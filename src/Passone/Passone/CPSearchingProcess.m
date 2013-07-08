//
//  CPSearchingProcess.m
//  Passone
//
//  Created by wangsw on 7/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSearchingProcess.h"

static CPSearchingProcess *process;

@implementation CPSearchingProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPSearchingProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
