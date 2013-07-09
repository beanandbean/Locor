//
//  CPRemovingPassCellProcess.m
//  Passone
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRemovingPassCellProcess.h"

#import "CPAnimationProcess.h"
#import "CPPreparationProcess.h"

static CPRemovingPassCellProcess *process;
static NSArray *allowedProcess;

@implementation CPRemovingPassCellProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPRemovingPassCellProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    if (!allowedProcess) {
        allowedProcess = [NSArray arrayWithObjects:[CPAnimationProcess process], [CPPreparationProcess process], nil];
    }
    return [allowedProcess indexOfObject:process] != NSNotFound;
}

@end
