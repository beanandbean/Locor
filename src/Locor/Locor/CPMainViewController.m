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
            
    // Not using main password while testing other parts of app.
    // self.mainPasswordManager = [[CPMainPasswordManager alloc] initWithSuperview:self.view];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - lazy init

- (CPRootManager *)rootManager {
    if (!_rootManager) {
        _rootManager = [[CPRootManager alloc] initWithSupermanager:nil andSuperview:self.view];
    }
    return _rootManager;
}

@end
