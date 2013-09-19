//
//  CPMainViewController.m
//  Locor
//
//  Created by wangyw on 6/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewController.h"

#import "CPRootManager.h"

@interface CPMainViewController ()

@property (strong, nonatomic) CPRootManager *rootManager;

@end

@implementation CPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.rootManager loadAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [[NSNotificationCenter defaultCenter] postNotificationName:CPDeviceOrientationWillChangeNotification object:nil];
}

#pragma mark - lazy init

- (CPRootManager *)rootManager {
    if (!_rootManager) {
        _rootManager = [[CPRootManager alloc] initWithSupermanager:nil andSuperview:self.view];
    }
    return _rootManager;
}

@end
