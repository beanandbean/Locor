//
//  CPProcessManager.m
//  Passone
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPProcessManager.h"

#import "CPAnimationProcess.h"
#import "CPApplicationProcess.h"
#import "CPPreparationProcess.h"

static NSMutableArray *processArray;

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
    if ([[[CPProcessManager processArray] lastObject] allowSubprocess:process]) {
        [processArray addObject:process];
        return YES;
    } else {
        return NO;
    }
}

+ (bool)startProcess:(id<CPProcess>)process withPreparation:(void (^)(void))preparation {
    if ([CPProcessManager startProcess:process]) {
        // Preparation process provides not REQUIRED protect, so there's no need to check if it is started successfully.
        [CPProcessManager startProcess:[CPPreparationProcess process]];
        preparation();
        [CPProcessManager stopProcess:[CPPreparationProcess process]];
        return YES;
    } else {
        return NO;
    }
}

+ (bool)stopProcess:(id<CPProcess>)process {
    if (process != [CPApplicationProcess process]) {
        int index = [CPProcessManager processArray].count - 1;
        while (index > 0 && [[CPProcessManager processArray] objectAtIndex:index] != process) {
            index--;
        }
        if (index > 0 && (index == [CPProcessManager processArray].count - 1 || [[[CPProcessManager processArray] objectAtIndex:index - 1] allowSubprocess:[[CPProcessManager processArray] objectAtIndex:index + 1]])) {
            [[CPProcessManager processArray] removeObjectAtIndex:index];
            return YES;
        }
    }
    return NO;
}

+ (bool)stopProcess:(id<CPProcess>)process withPreparation:(void (^)(void))preparation {
    if (process != [CPApplicationProcess process]) {
        int index = [CPProcessManager processArray].count - 1;
        while (index > 0 && [[CPProcessManager processArray] objectAtIndex:index] != process) {
            index--;
        }
        if (index > 0 && (index == [CPProcessManager processArray].count - 1 || [[[CPProcessManager processArray] objectAtIndex:index - 1] allowSubprocess:[[CPProcessManager processArray] objectAtIndex:index + 1]])) {
            [CPProcessManager startProcess:[CPPreparationProcess process]];
            preparation();
            [CPProcessManager stopProcess:[CPPreparationProcess process]];
            [[CPProcessManager processArray] removeObjectAtIndex:index];
            return YES;
        }
    }
    return NO;
}

@end
