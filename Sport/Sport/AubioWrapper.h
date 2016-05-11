//
//  AubioWrapper.h
//  Sport
//
//  Created by Tien on 5/11/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <aubio/aubio.h>

@interface AubioWrapper : NSObject

+ (void)simpleAnalyzeAudioFile:(NSString *)srcPath;

@end
