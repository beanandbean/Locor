//
//  CPAdManager.h
//  Locor
//
//  Created by wangsw on 8/21/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <iAd/iAd.h>

#import "CPViewManager.h"

@protocol CPAdResizingObserver <NSObject>

- (void)adResizingDidAffectContent;

@end

@interface CPAdManager : CPViewManager <ADBannerViewDelegate>

+ (void)registerAdResizingObserver:(id<CPAdResizingObserver>)observer;
+ (void)removeAdResizingObserver:(id<CPAdResizingObserver>)observer;


@end
