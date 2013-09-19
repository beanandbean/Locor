//
//  CPRemovingPassCellProcess.m
//  Locor
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRemovingPassCellProcess.h"

static CPRemovingPassCellProcess *g_process;

@implementation CPRemovingPassCellProcess

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPRemovingPassCellProcess alloc] init];
    }
    return g_process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
