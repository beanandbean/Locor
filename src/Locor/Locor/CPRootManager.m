//
//  CPRootManager.m
//  Locor
//
//  Created by wangyw on 9/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRootManager.h"

#import "CPAppearanceManager.h"
#import "CPUserDefaultManager.h"

#import "CPHelpManager.h"
#import "CPMainViewManager.h"
#import "CPMainPassManager.h"

@interface CPRootManager ()

@property (strong, nonatomic) CPHelpManager *helpManager;
@property (strong, nonatomic) CPMainViewManager *mainViewManager;

@property (strong, nonatomic) CPMainPassManager *mainPassManager;

@property (strong, nonatomic) UIView *helpView;
@property (strong, nonatomic) UIView *mainPassView;
 
@end

@implementation CPRootManager

- (void)loadAnimated:(BOOL)animated {
    [super loadAnimated:animated];
    
    if ([CPUserDefaultManager isFirstRunning]) {
        [self.superview addSubview:self.helpView];
        [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.helpView edgesAlignToView:self.superview]];
        [self.helpManager loadAnimated:animated];
        
        [CPUserDefaultManager setFirstRuning:NO];
    } else {
        [self loadMainPassManager];
    }
}

- (void)submanagerDidUnload:(CPViewManager *)submanager {
    if (submanager == self.helpManager) {
        [self loadMainPassManager];
        [self.superview bringSubviewToFront:self.helpView];
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            self.helpView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.helpView removeFromSuperview];
            self.helpView = nil;
            self.helpManager = nil;
        }];
    } else if (submanager == self.mainPassManager) {
        [self.mainViewManager loadAnimated:NO];
        [self.superview bringSubviewToFront:self.mainPassView];
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            self.mainPassView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.mainPassView removeFromSuperview];
            self.mainPassView = nil;
            self.mainPassManager = nil;
        }];
    }
}

- (void)loadMainPassManager {
    [self.superview addSubview:self.mainPassView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.mainPassView edgesAlignToView:self.superview]];
    [self.mainPassManager loadAnimated:YES];
}

#pragma mark - lazy init

- (CPHelpManager *)helpManager {
    if (!_helpManager) {
        _helpManager = [[CPHelpManager alloc] initWithSupermanager:self andSuperview:self.helpView];
    }
    return _helpManager;
}

- (CPMainViewManager *)mainViewManager {
    if (!_mainViewManager) {
        _mainViewManager = [[CPMainViewManager alloc] initWithSupermanager:self andSuperview:self.superview];
    }
    return _mainViewManager;
}

- (CPMainPassManager *)mainPassManager {
    if (!_mainPassManager) {
        _mainPassManager = [[CPMainPassManager alloc] initWithSupermanager:self andSuperview:self.mainPassView];
    }
    return _mainPassManager;
}

- (UIView *)helpView {
    if (!_helpView) {
        _helpView = [[UIView alloc] init];
        _helpView.backgroundColor = [UIColor blackColor];
        _helpView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _helpView;
}

- (UIView *)mainPassView {
    if (!_mainPassView) {
        _mainPassView = [[UIView alloc] init];
        _mainPassView.backgroundColor = [UIColor blackColor];
        _mainPassView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _mainPassView;
}

@end
