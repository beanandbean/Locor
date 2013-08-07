//
//  CPEditingMemoCellProcess.m
//  Passone
//
//  Created by wangsw on 7/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPEditingMemoCellProcess.h"

#import "CPRemovingMemoCellProcess.h"
#import "CPScrollingCollectionViewProcess.h"

static CPEditingMemoCellProcess *process;
static NSArray *allowedProcess;

@implementation CPEditingMemoCellProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPEditingMemoCellProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    if (!allowedProcess) {
        allowedProcess = [NSArray arrayWithObjects:[CPRemovingMemoCellProcess process], [CPScrollingCollectionViewProcess process], nil];
    }
    return [allowedProcess indexOfObject:process] != NSNotFound;
}

@end
