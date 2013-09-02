//
//  CPSettingsManager.m
//  Passone
//
//  Created by wangyw on 9/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSettingsManager.h"

@interface CPSettingsManager ()

@property (weak, nonatomic) UIView *superView;

@property (strong, nonatomic) UIView *buttonsView;

- (void)helpButtonTouched:(id)sender;

@end

@implementation CPSettingsManager

#pragma mark - public methods

- (id)initWithSuperview:(UIView *)superview {
    self = [super init];
    if (self) {
        self.superView = superview;
    }
    return self;
}

- (void)loadViews {
    NSAssert(self.superView, @"");
    NSAssert(!self.buttonsView, @"");
    
    self.buttonsView = [[UIView alloc] init];
    self.buttonsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.buttonsView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    helpButton.translatesAutoresizingMaskIntoConstraints = NO;
    helpButton.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    [helpButton setTitle:@"H" forState:UIControlStateNormal];
    [helpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(helpButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonsView addSubview:helpButton];
    [self.superView addSubview:self.buttonsView];
    
    [self.buttonsView addConstraint:[NSLayoutConstraint constraintWithItem:helpButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.buttonsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.buttonsView addConstraint:[NSLayoutConstraint constraintWithItem:helpButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.buttonsView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.buttonsView addConstraint:[NSLayoutConstraint constraintWithItem:helpButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0]];
    [self.buttonsView addConstraint:[NSLayoutConstraint constraintWithItem:helpButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0]];
    
    [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200.0]];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 1.0;
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.buttonsView.layer addAnimation:animation forKey:@""];
}

- (void)unloadViews {
    NSAssert(self.buttonsView, @"");
    [self.buttonsView removeFromSuperview];
    self.buttonsView = nil;
}

- (void)helpButtonTouched:(id)sender {
    [self unloadViews];
}

@end
