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
    
    [self.superview addConstraints:[NSArray arrayWithObjects:
                                    [CPAppearanceManager constraintWithView:contentView attribute:NSLayoutAttributeTop alignToView:self.superview],
                                    [CPAppearanceManager constraintWithView:contentView attribute:NSLayoutAttributeLeft alignToView:self.superview],
                                    [CPAppearanceManager constraintWithView:contentView attribute:NSLayoutAttributeRight alignToView:self.superview],
                                    
                                    [CPAppearanceManager constraintWithView:adView attribute:NSLayoutAttributeLeft alignToView:self.superview],
                                    [CPAppearanceManager constraintWithView:adView attribute:NSLayoutAttributeRight alignToView:self.superview],
                                    [CPAppearanceManager constraintWithView:adView attribute:NSLayoutAttributeBottom alignToView:self.superview],
                                    
                                    [CPAppearanceManager constraintWithView:contentView attribute:NSLayoutAttributeBottom alignToView:adView attribute:NSLayoutAttributeTop],
                                    nil]];
    
    UIView *passGridView = [[UIView alloc] init];
    passGridView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:passGridView];
    
    [CPNotificationCenter createNotificationCenterWithSuperView:contentView];
    
    self.passGridManager = [[CPPassGridManager alloc] initWithSuperView:passGridView];
    
    self.topBarAndSearchManager = [[CPTopBarAndSearchManager alloc] initWithSuperView:contentView];
    
    self.adManager = [[CPAdManager alloc] initWithSuperview:adView];
    
    [contentView addConstraints:[NSArray arrayWithObjects:
                                 [CPAppearanceManager constraintWithView:passGridView attribute:NSLayoutAttributeTop alignToView:self.topBarAndSearchManager.searchBar attribute:NSLayoutAttributeTop],
                                 [CPAppearanceManager constraintWithView:passGridView attribute:NSLayoutAttributeLeft alignToView:contentView],
                                 [CPAppearanceManager constraintWithView:passGridView attribute:NSLayoutAttributeRight alignToView:contentView],
                                 [CPAppearanceManager constraintWithView:passGridView attribute:NSLayoutAttributeBottom alignToView:contentView],
                                 nil]];
}

@end
