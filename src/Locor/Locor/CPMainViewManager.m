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
#import "CPTopBarManager.h"

#import "CPNotificationCenter.h"

@interface CPMainViewManager ()

@property (strong, nonatomic) CPPassGridManager *passGridManager;
@property (strong, nonatomic) CPTopBarManager *topBarManager;
@property (strong, nonatomic) CPNotificationCenter *notificationCenter;
@property (strong, nonatomic) CPAdManager *adManager;

@property (strong, nonatomic) UIView *outerView;
@property (strong, nonatomic) UIView *statusBarView;
@property (strong, nonatomic) UIView *adView;
@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) UIView *contentView;

@end

@implementation CPMainViewManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.outerView];
    [self.superview addSubview:self.statusBarView];
    [self.superview addSubview:self.adView];
    [self.outerView addSubview:self.mainView];
    [self.mainView addSubview:self.contentView];
    
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.statusBarView alignToView:self.superview attribute:NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.statusBarView height:20.0]];
    
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.adView alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom, ATTR_END]];
    
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.outerView attribute:NSLayoutAttributeTop alignToView:self.statusBarView attribute:NSLayoutAttributeBottom]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.outerView attribute:NSLayoutAttributeBottom alignToView:self.adView attribute:NSLayoutAttributeTop]];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.outerView alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    
    [self.outerView addConstraints:[CPAppearanceManager constraintsWithView:self.mainView edgesAlignToView:self.outerView]];
    
    [self.passGridManager loadAnimated:NO];
    // topBarAndSearchManager must init after passGridManager
    [self.topBarManager loadAnimated:NO];
    [self.notificationCenter loadAnimated:NO];
    [self.adManager loadAnimated:NO];
    
    [self.mainView addConstraint:[CPAppearanceManager constraintWithView:self.contentView attribute:NSLayoutAttributeTop alignToView:self.topBarManager.topBar attribute:NSLayoutAttributeBottom]];
    [self.mainView addConstraints:[CPAppearanceManager constraintsWithView:self.contentView alignToView:self.mainView attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom]];
}

#pragma mark - lazy init

- (CPPassGridManager *)passGridManager {
    if (!_passGridManager) {
        _passGridManager = [[CPPassGridManager alloc] initWithSupermanager:self andSuperview:self.contentView];
    }
    return _passGridManager;
}

- (CPTopBarManager *)topBarManager {
    if (!_topBarManager) {
        _topBarManager = [[CPTopBarManager alloc] initWithSupermanager:self andSuperview:self.mainView];
    }
    return _topBarManager;
}

- (CPNotificationCenter *)notificationCenter {
    if (!_notificationCenter) {
        _notificationCenter = [[CPNotificationCenter alloc] initWithSupermanager:self andSuperview:self.outerView];
    }
    return _notificationCenter;
}

- (CPAdManager *)adManager {
    if (!_adManager) {
        _adManager = [[CPAdManager alloc] initWithSupermanager:self andSuperview:self.adView];
    }
    return _adManager;
}

- (UIView *)outerView {
    if (!_outerView) {
        _outerView = [[UIView alloc] init];
        _outerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _outerView;
}

- (UIView *)statusBarView {
    if (!_statusBarView) {
        _statusBarView = [[UIView alloc] init];
        _statusBarView.translatesAutoresizingMaskIntoConstraints = NO;
        _statusBarView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    }
    return _statusBarView;
}

- (UIView *)adView {
    if (!_adView) {
        _adView = [[UIView alloc] init];
        _adView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _adView;
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] init];
        _mainView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _mainView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentView;
}

@end
