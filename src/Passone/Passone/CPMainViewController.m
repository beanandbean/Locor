//
//  CPMainViewController.m
//  Passone
//
//  Created by wangyw on 6/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewController.h"

#import "CPPassGridManager.h"
#import "CPSearchViewManager.h"

#import "CPNotificationCenter.h"

@interface CPMainViewController ()

@property (strong, nonatomic) CPPassGridManager *passGridManager;
@property (strong, nonatomic) CPSearchViewManager *searchViewManager;

@end

@implementation CPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    searchBar.backgroundImage = [[UIImage alloc] init];
    
    UIGraphicsBeginImageContext(CGSizeMake(15.0, 34.0));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, 15.0, 34.0));
    UIImage *bg = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    UIGraphicsEndImageContext();
    
    [searchBar setSearchFieldBackgroundImage:bg forState:UIControlStateNormal];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:5.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-5.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0]];
    [self.view addSubview:searchBar];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
    [self.view addSubview:contentView];

    self.passGridManager = [[CPPassGridManager alloc] initWithSuperView:contentView];
    self.searchViewManager = [[CPSearchViewManager alloc] initWithSearchBar:searchBar superView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
