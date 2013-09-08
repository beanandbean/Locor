//
//  CPMainViewController.m
//  Locor
//
//  Created by wangyw on 6/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewController.h"

#import "CPRootManager.h"

#define DEVICE_ROTATE_OBSERVERS [CPMainViewController deviceRotateObservers]

static NSMutableArray *deviceRotateObservers;

@interface CPMainViewController ()

@property (strong, nonatomic) CPRootManager *rootManager;

@end

@implementation CPMainViewController

+ (NSMutableArray *)deviceRotateObservers {
    if (!deviceRotateObservers) {
        deviceRotateObservers = [NSMutableArray array];
    }
    return deviceRotateObservers;
}

#pragma mark - public methods

+ (void)registerDeviceRotateObserver:(id<CPDeviceRotateObserver>)observer {
    if ([DEVICE_ROTATE_OBSERVERS indexOfObject:observer] == NSNotFound) {
        [DEVICE_ROTATE_OBSERVERS addObject:observer];
    }
}

+ (void)removeDeviceRotateObserver:(id<CPDeviceRotateObserver>)observer {
    if ([DEVICE_ROTATE_OBSERVERS indexOfObject:observer] != NSNotFound) {
        [DEVICE_ROTATE_OBSERVERS removeObject:observer];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.rootManager loadAnimated:NO];
            
    // Not using main password while testing other parts of app.
    // self.mainPasswordManager = [[CPMainPasswordManager alloc] initWithSuperview:self.view];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    for (id<CPDeviceRotateObserver> observer in DEVICE_ROTATE_OBSERVERS) {
        [observer deviceWillRotateToOrientation:toInterfaceOrientation];
    }
}

#pragma mark - lazy init

- (CPRootManager *)rootManager {
    if (!_rootManager) {
        _rootManager = [[CPRootManager alloc] initWithSupermanager:nil andSuperview:self.view];
    }
    return _rootManager;
}

@end
