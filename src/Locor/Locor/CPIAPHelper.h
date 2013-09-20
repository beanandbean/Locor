//
//  CPIAPHelper.h
//  Locor
//
//  Created by wangyw on 9/20/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "StoreKit/StoreKit.h"

@interface CPIAPHelper : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

+ (void)requstProductList;

+ (NSArray *)productList;

+ (void)buyProduct:(SKProduct *)product;

+ (BOOL)isRemovedAdPurchased;

@end
