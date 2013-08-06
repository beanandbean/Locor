//
//  CPEditingPassCellProcess.m
//  Passone
//
//  Created by wangsw on 8/6/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPEditingPassCellProcess.h"

#import "CPAnimationProcess.h"
#import "CPEditingMemoCellProcess.h"
#import "CPPreparationProcess.h"
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
        allowedProcess = [NSArray arrayWithObjects:[CPAnimationProcess process], [CPEditingMemoCellProcess process], [CPPreparationProcess process], [CPRemovingMemoCellProcess process], [CPScrollingCollectionViewProcess process], nil];
    }
    return [allowedProcess indexOfObject:process] != NSNotFound;
}

@end
