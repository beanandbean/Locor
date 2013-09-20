//
//  CPIAPHelper.m
//  Locor
//
//  Created by wangyw on 9/20/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPIAPHelper.h"

#import "CPUserDefaultManager.h"

static NSString *REMOVE_AD_NAME = @"Remove Ad";

@interface CPIAPHelper ()

@property (strong, nonatomic) NSArray *productList;

@end

@implementation CPIAPHelper

static CPIAPHelper *g_helper = nil;

+ (CPIAPHelper *)helper {
    if (!g_helper) {
        g_helper = [[CPIAPHelper alloc] init];
    }
    return g_helper;
}

- (id)init {
    self = [super init];
    if (self) {
        if ([SKPaymentQueue canMakePayments]) {
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            
            if (![CPUserDefaultManager isCompletedTransactionsRestored]) {
                [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
            }
        }
    }
    return self;
}

+ (void)requstProductList {
    if ([SKPaymentQueue canMakePayments]) {
        SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:REMOVE_AD_NAME, nil]];
        productRequest.delegate = [CPIAPHelper helper];
        [productRequest start];
    }
}

+ (NSArray *)productList {
    return [CPIAPHelper helper].productList;
}

+ (void)buyProduct:(SKProduct *)product {
    if ([SKPaymentQueue canMakePayments]) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

+ (BOOL)isRemovedAdPurchased {
    return [CPUserDefaultManager isProductPurchased:REMOVE_AD_NAME];
}

#pragma mark - SKPaymentTransactionObserver implement

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStatePurchased:
                [CPUserDefaultManager setProduct:transaction.payment.productIdentifier purchased:YES];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Removed Ad purchased" message:@"Removed Ad purchased" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alertView show];
            }
                break;
            case SKPaymentTransactionStateRestored:
                [CPUserDefaultManager setProduct:transaction.payment.productIdentifier purchased:YES];
                [CPUserDefaultManager setCompletedTransactionsRestored:YES];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

#pragma mark - SKProductsRequestDelegate implement

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.productList = response.products;
}

#pragma mark - lazy init

- (NSArray *)productList {
    if (!_productList) {
        _productList = [NSArray array];
    }
    return _productList;
}

@end
