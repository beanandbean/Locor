//
//  CPUserDefaultManager.m
//  Locor
//
//  Created by wangyw on 9/19/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPUserDefaultManager.h"

static NSString *g_keyIsFirstRunning = @"IsFirstRunning";
static NSString *g_keyMainPass = @"MainPass";

@implementation CPUserDefaultManager

+ (void)registerDefaults {
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [NSNumber numberWithBool:YES], g_keyIsFirstRunning,
                                                             @"", g_keyMainPass,
                                                             nil]];
}

+ (BOOL)isFirstRunning {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_keyIsFirstRunning];
}

+ (void)setFirstRuning:(BOOL)firstRunning {
    [[NSUserDefaults standardUserDefaults] setBool:firstRunning forKey:g_keyIsFirstRunning];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)mainPass {
    NSMutableArray *result = [NSMutableArray array];
    NSMutableString *mainPassString = [[NSUserDefaults standardUserDefaults] objectForKey:g_keyMainPass];
    for (int i = 0; i < mainPassString.length; i++) {
        int number = [mainPassString characterAtIndex:i] - '0';
        NSAssert(number >= 0 && number <= 8 , @"");
        [result addObject:[NSNumber numberWithInt:number]];
    }
    return [result copy];
}

+ (void)setMainPass:(NSArray *)mainPass {
    NSMutableString *mainPassString = [[NSMutableString alloc] init];
    for (NSNumber *number in mainPass) {
        [mainPassString appendFormat:@"%d", number.intValue];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[mainPassString copy] forKey:g_keyMainPass];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
