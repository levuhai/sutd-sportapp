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

#define AUBIO_DEBUG 0

using namespace essentia;
using namespace standard;

@implementation AubioWrapper

+ (AnalysisOutput *)simpleAnalyzeAudioFile:(NSString *)srcPath {
    
    // ====================================================
    // ESSENTIA
    // register the algorithms in the factory(ies)
    essentia::init();
    
    // instanciate factory
    AlgorithmFactory& factory = AlgorithmFactory::instance();
   
    
    Algorithm* s = factory.create("Spectrum",
                                         "size", 2048);
    
    // shut down essentia
    essentia::shutdown();
    
    // ====================================================
    // AUBIO
    uint_t winSize = 1024;
    uint_t hopSize = winSize / 4;
    aubio_source_t *source = new_aubio_source((char_t *)(srcPath.UTF8String), 0, hopSize);
    uint_t sampleRate = aubio_source_get_samplerate(source);
    
    fvec_t *inputVec = new_fvec(hopSize); // input audio buffer
    fvec_t *outputVec = new_fvec(2); // output position
    
    // create tempo object
    aubio_tempo_t *tempoObject = new_aubio_tempo("default", winSize, hopSize, sampleRate);
    uint_t nFrames = 0;
    uint_t read = 0;
    NSMutableDictionary* dic = [NSMutableDictionary new];
    
    // BPM
    int cBPM = 0;
    NSString* sBPM = @"";
    double outputValue = 0;
    // db level
    smpl_t dbLevel = 0.0;
    // count
    int readCount = 0;
    
    // TODO: Add energy, happiness analisys here.
    do {
        aubio_source_do(source, inputVec, &read);
        
        // execute tempo
        aubio_tempo_do(tempoObject, inputVec, outputVec);
        
        // BPM
        if (outputVec->data[0] != 0) {
            #if AUBIO_DEBUG
                NSLog(@"beat at %.3fs, frame %d, %.2fbpm with confidence %.2f\n",
                        aubio_tempo_get_last_s(tempoObject),
                        aubio_tempo_get_last(tempoObject),
                        aubio_tempo_get_bpm(tempoObject),
                        aubio_tempo_get_confidence(tempoObject));
            #endif
        
            // Count instance
            cBPM = aubio_tempo_get_bpm(tempoObject);
            sBPM = [NSString stringWithFormat:@"%d",cBPM];
            if (dic[sBPM]) {
                int b = [dic[sBPM] intValue];
                dic[sBPM] = [NSNumber numberWithInt:b+1];
            } else {
                dic[sBPM] = @1;
            }
        }
        
        // RMS: amplitude
        // each element can be accessed directly
        float val = fmaxf(aubio_db_spl(inputVec),-60.0);
        
        readCount += 1;
        dbLevel += val;

        nFrames += read;
        
    } while (read == hopSize);
    
#if AUBIO_DEBUG
    // Print tempo value
    
#endif
    
    // Calculate BPM
    // Get highest instance count
    int count = 0;
    
    for (NSString* key in dic.allKeys) {
        int val = [dic[key] intValue];
        if (val > count) {
            count = val;
            outputValue = [key floatValue];
        }
    }
    
    // Calculate Amplitude
    dbLevel = ((dbLevel/readCount)+60.0)/60.0;
    
    // Log
    NSLog(@"BPM:%f DB:%f",outputValue, dbLevel);
    
    del_aubio_tempo(tempoObject);
    del_fvec(inputVec);
    del_fvec(outputVec);
    del_aubio_source(source);
    aubio_cleanup();
    
    // TODO: Change value of energy & valence to the analized value.
    AnalysisOutput *output = [[AnalysisOutput alloc] initWithTempo:outputValue
                                                            energy:dbLevel
                                                           valence:0];
    return output;
}

@end
