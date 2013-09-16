//
//  CPSettingsManager.m
//  Locor
//
//  Created by wangyw on 9/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSettingsManager.h"

#import "CPHelperMacros.h"
#import "CPLocorConfig.h"

#import "CPBarButtonManager.h"

#import "CPAppearanceManager.h"

#import "CPProcessManager.h"
#import "CPSettingsProcess.h"

static const int BUTTON_COUNT = 3;
static const float BUTTON_ANIMATION_TIME_STEP = 0.1, BUTTON_ANIMATION_BOUNCE_MULTIPLIER = 2.0;
static const char *NAMES[] = {"H", "M", "P"}, *SELECTORS[] = {"pressedHelp", "pressedMainPassword", "pressedPurchase"};

@interface CPSettingsManager ()

@property (weak, nonatomic) id<CPSettingsManagerDelegate, CPSettingsManagerBarButtonAccessProtocol> delegate;

@property (weak, nonatomic) UIView *superView;

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@property (strong, nonatomic) UIView *buttonContainer;
//@property (strong, nonatomic) NSArray *buttonContainerConstraints;
//@property (strong, nonatomic) NSArray *buttonContainerToBarButtonConstraints;

@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSMutableArray *buttonTopConstraints;

@end

@implementation CPSettingsManager

#pragma mark - public methods

- (id)initWithSuperview:(UIView *)superview andDelegate:(id<CPSettingsManagerDelegate, CPSettingsManagerBarButtonAccessProtocol>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.superView = superview;
    }
    return self;
}

- (void)loadViews {
    NSAssert(self.superView, @"Settings manager superview not specified!");
    
    [CPProcessManager startProcess:SETTINGS_PROCESS withPreparation:^{
        [CPBarButtonManager pushBarButtonStateWithTitle:@"X" target:self action:@selector(unloadViews) andControlEvents:UIControlEventTouchUpInside];
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unloadViews)];
        [self.superView addGestureRecognizer:self.tapGesture];
        
        self.superView.alpha = 0.0;
        self.superView.backgroundColor = [UIColor blackColor];
        
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            self.superView.alpha = 0.9;
        }];
        
        self.buttonContainer = [[UIView alloc] init];
        self.buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.superView addSubview:self.buttonContainer];
        
        [self.superView addConstraints:[CPAppearanceManager constraintsWithView:self.buttonContainer alignToView:self.superView attribute:NSLayoutAttributeTop, NSLayoutAttributeBottom, ATTR_END]];
        [self.delegate.barButtonSuperview addConstraints:[CPAppearanceManager constraintsWithView:self.buttonContainer alignToView:self.delegate.barButton attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
        
        self.buttons = [NSMutableArray array];
        self.buttonTopConstraints = [NSMutableArray array];
        
        for (int i = 0; i < BUTTON_COUNT; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:CSTR_TO_OBJC(NAMES[i]) forState:UIControlStateNormal];
            [button addTarget:self action:NSSelectorFromString(CSTR_TO_OBJC(SELECTORS[i])) forControlEvents:UIControlEventTouchUpInside];
            
            [self.buttons addObject:button];
            [self.buttonContainer addSubview:button];
            
            [self.buttonContainer addConstraints:[CPAppearanceManager constraintsWithView:button alignToView:self.buttonContainer attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
            
            [button addConstraint:[CPAppearanceManager constraintWithView:button height:BAR_HEIGHT]];
            
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.buttonContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:-BOX_SEPARATOR_SIZE];
            [self.buttonContainer addConstraint:topConstraint];
            [self.buttonTopConstraints addObject:topConstraint];
        }
        
        [self.superView layoutIfNeeded];
        
        [self.buttonContainer removeConstraints:self.buttonTopConstraints];
        self.buttonTopConstraints = [NSMutableArray array];
        for (int i = 0; i < BUTTON_COUNT; i++) {
            UIButton *button = [self.buttons objectAtIndex:i];
            __block NSLayoutConstraint *topConstraint;
            [CPAppearanceManager animateWithDuration:(BUTTON_COUNT - i) * BUTTON_ANIMATION_TIME_STEP delay:i * BUTTON_ANIMATION_TIME_STEP + 0.3 options:0 preparation:^{
                if (i) {
                    topConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self.buttons objectAtIndex:i - 1] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE];
                } else {
                    topConstraint = [CPAppearanceManager constraintWithView:button alignToView:self.buttonContainer attribute:NSLayoutAttributeTop];
                }
                [self.buttonContainer addConstraint:topConstraint];
                [self.buttonTopConstraints addObject:topConstraint];
            } animations:^{
                [self.buttonContainer layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (i == BUTTON_COUNT - 1) {
                    for (NSLayoutConstraint *constraint in self.buttonTopConstraints) {
                        constraint.constant += BOX_SEPARATOR_SIZE * (BUTTON_ANIMATION_BOUNCE_MULTIPLIER - 1);
                    }
                    [CPAppearanceManager animateWithDuration:0.2 animations:^{
                        [self.buttonContainer layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        for (NSLayoutConstraint *constraint in self.buttonTopConstraints) {
                            constraint.constant -= BOX_SEPARATOR_SIZE * (BUTTON_ANIMATION_BOUNCE_MULTIPLIER - 1);
                        }
                        [CPAppearanceManager animateWithDuration:0.2 animations:^{
                            [self.buttonContainer layoutIfNeeded];
                        }];
                    }];
                }
            }];
        }
    }];
}

- (void)unloadViews {
    [CPProcessManager stopProcess:SETTINGS_PROCESS withPreparation:^{
        [CPBarButtonManager popBarButtonState];
        
        [self.superView removeGestureRecognizer:self.tapGesture];
        
        [self.buttonContainer removeConstraints:self.buttonTopConstraints];
        
        for (int i = 0; i < BUTTON_COUNT; i++) {
            UIButton *button = [self.buttons objectAtIndex:i];
            [CPAppearanceManager animateWithDuration:(i + 1) * BUTTON_ANIMATION_TIME_STEP animations:^{
                [self.buttonContainer addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.buttonContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
                [self.buttonContainer layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (i == BUTTON_COUNT - 1) {
                    [self.buttonContainer removeFromSuperview];
                }
            }];
        }
        
        [CPAppearanceManager animateWithDuration:0.5 delay:BUTTON_COUNT * BUTTON_ANIMATION_TIME_STEP - 0.2 options:0 animations:^{
            self.superView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.delegate settingsManagerClosed];
        }];
    }];
}

#pragma mark - Button Targets

- (void)pressedHelp {
    NSLog(@"HELP!");
}

- (void)pressedMainPassword {
    NSLog(@"MAIN PASSWORD!");
}

- (void)pressedPurchase {
    NSLog(@"PURCHASE!");
}

@end
