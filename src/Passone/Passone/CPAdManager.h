//
//  CPAdManager.h
//  Passone
//
//  Created by wangsw on 8/21/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <iAd/iAd.h>

@interface CPAdManager : NSObject <ADBannerViewDelegate>

- (id)initWithSuperview:(UIView *)superview;

@end
