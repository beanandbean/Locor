//
//  CPApplicationProcess.m
//  Passone
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPApplicationProcess.h"

#import "CPDraggingPassCellProcess.h"
#import "CPEditingPassCellProcess.h"
#import "CPRemovingPassCellProcess.h"
#import "CPSearchingProcess.h"

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
        allowedProcess = [NSArray arrayWithObjects:DRAGGING_PASS_CELL_PROCESS, EDITING_PASS_CELL_PROCESS, REMOVING_PASS_CELL_PROCESS, SEARCHING_PROCESS, nil];
    }
    return [allowedProcess indexOfObject:process] != NSNotFound;
}

@end
