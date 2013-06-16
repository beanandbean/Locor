//
//  CPMainViewController.m
//  Passone
//
//  Created by wangyw on 6/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewController.h"

#import "CPPassGridManager.h"

@interface CPMainViewController ()

@property (strong, nonatomic) CPPassGridManager *passGridManager;

@end

@implementation CPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.passGridManager = [[CPPassGridManager alloc] initWithSuperView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
