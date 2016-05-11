//
//  AubioWrapper.m
//  Sport
//
//  Created by Tien on 5/11/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

#import "AubioWrapper.h"

@implementation AubioWrapper

+ (void)simpleAnalyzeAudioFile:(NSString *)srcPath {
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
    do {
        aubio_source_do(source, inputVec, &read);
        
        // execute tempo
        aubio_tempo_do(tempoObject, inputVec, outputVec);
        
        // do something with the beats
        if (outputVec->data[0] != 0) {
            NSLog(@"beat at %.3fms, %.3fs, frame %d, %.2fbpm with confidence %.2f\n",
                  aubio_tempo_get_last_ms(tempoObject), aubio_tempo_get_last_s(tempoObject),
                  aubio_tempo_get_last(tempoObject), aubio_tempo_get_bpm(tempoObject), aubio_tempo_get_confidence(tempoObject));
        }
        nFrames += read;
    } while (read == hopSize);
    
    del_aubio_tempo(tempoObject);
    del_fvec(inputVec);
    del_fvec(outputVec);
    del_aubio_source(source);
    aubio_cleanup();
    
}

@end
