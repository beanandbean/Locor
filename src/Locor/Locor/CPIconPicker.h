//
//  CPIconPicker.h
//  Locor
//
//  Created by wangsw on 9/6/13.
//  Copyright (c) 2013 beanandbean. All rights reserved.
//

#import "CPMainViewController.h"

@protocol CPIconPickerDelegate <NSObject>

- (void)iconSelected:(NSString *)iconName;

@end

@interface CPIconPicker : UIView <CPDeviceRotateObserver>

- (id)initWithDelegate:(id<CPIconPickerDelegate>)delegate;

- (void)setStartIcon:(NSString *)iconName;

- (void)setEnabled:(BOOL)enabled;

@end
