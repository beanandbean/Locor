//
//  CPAdManager.h
//  Locor
//
//  Created by wangsw on 8/21/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <iAd/iAd.h>

#import "CPViewManager.h"

// This variable is used in several files so it had better be defined in a header file. However, it is not used here.
static NSString *CPAdResizingDidAffectContentNotification = @"CP_Ad_Resizing_Did_Affect_Content_Notification";

@interface CPAdManager : CPViewManager <ADBannerViewDelegate>

@end
