//
//  CPSettingsManager.h
//  Locor
//
//  Created by wangyw on 9/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@protocol CPSettingsManagerDelegate <NSObject>

- (void)settingsManagerClosed;

@end

@interface CPSettingsManager : NSObject

- (id)initWithSuperview:(UIView *)superview andDelegate:(id<CPSettingsManagerDelegate>)delegate;

- (void)loadViews;

@end
