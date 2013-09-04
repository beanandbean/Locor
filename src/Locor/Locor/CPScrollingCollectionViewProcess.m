//
//  CPScrollingCollectionViewProcess.m
//  Locor
//
//  Created by wangsw on 7/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPScrollingCollectionViewProcess.h"

static CPScrollingCollectionViewProcess *process;

@implementation CPScrollingCollectionViewProcess

+ (id<CPProcess>)process {
    if (!process) {
        process = [[CPScrollingCollectionViewProcess alloc] init];
    }
    return process;
}

- (bool)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end

