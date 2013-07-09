//
//  CPPreparationProcess.m
//  Passone
//
//  Created by wangsw on 7/9/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPreparationProcess.h"

#import "CPAnimationProcess.h"

static CPPreparationProcess *process;
static NSArray *allowedProcess;

@implementation CPPreparationProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPPreparationProcess alloc] init];
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
