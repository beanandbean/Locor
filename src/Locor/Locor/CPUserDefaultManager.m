//
//  CPUserDefaultManager.m
//  Locor
//
//  Created by wangyw on 9/19/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPUserDefaultManager.h"

static NSString *KEY_COMPLETED_TRANSACTIONS_RESTORED = @"CompletedTransactionsRestored";
static NSString *KEY_IS_FIRST_RUNNING = @"IsFirstRunning";
static NSString *KEY_MAIN_PASS = @"MainPass";

@implementation CPUserDefaultManager

+ (void)registerDefaults {
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [NSNumber numberWithBool:NO], KEY_COMPLETED_TRANSACTIONS_RESTORED,
                                                             [NSNumber numberWithBool:YES], KEY_IS_FIRST_RUNNING,
                                                             @"", KEY_MAIN_PASS,
                                                             nil]];
}

+ (BOOL)isCompletedTransactionsRestored {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KEY_COMPLETED_TRANSACTIONS_RESTORED];
}

+ (void)setCompletedTransactionsRestored:(BOOL)completedTransactionsRestored {
    [[NSUserDefaults standardUserDefaults] setBool:completedTransactionsRestored forKey:KEY_COMPLETED_TRANSACTIONS_RESTORED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isFirstRunning {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_FIRST_RUNNING];
}

+ (void)setFirstRuning:(BOOL)firstRunning {
    [[NSUserDefaults standardUserDefaults] setBool:firstRunning forKey:KEY_IS_FIRST_RUNNING];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)mainPass {
    NSMutableArray *result = [NSMutableArray array];
    NSMutableString *mainPassString = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_MAIN_PASS];
    for (int i = 0; i < mainPassString.length; i++) {
        int number = [mainPassString characterAtIndex:i] - '0';
        NSAssert(number >= 0 && number <= 8, @"");
        [result addObject:[NSNumber numberWithInt:number]];
    }
    return [result copy];
}

+ (void)setMainPass:(NSArray *)mainPass {
    NSMutableString *mainPassString = [[NSMutableString alloc] init];
    for (NSNumber *number in mainPass) {
        [mainPassString appendFormat:@"%d", number.intValue];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[mainPassString copy] forKey:KEY_MAIN_PASS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isProductPurchased:(NSString *)productName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:productName];
}

+ (void)setProduct:(NSString *)productName purchased:(BOOL)purchased {
    [[NSUserDefaults standardUserDefaults] setBool:purchased forKey:productName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
