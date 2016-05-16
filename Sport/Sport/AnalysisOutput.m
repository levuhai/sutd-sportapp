//
//  AnalysisOutput.m
//  Sport
//
//  Created by Tien on 5/16/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

#import "AnalysisOutput.h"

@implementation AnalysisOutput

- (instancetype)initWithTempo:(double)tempo energy:(double)energy valence:(double)valence {
    
    if (self = [super init]) {
        _tempo = tempo;
        _energy = energy;
        _valence = valence;
    }
    
    return self;
}

@end
