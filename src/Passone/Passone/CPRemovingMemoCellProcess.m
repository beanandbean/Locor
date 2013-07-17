//
//  CPRemovingMemoCellProcess.m
//  Passone
//
//  Created by wangsw on 7/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRemovingMemoCellProcess.h"

#import "CPAnimationProcess.h"
#import "CPPreparationProcess.h"

static CPRemovingMemoCellProcess *process;
static NSArray *allowedProcess;

@implementation CPRemovingMemoCellProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPRemovingMemoCellProcess alloc] init];
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

