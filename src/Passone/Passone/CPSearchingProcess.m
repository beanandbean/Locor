//
//  CPSearchingProcess.m
//  Passone
//
//  Created by wangsw on 7/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSearchingProcess.h"

#import "CPAnimationProcess.h"

static CPSearchingProcess *process;
static NSArray *allowedProcess;

@implementation CPSearchingProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPSearchingProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    if (!allowedProcess) {
        allowedProcess = [NSArray arrayWithObjects:[CPAnimationProcess process], nil];
    }
    return [allowedProcess indexOfObject:process] != NSNotFound;
}

@end
