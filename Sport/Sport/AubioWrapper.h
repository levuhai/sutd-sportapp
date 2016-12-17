//
//  AubioWrapper.h
//  Sport
//
//  Created by Tien on 5/11/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnalysisOutput.h"

@interface AubioWrapper : NSObject

+ (AnalysisOutput *)analyzeAudioFile:(NSString *)srcPath;
//+ (AnalysisOutput *)analyzeAudioFile:(NSString*)path dataArray:(NSArray*)arr;

@end
