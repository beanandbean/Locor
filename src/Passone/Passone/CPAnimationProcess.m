//
//  CPAnimationProcess.m
//  Passone
//
//  Created by wangsw on 7/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPAnimationProcess.h"

static CPAnimationProcess *process;

@implementation CPAnimationProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPAnimationProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
