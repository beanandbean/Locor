//
//  CPSettingsProcess.m
//  Locor
//
//  Created by wangsw on 9/13/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSettingsProcess.h"

static CPSettingsProcess *process;

@implementation CPSettingsProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPSettingsProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
