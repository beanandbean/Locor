//
//  CPPassEditViewManager.m
//  Passone
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditViewManager.h"

@interface CPPassEditViewManager ()

@property (strong, nonatomic) NSLayoutConstraint *passwordEditViewLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *passwordEditViewTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *passwordEditViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *passwordEditViewHeightConstraint;

@end

@implementation CPPassEditViewManager

- (UIView *)passwordEditView {
    if (!_passwordEditView) {
        [[NSBundle mainBundle] loadNibNamed:@"CPPassEditView" owner:self options:nil];
        _passwordEditView.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordEditView.backgroundColor = [UIColor blueColor];
    }
    return _passwordEditView;
}

- (void)addPassEditViewInView:(UIView *)view forCell:(UIView *)cell inCells:(NSMutableArray *)cells {
    [view addSubview:self.passwordEditView];    
    
    [self.passwordEditView removeConstraint:self.passwordEditViewLeftConstraint];
    [self.passwordEditView removeConstraint:self.passwordEditViewTopConstraint];
    [self.passwordEditView removeConstraint:self.passwordEditViewWidthConstraint];
    [self.passwordEditView removeConstraint:self.passwordEditViewHeightConstraint];
    
    self.passwordEditViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    [view addConstraint:self.passwordEditViewLeftConstraint];
    self.passwordEditViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [view addConstraint:self.passwordEditViewTopConstraint];
    self.passwordEditViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [view addConstraint:self.passwordEditViewWidthConstraint];
    self.passwordEditViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [view addConstraint:self.passwordEditViewHeightConstraint];
    [view layoutIfNeeded];
    
    self.passwordEditViewWidthConstraint.constant = 100;
    [UIView animateWithDuration:0.5 animations:^{
        [view layoutIfNeeded];
    }];
}

@end
