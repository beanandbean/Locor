//
//  CPSettingsProcess.m
//  Locor
//
//  Created by wangsw on 9/13/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSettingsProcess.h"

static CPSettingsProcess *g_process;

@implementation CPSettingsProcess

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPSettingsProcess alloc] init];
    }
    return g_process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
