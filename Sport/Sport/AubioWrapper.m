//
//  AubioWrapper.m
//  Sport
//
//  Created by Tien on 5/11/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

#import "AubioWrapper.h"
#import <aubio/aubio.h>

@implementation AubioWrapper

+ (AnalysisOutput *)simpleAnalyzeAudioFile:(NSString *)srcPath {
    // Low pass array
    
    uint_t winSize = 1024;
    uint_t hopSize = winSize / 4;
    aubio_source_t *source = new_aubio_source((char_t *)(srcPath.UTF8String), 0, hopSize);
    uint_t sampleRate = aubio_source_get_samplerate(source);
    NSLog(@"Sample rate: %d", sampleRate);
    
    fvec_t *inputVec = new_fvec(hopSize); // input audio buffer
    fvec_t *outputVec = new_fvec(2); // output position
    
    // create tempo object
    aubio_tempo_t *tempoObject = new_aubio_tempo("default", winSize, hopSize, sampleRate);
    uint_t nFrames = 0;
    uint_t read = 0;

    double currnetBpm = 0, lastBpm = 0;
    double rate = 0.5;
    double outputValue = 0;

    do {
        aubio_source_do(source, inputVec, &read);
        
        // execute tempo
        aubio_tempo_do(tempoObject, inputVec, outputVec);
        
        // do something with the beats
        if (outputVec->data[0] != 0) {
#ifdef DEBUG
            NSLog(@"beat at %.3fs, frame %d, %.2fbpm with confidence %.2f\n",
                      aubio_tempo_get_last_s(tempoObject),
                      aubio_tempo_get_last(tempoObject),
                      aubio_tempo_get_bpm(tempoObject),
                      aubio_tempo_get_confidence(tempoObject));
#endif
        
            // Low pass filter
            currnetBpm = aubio_tempo_get_bpm(tempoObject);
            outputValue = rate * currnetBpm + (1.0 - rate) * lastBpm;
            lastBpm = currnetBpm;
            
        } else {
//            NSLog(@"missed");
        }
        nFrames += read;
    } while (read == hopSize);
    
#ifdef DEBUG
    // Print tempo value
    NSLog(@"TEMPO: %f", outputValue);
#endif
    
    del_aubio_tempo(tempoObject);
    del_fvec(inputVec);
    del_fvec(outputVec);
    del_aubio_source(source);
    aubio_cleanup();
    
    AnalysisOutput *output = [[AnalysisOutput alloc] initWithTempo:outputValue energy:0 valence:0];
    return output;
}

@end
