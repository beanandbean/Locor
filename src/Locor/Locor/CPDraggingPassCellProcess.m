//
//  CPDraggingPassCellProcess.m
//  Locor
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPDraggingPassCellProcess.h"

static CPDraggingPassCellProcess *process;

@implementation CPDraggingPassCellProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPDraggingPassCellProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
