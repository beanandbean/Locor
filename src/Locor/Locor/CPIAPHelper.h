//
//  CPIAPHelper.h
//  Locor
//
//  Created by wangyw on 9/20/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "StoreKit/StoreKit.h"

extern const NSString * const CPProductNameRemoveAd;

@class CPIAPHelper;

@protocol CPIAPHelperDelegate <NSObject>

- (void)helper:(CPIAPHelper *)helper didReceiveProducts:(NSArray *)products;

- (void)helper:(CPIAPHelper *)helper didPurchaseProduct:(NSString *)productIdentifier;

- (void)helper:(CPIAPHelper *)helper didRestoreProduct:(NSString *)productIdentifier;

@end

@interface CPIAPHelper : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (weak, nonatomic) id<CPIAPHelperDelegate> delegate;

- (void)requstProducts;

- (void)buyProduct:(SKProduct *)product;

- (void)restoreProducts;

@end
