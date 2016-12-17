//
//  AubioWrapper.m
//  Sport
//
//  Created by Tien on 5/11/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

#import "AubioWrapper.h"
#import <aubio/aubio.h>
//#import <Essentia/>
#include "essentia.h"
#include <essentia/algorithmfactory.h>
#include <essentia/essentiamath.h>
#include <essentia/pool.h>
#import <AudioKit/AudioKit.h>
#import <AudioKit/EZAudio.h>

#define AUBIO_DEBUG 0

using namespace essentia;
using namespace standard;

@implementation AubioWrapper

+ (AnalysisOutput *)analyzeAudioFile:(NSString *)srcPath {
    // ====================================================
    // AUBIO
    uint_t winSize = 1024;
    uint_t hopSize = winSize / 4;
    aubio_source_t *source = new_aubio_source((char_t *)(srcPath.UTF8String), 0, hopSize);
    uint_t sampleRate = aubio_source_get_samplerate(source);
    fvec_t *inputVec = new_fvec(hopSize); // input audio buffer
    uint_t read = 0;

    
    // Essentia vector
    std::vector<Real> vec;
    int idx = 0;
    // TODO: Add energy, happiness analisys here.
    do {
        aubio_source_do(source, inputVec, &read);
        if (idx >= sampleRate*10) {
            for (int i = 0; i<inputVec->length; i++) {
                vec.push_back(inputVec->data[i]);
            }
            if (vec.size() >= sampleRate*45) {
                break;
            }
        }
        idx += sampleRate;
    } while (read == hopSize);
    
    del_fvec(inputVec);
    del_aubio_source(source);
    aubio_cleanup();
    
    // ====================================================
    // ESSENTIA
    
    // register the algorithms in the factory(ies)
    essentia::init();
    
    // instanciate factory
    AlgorithmFactory& factory = AlgorithmFactory::instance();
    
    Real energy,dynamicComplexity;
    Algorithm* energyAlgo = factory.create("DynamicComplexity");
    energyAlgo->input("signal").set(vec);
    energyAlgo->output("loudness").set(energy);
    energyAlgo->output("dynamicComplexity").set(dynamicComplexity);
    energyAlgo->compute();
    std::cout << energy << " " << dynamicComplexity <<"\n";
    
    Real strength;
    std::string key, scale;
    Algorithm* intensiveAlgo = factory.create("KeyExtractor");
    intensiveAlgo->input("audio").set(vec);
    intensiveAlgo->output("key").set(key);
    intensiveAlgo->output("scale").set(scale);
    intensiveAlgo->output("strength").set(strength);
    intensiveAlgo->compute();
    
    strength -= 0.3; // Strength value from 0.4 -> 0.8x
    strength /= 0.6; // Convert to -1 -> 1 value
    if (scale.compare("minor") == 0) {
        strength = strength * -1;
    }
    
    Real bpm, confidence;
    std::vector<Real> ticks, estimates, bpmIntervals;
    Algorithm* rhythmAlgo = factory.create("RhythmExtractor2013");
    rhythmAlgo->input("signal").set(vec);
    rhythmAlgo->output("bpm").set(bpm);
    rhythmAlgo->output("confidence").set(confidence);
    rhythmAlgo->output("ticks").set(ticks);
    rhythmAlgo->output("estimates").set(estimates);
    rhythmAlgo->output("bpmIntervals").set(bpmIntervals);
    rhythmAlgo->compute();
    
    delete rhythmAlgo;
    delete energyAlgo;
    delete intensiveAlgo;
    
    // shut down essentia
    essentia::shutdown();
    vec.clear();
    
    
    // ====================================================
    // TODO: Change value of energy & valence to the analized value.
    AnalysisOutput *output = [[AnalysisOutput alloc] initWithTempo:bpm
                                                            energy:energy
                                                           valence:strength];
    return output;}

@end
