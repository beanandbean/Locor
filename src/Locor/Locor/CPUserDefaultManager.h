//
//  CPUserDefaultManager.h
//  Locor
//
//  Created by wangyw on 9/19/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPUserDefaultManager : NSObject

+ (void)registerDefaults;

+ (BOOL)isFirstRunning;
+ (void)setFirstRuning:(BOOL)firstRunning;

+ (NSArray *)mainPass;
+ (void)setMainPass:(NSArray *)mainPass;

+ (BOOL)isProductPurchased:(NSString *)productName;
+ (void)setProduct:(NSString *)productName purchased:(BOOL)purchased;

@end
