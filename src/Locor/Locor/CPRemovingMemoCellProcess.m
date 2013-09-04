//
//  CPRemovingMemoCellProcess.m
//  Locor
//
//  Created by wangsw on 7/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRemovingMemoCellProcess.h"

static CPRemovingMemoCellProcess *process;

@implementation CPRemovingMemoCellProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPRemovingMemoCellProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end

