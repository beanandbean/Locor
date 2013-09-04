//
//  CPRemovingPassCellProcess.m
//  Locor
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRemovingPassCellProcess.h"

static CPRemovingPassCellProcess *process;

@implementation CPRemovingPassCellProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPRemovingPassCellProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
