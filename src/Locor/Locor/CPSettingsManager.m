//
//  CPSettingsManager.m
//  Locor
//
//  Created by wangyw on 9/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSettingsManager.h"

#import "CPLocorConfig.h"

#import "CPBarButtonManager.h"

#import "CPAppearanceManager.h"

@interface CPSettingsManager ()

@property (weak, nonatomic) id<CPSettingsManagerDelegate> delegate;

@property (weak, nonatomic) UIView *superView;

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@property (strong, nonatomic) UIView *buttonList;
@property (strong, nonatomic) NSArray *buttonListConstraints;

@end

@implementation CPSettingsManager

#pragma mark - public methods

- (id)initWithSuperview:(UIView *)superview andDelegate:(id<CPSettingsManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.superView = superview;
    }
    return self;
}

- (void)loadViews {
    NSAssert(self.superView, @"");
    
    [CPBarButtonManager pushBarButtonStateWithTitle:@"X" target:self action:@selector(unloadViews) andControlEvents:UIControlEventTouchUpInside];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unloadViews)];
    [self.superView addGestureRecognizer:self.tapGesture];
    
    self.superView.alpha = 0.0;
    self.superView.backgroundColor = [UIColor blackColor];
    
    self.buttonList = [[UIView alloc] init];
    self.buttonList.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superView addSubview:self.buttonList];
    
    self.buttonListConstraints = [CPAppearanceManager constraintsWithView:self.buttonList alignToView:self.superView attribute:NSLayoutAttributeTop, NSLayoutAttributeBottom, NSLayoutAttributeRight, ATTR_END];
    [self.superView addConstraints:self.buttonListConstraints];
    
    [self.buttonList addConstraint:[CPAppearanceManager constraintWithView:self.buttonList width:BAR_HEIGHT]];
    
    [CPAppearanceManager animateWithDuration:0.5 animations:^{
        self.superView.alpha = 0.9;
    }];
}

- (void)unloadViews {
    [CPBarButtonManager popBarButtonState];
    
    [self.superView removeGestureRecognizer:self.tapGesture];
    
    [self.superView removeConstraints:self.buttonListConstraints];
    [self.buttonList removeFromSuperview];
    
    [CPAppearanceManager animateWithDuration:0.5 animations:^{
        self.superView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.delegate settingsManagerClosed];
    }];
}

@end
