//
//  CPDraggingPassCellProcess.m
//  Locor
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPDraggingPassCellProcess.h"

static CPDraggingPassCellProcess *g_process;

@implementation CPDraggingPassCellProcess

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPDraggingPassCellProcess alloc] init];
    }
    return g_process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
