//
//  EssentiaWrapper.m
//  Sport
//
//  Created by Tien on 6/18/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

#import "EssentiaWrapper.h"
#import "essentia.h"
#include "algorithmfactory.h"
#include "essentiamath.h"
#include "pool.h"

@implementation EssentiaWrapper

using namespace essentia::standard;

+ (void)foo {
    // register the algorithms in the factory(ies)
    essentia::init();
    
    essentia::Pool pool;
    
    /////// PARAMS //////////////
    int sampleRate = 44100;
    int frameSize = 2048;
    int hopSize = 1024;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"big" ofType:@"mp3"];
    
    AlgorithmFactory& factory = essentia::standard::AlgorithmFactory::instance();
    
    Algorithm* audio = factory.create("MonoLoader",
                                      "filename", [path cStringUsingEncoding:NSUTF8StringEncoding],
                                      "sampleRate", sampleRate);
    
    Algorithm* fc    = factory.create("FrameCreator",
                                      "frameSize", frameSize,
                                      "hopSize", hopSize);
    
    Algorithm* w     = factory.create("Windowing",
                                      "type", "blackmanharris62");

    Algorithm* spec  = factory.create("Spectrum");
    Algorithm* mfcc  = factory.create("MFCC");
    
    /////////// CONNECTING THE ALGORITHMS ////////////////
    std::cout << "-------- connecting algos ---------" << std::endl;
    
    // Audio -> FrameCutter
    std::vector<essentia::Real> audioBuffer;
    
    audio->output("audio").set(audioBuffer);
    fc->input("signal").set(audioBuffer);
    
    // FrameCutter -> Windowing -> Spectrum
    std::vector<essentia::Real> frame, windowedFrame;
    
    fc->output("frame").set(frame);
    w->input("signal").set(frame);
    
    w->output("windowedSignal").set(windowedFrame);
    spec->input("signal").set(windowedFrame);
    
    // Spectrum -> MFCC
    std::vector<essentia::Real> spectrum, mfccCoeffs, mfccBands;
    
    spec->output("spectrum").set(spectrum);
    mfcc->input("spectrum").set(spectrum);
    
    mfcc->output("bands").set(mfccBands);
    mfcc->output("mfcc").set(mfccCoeffs);
    
    /////////// STARTING THE ALGORITHMS //////////////////
    std::cout << "-------- start processing " << [path cStringUsingEncoding:NSUTF8StringEncoding] << " --------" << std::endl;
    
    audio->compute();

    while (true) {
        
        // compute a frame
        fc->compute();
        
        // if it was the last one (ie: it was empty), then we're done.
        if (!frame.size()) {
            break;
        }
        
        // if the frame is silent, just drop it and go on processing
        if (essentia::isSilent(frame)) continue;
        
        w->compute();
        spec->compute();
        mfcc->compute();
        
        pool.add("lowlevel.mfcc", mfccCoeffs);
        
    }
}

@end
