//
//  CPMainViewController.h
//  Locor
//
//  Created by wangyw on 6/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@protocol CPDeviceRotateObserver <NSObject>

- (void)deviceWillRotateToOrientation:(UIInterfaceOrientation)orientation;

@end

@interface CPMainViewController : UIViewController

+ (void)registerDeviceRotateObserver:(id<CPDeviceRotateObserver>)observer;
+ (void)removeDeviceRotateObserver:(id<CPDeviceRotateObserver>)observer;

@end
