//
//  CPMainViewController.m
//  Passone
//
//  Created by wangyw on 6/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewController.h"

#import "CPMainPasswordManager.h"

#import "CPPassGridManager.h"
#import "CPSearchViewManager.h"

#import "CPNotificationCenter.h"
#import "CPAppearanceManager.h"

#import "CPProcessManager.h"

@interface CPMainViewController ()

@property (strong, nonatomic) CPMainPasswordManager *mainPasswordManager;
@property (strong, nonatomic) CPPassGridManager *passGridManager;
@property (strong, nonatomic) CPSearchViewManager *searchViewManager;

@end

@implementation CPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainPasswordManager = [[CPMainPasswordManager alloc] initWithSuperview:self.view];
    
    /*[CPProcessManager increaseForbiddenCount];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [CPNotificationCenter createNotificationCenterWithSuperView:self.view];

    self.passGridManager = [[CPPassGridManager alloc] initWithSuperView:contentView];
    
    self.searchViewManager = [[CPSearchViewManager alloc] initWithSuperView:self.view];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchViewManager.searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
    [self.view addSubview:contentView];
    
    [CPProcessManager decreaseForbiddenCount];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
