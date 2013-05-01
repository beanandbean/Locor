//
//  CPLoginViewController.m
//  Passone
//
//  Created by wangyw on 4/30/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPLoginViewController.h"
#import "CPLoginView.h"

@interface CPLoginViewController ()

@end

@implementation CPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    CPLoginView *loginView1 = [[CPLoginView alloc] init];
    [self.view addSubview:loginView1];
    CPLoginView *loginView2 = [[CPLoginView alloc] init];
    [self.view addSubview:loginView2];
    CPLoginView *loginView3 = [[CPLoginView alloc] init];
    [self.view addSubview:loginView3];
    CPLoginView *loginView4 = [[CPLoginView alloc] init];
    [self.view addSubview:loginView4];
    float centerX = self.view.center.x, centerY = self.view.center.y;
    loginView1.center = CGPointMake(centerX - 110, centerY - 110);
    loginView2.center = CGPointMake(centerX + 110, centerY - 110);
    loginView3.center = CGPointMake(centerX - 110, centerY + 110);
    loginView4.center = CGPointMake(centerX + 110, centerY + 110);
    /*[self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginView1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginView1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginView2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:-110]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginView2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:110]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginView3 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:110]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginView3 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:-110]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginView4 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:110]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginView4 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:110]];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
