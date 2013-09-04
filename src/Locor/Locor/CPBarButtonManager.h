//
//  CPBarButtonManager.h
//  Locor
//
//  Created by wangsw on 9/4/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPBarButtonManager : NSObject

+ (void)initializeWithBarButton:(UIButton *)button;

+ (void)pushBarButtonStateWithTitle:(NSString *)title target:(id)target action:(SEL)action andControlEvents:(UIControlEvents)controlEvents;
+ (void)popBarButtonState;

@end
