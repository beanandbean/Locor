//
//  CPNotificationCenter.h
//  Passone
//
//  Created by wangsw on 6/28/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPNotificationCenter : NSObject

+ (void)createNotificationCenterWithSuperView:(UIView *)superView labelLeft:(UIView *)left andLabelRight:(UIView *)right;

+ (void)insertNotification:(NSString *)notification;

@end
