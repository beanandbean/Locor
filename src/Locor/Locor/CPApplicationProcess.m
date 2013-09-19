//
//  CPApplicationProcess.m
//  Locor
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPApplicationProcess.h"

#import "CPDraggingPassCellProcess.h"
#import "CPEditingPassCellProcess.h"
#import "CPRemovingPassCellProcess.h"
#import "CPSearchingProcess.h"
#import "CPSettingsProcess.h"

static CPApplicationProcess *g_process;
static NSArray *g_allowedProcess;

@implementation CPApplicationProcess

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPApplicationProcess alloc] init];
    }
    return g_process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    if (!g_allowedProcess) {
        g_allowedProcess = [NSArray arrayWithObjects:DRAGGING_PASS_CELL_PROCESS, EDITING_PASS_CELL_PROCESS, REMOVING_PASS_CELL_PROCESS, SEARCHING_PROCESS, SETTINGS_PROCESS, nil];
    }
    return [g_allowedProcess indexOfObject:process] != NSNotFound;
}

@end
