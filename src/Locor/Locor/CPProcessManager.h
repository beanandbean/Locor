//
//  CPProcessManager.h
//  Locor
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPProcess.h"

@interface CPProcessManager : NSObject

+ (bool)isInProcess:(id<CPProcess>)process;
+ (bool)startProcess:(id<CPProcess>)process;
+ (bool)startProcess:(id<CPProcess>)process withPreparation:(void (^)(void))preparation;
+ (bool)stopProcess:(id<CPProcess>)process;
+ (bool)stopProcess:(id<CPProcess>)process withPreparation:(void (^)(void))preparation;

+ (void)increaseForbiddenCount;
+ (void)decreaseForbiddenCount;

@end
