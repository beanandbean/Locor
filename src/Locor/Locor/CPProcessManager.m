//
//  CPProcessManager.m
//  Locor
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPProcessManager.h"

#import "CPApplicationProcess.h"

#define NO_PROCESS_LOG

#define PROCESS_ARRAY [CPProcessManager processArray]

static NSMutableArray *processArray;
static int forbiddenCount = 0;

@implementation CPProcessManager

+ (NSMutableArray *)processArray {
    if (!processArray) {
        processArray = [NSMutableArray arrayWithObject:APPLICATION_PROCESS];
    }
    return processArray;
}

+ (bool)isInProcess:(id<CPProcess>)process {
    return [PROCESS_ARRAY indexOfObject:process] != NSNotFound;
}

+ (bool)startProcess:(id<CPProcess>)process {
    if (!forbiddenCount && [[PROCESS_ARRAY lastObject] allowSubprocess:process]) {
        [processArray addObject:process];
        return YES;
    } else {
        
#ifndef NO_PROCESS_LOG
        NSLog(@"Try to start process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), PROCESS_ARRAY);
#endif
        
        return NO;
    }
}

+ (bool)startProcess:(id<CPProcess>)process withPreparation:(void (^)(void))preparation {
    if ([CPProcessManager startProcess:process]) {
        // Preparation process provides not REQUIRED protect, so there's no need to check if it is started successfully.
        [CPProcessManager increaseForbiddenCount];
        preparation();
        [CPProcessManager decreaseForbiddenCount];
        return YES;
    } else {
        
#ifndef NO_PROCESS_LOG
        NSLog(@"Try to start process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), PROCESS_ARRAY);
#endif
        
        return NO;
    }
}

+ (bool)stopProcess:(id<CPProcess>)process {
    if (!forbiddenCount && process != APPLICATION_PROCESS) {
        int index = PROCESS_ARRAY.count - 1;
        while (index > 0 && [PROCESS_ARRAY objectAtIndex:index] != process) {
            index--;
        }
        if (index > 0 && (index == PROCESS_ARRAY.count - 1 || [[PROCESS_ARRAY objectAtIndex:index - 1] allowSubprocess:[PROCESS_ARRAY objectAtIndex:index + 1]])) {
            [PROCESS_ARRAY removeObjectAtIndex:index];
            return YES;
        }
    }
    
#ifndef NO_PROCESS_LOG
    NSLog(@"Try to stop process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), PROCESS_ARRAY);
#endif
    
    return NO;
}

+ (bool)stopProcess:(id<CPProcess>)process withPreparation:(void (^)(void))preparation {
    if ([CPProcessManager stopProcess:process]) {
        [CPProcessManager increaseForbiddenCount];
        preparation();
        [CPProcessManager decreaseForbiddenCount];
        return YES;
    } else {
    
#ifndef NO_PROCESS_LOG
        NSLog(@"Try to stop process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), PROCESS_ARRAY);
#endif
    
        return NO;
    }
}

+ (void)increaseForbiddenCount {
    forbiddenCount++;
}

+ (void)decreaseForbiddenCount {
    if (forbiddenCount > 0) {
        forbiddenCount--;
    }
}

@end