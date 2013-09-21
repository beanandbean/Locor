//
//  CPIAPHelper.m
//  Locor
//
//  Created by wangyw on 9/20/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPIAPHelper.h"

#import "CPUserDefaultManager.h"

const NSString * const CPProductNameRemoveAd = @"codingpotato.Locor.RemoveAd";

@interface CPIAPHelper ()

@end

@implementation CPIAPHelper

- (id)init {
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)requstProducts {
    if ([SKPaymentQueue canMakePayments]) {
        SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:CPProductNameRemoveAd, nil]];
        productRequest.delegate = self;
        [productRequest start];
    }
}

- (void)buyProduct:(SKProduct *)product {
    if ([SKPaymentQueue canMakePayments]) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)restoreProducts {
    if ([SKPaymentQueue canMakePayments]) {
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

#pragma mark - SKPaymentTransactionObserver implement

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStatePurchased:
                [CPUserDefaultManager setProduct:transaction.payment.productIdentifier purchased:YES];
                [self.delegate helper:self didPurchaseProduct:transaction.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [CPUserDefaultManager setProduct:transaction.payment.productIdentifier purchased:YES];
                [self.delegate helper:self didRestoreProduct:transaction.payment.productIdentifier];
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
    [self.delegate helper:self didReceiveProducts:response.products];
}

@end
