//
//  main.m
//  Locor
//
//  Created by wangyw on 6/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPAppDelegate.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        @try {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([CPAppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            NSLog(@"%@", exception.callStackSymbols);
        }
        @finally {
        }
    }
}
