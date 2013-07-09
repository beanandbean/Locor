//
//  CPApplicationProcess.m
//  Passone
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPApplicationProcess.h"

#import "CPAnimationProcess.h"
#import "CPDraggingPassCellProcess.h"
#import "CPRemovingPassCellProcess.h"
#import "CPSearchingProcess.h"
#import "CPPreparationProcess.h"

static CPApplicationProcess *process;
static NSArray *allowedProcess;

@implementation CPApplicationProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPApplicationProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    if (!allowedProcess) {
        allowedProcess = [NSArray arrayWithObjects:[CPAnimationProcess process], [CPDraggingPassCellProcess process], [CPPreparationProcess process], [CPRemovingPassCellProcess process], [CPSearchingProcess process], nil];
    }
    return [allowedProcess indexOfObject:process] != NSNotFound;
}

@end
