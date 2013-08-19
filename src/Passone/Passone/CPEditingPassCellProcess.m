//
//  CPEditingPassCellProcess.m
//  Passone
//
//  Created by wangsw on 8/6/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPEditingPassCellProcess.h"

#import "CPEditingMemoCellProcess.h"
#import "CPRemovingMemoCellProcess.h"
#import "CPScrollingCollectionViewProcess.h"
#import "CPSearchingProcess.h"

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
        allowedProcess = [NSArray arrayWithObjects:[CPEditingMemoCellProcess process], [CPRemovingMemoCellProcess process], [CPScrollingCollectionViewProcess process], [CPSearchingProcess process], nil];
    }
    return [allowedProcess indexOfObject:process] != NSNotFound;
}

@end
