//
//  AnalysisOutput.h
//  Sport
//
//  Created by Tien on 5/16/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalysisOutput : NSObject

@property (assign, nonatomic) double tempo;
@property (assign, nonatomic) double energy;
@property (assign, nonatomic) double valence;

- (instancetype)initWithTempo:(double)tempo energy:(double)energy valence:(double)valence;

@end
