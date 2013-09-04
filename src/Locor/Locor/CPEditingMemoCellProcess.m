//
//  CPEditingMemoCellProcess.m
//  Locor
//
//  Created by wangsw on 7/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPEditingMemoCellProcess.h"

static CPEditingMemoCellProcess *process;

@implementation CPEditingMemoCellProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPEditingMemoCellProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
