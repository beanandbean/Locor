//
//  CPProcessManager.h
//  Passone
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPProcess.h"

@interface CPProcessManager : NSObject

+ (bool)isInProcess:(id<CPProcess>)process;
+ (bool)startProcess:(id<CPProcess>)process;
+ (bool)stopProcess:(id<CPProcess>)process;

@end
