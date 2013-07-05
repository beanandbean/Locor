//
//  CPProcessManager.m
//  Passone
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPProcessManager.h"

#import "CPApplicationProcess.h"

static NSMutableArray *processArray;

@interface CPProcessManager ()

+ (NSMutableArray *)processArray;

@end

@implementation CPProcessManager

+ (bool)isInProcess:(id<CPProcess>)process {
    return [[CPProcessManager processArray] indexOfObject:process] != NSNotFound;
}

+ (bool)startProcess:(id<CPProcess>)process {
    if ([[[CPProcessManager processArray] lastObject] allowSubprocess:process]) {
        [processArray addObject:process];
        return YES;
    } else {
        return NO;
    }
}

+ (bool)stopProcess:(id<CPProcess>)process {
    if (process != [CPApplicationProcess process] && process == [[CPProcessManager processArray] lastObject]) {
        [[CPProcessManager processArray] removeLastObject];
        return YES;
    } else {
        return NO;
    }
}

+ (NSMutableArray *)processArray {
    if (!processArray) {
        processArray = [NSMutableArray arrayWithObject:[CPApplicationProcess process]];
    }
    return processArray;
}

@end
