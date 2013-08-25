//
//  CPSearchingProcess.m
//  Passone
//
//  Created by wangsw on 7/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSearchingProcess.h"

#import "CPEditingMemoCellProcess.h"
#import "CPRemovingMemoCellProcess.h"
#import "CPScrollingCollectionViewProcess.h"

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
        allowedProcess = [NSArray arrayWithObjects:EDITING_MEMO_CELL_PROCESS, REMOVING_MEMO_CELL_PROCESS, SCROLLING_COLLECTION_VIEW_PROCESS, nil];
    }
    return [allowedProcess indexOfObject:process] != NSNotFound;
}

@end
