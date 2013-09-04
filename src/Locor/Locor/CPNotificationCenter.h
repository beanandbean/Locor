//
//  CPNotificationCenter.h
//  Locor
//
//  Created by wangsw on 6/28/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPNotificationCenter : NSObject

+ (void)createNotificationCenterWithSuperView:(UIView *)superView;

+ (void)insertNotification:(NSString *)notification;

@end
