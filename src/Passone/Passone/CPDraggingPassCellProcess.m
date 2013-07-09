//
//  CPDraggingPassCellProcess.m
//  Passone
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPDraggingPassCellProcess.h"

#import "CPAnimationProcess.h"
#import "CPPreparationProcess.h"

static CPDraggingPassCellProcess *process;
static NSArray *allowedProcess;

@implementation CPDraggingPassCellProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPDraggingPassCellProcess alloc] init];
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
