//
//  CPProcessManager.m
//  Passone
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPProcessManager.h"

#import "CPApplicationProcess.h"

#define NO_PROCESS_LOG

static NSMutableArray *processArray;
static int forbiddenCount = 0;

@interface CPProcessManager ()

+ (NSMutableArray *)processArray;

@end

@implementation CPProcessManager

+ (NSMutableArray *)processArray {
    if (!processArray) {
        processArray = [NSMutableArray arrayWithObject:[CPApplicationProcess process]];
    }
    return processArray;
}

+ (bool)isInProcess:(id<CPProcess>)process {
    return [[CPProcessManager processArray] indexOfObject:process] != NSNotFound;
}

+ (bool)startProcess:(id<CPProcess>)process {
    if (!forbiddenCount && [[[CPProcessManager processArray] lastObject] allowSubprocess:process]) {
        [processArray addObject:process];
        return YES;
    } else {
        
#ifndef NO_PROCESS_LOG
        NSLog(@"Try to start process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), [CPProcessManager processArray]);
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
        NSLog(@"Try to start process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), [CPProcessManager processArray]);
#endif
        
        return NO;
    }
}

+ (bool)stopProcess:(id<CPProcess>)process {
    if (!forbiddenCount && process != [CPApplicationProcess process] && [[CPProcessManager processArray] lastObject] == process) {
        [[CPProcessManager processArray] removeLastObject];
        return YES;
    } else {
    
#ifndef NO_PROCESS_LOG
        NSLog(@"Try to stop process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), [CPProcessManager processArray]);
#endif
    
        return NO;
    }
}

+ (bool)stopProcess:(id<CPProcess>)process withPreparation:(void (^)(void))preparation {
    if ([CPProcessManager stopProcess:process]) {
        [CPProcessManager increaseForbiddenCount];
        preparation();
        [CPProcessManager decreaseForbiddenCount];
        return YES;
    } else {
    
#ifndef NO_PROCESS_LOG
        NSLog(@"Try to stop process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), [CPProcessManager processArray]);
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
