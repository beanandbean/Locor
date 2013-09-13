//
//  CPSettingsManager.h
//  Locor
//
//  Created by wangyw on 9/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

// CPSettingsManagerDelegate protocol can be removed when CPSettingsManager become subclass of CPViewManger, as you can call submanagerDidUnload instead of settingsManagerClosed, but CPSettingsManagerBarButtonAccessProtocol cannot be removed.
@protocol CPSettingsManagerDelegate <NSObject>

- (void)settingsManagerClosed;

@end

@protocol CPSettingsManagerBarButtonAccessProtocol <NSObject>

- (UIButton *)barButton;
- (UIView *)barButtonSuperview;

@end

@interface CPSettingsManager : NSObject

- (id)initWithSuperview:(UIView *)superview andDelegate:(id<CPSettingsManagerDelegate, CPSettingsManagerBarButtonAccessProtocol>)delegate;

- (void)loadViews;

@end
