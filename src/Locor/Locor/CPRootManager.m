//
//  CPRootManager.m
//  Locor
//
//  Created by wangyw on 9/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRootManager.h"

#import "CPAppearanceManager.h"

#import "CPHelpManager.h"
#import "CPMainViewManager.h"

@interface CPRootManager ()

@property (strong, nonatomic) CPHelpManager *helpManager;
@property (strong, nonatomic) CPMainViewManager *mainViewManager;

//@property (strong, nonatomic) CPMainPasswordManager *mainPasswordManager;

@property (strong, nonatomic) UIView *helpView;
 
@end

@implementation CPRootManager

- (void)loadAnimated:(BOOL)animated {
    [super loadAnimated:animated];
    
    [self.superview addSubview:self.helpView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.helpView edgesAlignToView:self.superview]];
    [self.helpManager loadAnimated:animated];
}

- (void)submanagerDidUnload:(CPViewManager *)submanager {
    if (submanager == self.helpManager) {
        [self.mainViewManager loadAnimated:NO];
        [self.superview bringSubviewToFront:self.helpView];
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            self.helpView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.helpView removeFromSuperview];
            self.helpView = nil;
            self.helpManager = nil;
        }];
    }
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

- (UIView *)helpView {
    if (!_helpView) {
        _helpView = [[UIView alloc] init];
        _helpView.backgroundColor = [UIColor blackColor];
        _helpView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _helpView;
}

@end
