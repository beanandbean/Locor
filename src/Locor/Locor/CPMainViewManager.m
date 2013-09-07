//
//  CPMainViewManager.m
//  Locor
//
//  Created by wangyw on 9/6/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewManager.h"

#import "CPAppearanceManager.h"

#import "CPAdManager.h"
#import "CPPassGridManager.h"
#import "CPTopBarAndSearchManager.h"

#import "CPNotificationCenter.h"

@interface CPMainViewManager ()

@property (strong, nonatomic) CPAdManager *adManager;
@property (strong, nonatomic) CPPassGridManager *passGridManager;
@property (strong, nonatomic) CPTopBarAndSearchManager *topBarAndSearchManager;

@end

@implementation CPMainViewManager

- (void)loadAnimated:(BOOL)animated {
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:contentView];

    UIView *adView = [[UIView alloc] init];
    adView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:adView];
    
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:contentView attribute:NSLayoutAttributeBottom alignToView:adView attribute:NSLayoutAttributeTop]];
    
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:contentView alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeTop, ATTR_END]];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:adView alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom, ATTR_END]];
    
    UIView *passGridView = [[UIView alloc] init];
    passGridView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:passGridView];
    
    [CPNotificationCenter createNotificationCenterWithSuperView:contentView];
    
    self.passGridManager = [[CPPassGridManager alloc] initWithSuperView:passGridView];
    
    self.topBarAndSearchManager = [[CPTopBarAndSearchManager alloc] initWithSuperView:contentView];
    
    self.adManager = [[CPAdManager alloc] initWithSuperview:adView];
    
    [contentView addConstraint:[CPAppearanceManager constraintWithView:passGridView attribute:NSLayoutAttributeTop alignToView:self.topBarAndSearchManager.searchBar attribute:NSLayoutAttributeTop]];
    
    [contentView addConstraints:[CPAppearanceManager constraintsWithView:passGridView alignToView:contentView attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom]];
}

@end
