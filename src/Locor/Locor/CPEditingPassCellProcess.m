//
//  CPEditingPassCellProcess.m
//  Locor
//
//  Created by wangsw on 8/6/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPEditingPassCellProcess.h"

#import "CPEditingMemoCellProcess.h"
#import "CPRemovingMemoCellProcess.h"
#import "CPScrollingCollectionViewProcess.h"

static CPEditingPassCellProcess *process;
static NSArray *allowedProcess;

@implementation CPEditingPassCellProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPEditingPassCellProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    if (!allowedProcess) {
        allowedProcess = [NSArray arrayWithObjects:EDITING_MEMO_CELL_PROCESS, REMOVING_MEMO_CELL_PROCESS, SCROLLING_COLLECTION_VIEW_PROCESS, nil];
    }
    return [allowedProcess indexOfObject:process] != NSNotFound;
}

@end
