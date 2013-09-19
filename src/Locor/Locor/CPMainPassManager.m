//
//  CPMainPassManager.m
//  Locor
//
//  Created by wangsw on 8/15/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CPMainPassManager.h"

#import "CPMainPasswordCanvas.h"

#import "CPAppearanceManager.h"
#import "CPLocorConfig.h"
#import "CPNotificationCenter.h"
#import "CPUserDefaultManager.h"

typedef enum {
    CPMainPasswordStateSetting,
    CPMainPasswordStateConfirming,
    CPMainPasswordStateChecking
} CPMainPasswordState;

typedef enum {
    CPMainPasswordCanvasLastPointStateMouse,
    CPMainPasswordCanvasLastPointStatePassPoint
} CPMainPasswordCanvasLastPointState;

@interface CPMainPassManager ()

@property (nonatomic) CPMainPasswordState state;

@property (strong, nonatomic) UIView *outerView;

@property (strong, nonatomic) CPMainPasswordCanvas *pointsContainer;

@property (strong, nonatomic) UILabel *stateLabel;
@property (strong, nonatomic) UIButton *redrawButton;

@property (strong, nonatomic) NSArray *passwordPointViews;

@property (strong, nonatomic) NSArray *passwords;
@property (strong, nonatomic) NSMutableArray *panningPoints;

@property (nonatomic) CPMainPasswordCanvasLastPointState lastPointState;

@end

@implementation CPMainPassManager

+ (BOOL)passwordPointWithCenter:(CGPoint)passCenter containsCGPoint:(CGPoint)point {
    return sqrtf((passCenter.x - point.x) * (passCenter.x - point.x) + (passCenter.y - point.y) * (passCenter.y - point.y)) < MAIN_PASSWORD_POINT_SIZE / 2;
}

+ (BOOL)intArray:(NSArray *)array1 isEqualToArray:(NSArray *)array2 {
    if (array1.count == array2.count) {
        for (int i = 0; i < array1.count; i++) {
            if (((NSNumber *)[array1 objectAtIndex:i]).intValue != ((NSNumber *)[array2 objectAtIndex:i]).intValue) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

+ (void)addPoint:(CGPoint)point toPointArray:(NSMutableArray *)array atState:(CPMainPasswordCanvasLastPointState)state {
    switch (state) {
        case CPMainPasswordCanvasLastPointStateMouse:
            [array replaceObjectAtIndex:array.count - 1 withObject:[NSValue valueWithCGPoint:point]];
            break;
        
        case CPMainPasswordCanvasLastPointStatePassPoint:
            [array addObject:[NSValue valueWithCGPoint:point]];
            break;
            
        default:
            NSAssert(NO, @"Unknown main password canvas last point state!");
            break;
    }
}

- (void)loadAnimated:(BOOL)animated {
    if ([CPUserDefaultManager mainPass].count) {
        self.state = CPMainPasswordStateChecking;
    } else {
        self.state = CPMainPasswordStateSetting;
    }
    
    self.outerView = [[UIView alloc] init];
    self.outerView.backgroundColor = [UIColor whiteColor];
    self.outerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.superview addSubview:self.outerView];
    
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.outerView edgesAlignToView:self.superview]];
    
    self.pointsContainer = [[CPMainPasswordCanvas alloc] init];
    
    [self.pointsContainer addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    
    [self.outerView addSubview:self.pointsContainer];
    
    NSLayoutConstraint *lowPriorityWidthEqualConstraint = [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.outerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-20.0];
    lowPriorityWidthEqualConstraint.priority = 999;
    NSLayoutConstraint *lowPriorityHeightEqualConstraint = [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.outerView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-60.0];
    lowPriorityHeightEqualConstraint.priority = 999;
    
    NSArray *outerConstraints = [NSArray arrayWithObjects:
                                 [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.outerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
                                 [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.outerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:20.0],
                                 [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.outerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-20.0],
                                 [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.outerView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-60.0],
                                 [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],
                                 lowPriorityWidthEqualConstraint, lowPriorityHeightEqualConstraint, nil];
    [self.outerView addConstraints:outerConstraints];
    
    self.stateLabel = [[UILabel alloc] init];
    self.stateLabel.font = [UIFont boldSystemFontOfSize:30.0];
    
    // TODO: Adjust font of label in main password input view.
    
    self.stateLabel.backgroundColor = [UIColor clearColor];
    self.stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.outerView addSubview:self.stateLabel];
    
    switch (self.state) {
        case CPMainPasswordStateChecking:
            self.stateLabel.text = @"Please input the main password";
            break;
        
        case CPMainPasswordStateConfirming:
            self.stateLabel.text = @"Please input the main password again to confirm";
            break;
            
        case CPMainPasswordStateSetting:
            self.stateLabel.text = @"Please set a main password";
            break;
            
        default:
            NSAssert(NO, @"Unknown main password manager state!");
            break;
    }
    
    [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.stateLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.stateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:-40.0]];
    
    // The button is used to reset main password or return to set password mode when confirming.
    
    self.redrawButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.redrawButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.redrawButton.backgroundColor = [UIColor blackColor];
    self.redrawButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
    self.redrawButton.alpha = 0.0;
    self.redrawButton.enabled = NO;
    
    [self.redrawButton setTitle:@"Redraw" forState:UIControlStateNormal];
    [self.redrawButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.redrawButton addTarget:self action:@selector(redrawButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize predictedSize = [@"Redraw" sizeWithFont:self.redrawButton.titleLabel.font];
    
    [self.outerView addSubview:self.redrawButton];
    
    [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.redrawButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeRight multiplier:1.0 constant:-100.0]];
    [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.redrawButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.redrawButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:predictedSize.width + 20.0]];
    
    [self.outerView layoutIfNeeded];

    NSMutableArray *constraintViews = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        UIView *constraintView = [[UIView alloc] init];
        constraintView.translatesAutoresizingMaskIntoConstraints = NO;
        [constraintViews addObject:constraintView];
        [self.pointsContainer addSubview:constraintView];
        
        if (i) {
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:constraintView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:i - 1] attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:constraintView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:i - 1] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:constraintView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:i - 1] attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:constraintView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:i - 1] attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        }
    }
    [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:[constraintViews objectAtIndex:0] attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:[constraintViews objectAtIndex:0] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:[constraintViews objectAtIndex:2] attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:[constraintViews objectAtIndex:2] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    NSMutableArray *passwordPoints = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            UIView *passwordPoint = [[UIView alloc] init];
            passwordPoint.translatesAutoresizingMaskIntoConstraints = NO;
            
            passwordPoint.backgroundColor = [UIColor grayColor];
            
            passwordPoint.layer.cornerRadius = MAIN_PASSWORD_POINT_SIZE / 2;
            passwordPoint.layer.borderWidth = MAIN_PASSWORD_POINT_SIZE / 6;
            passwordPoint.layer.borderColor = [UIColor blackColor].CGColor;
            
            [passwordPoints addObject:passwordPoint];
            [self.pointsContainer addSubview:passwordPoint];
            
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:j] attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:i] attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:MAIN_PASSWORD_POINT_SIZE]];
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:MAIN_PASSWORD_POINT_SIZE]];
        }
    }
    self.passwordPointViews = passwordPoints;
}

- (void)unloadAnimated:(BOOL)animated {
    [self.supermanager submanagerDidUnload:self];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.panningPoints = [NSMutableArray array];
        self.pointsContainer.points = [NSMutableArray array];
        self.lastPointState = CPMainPasswordCanvasLastPointStatePassPoint;
    }
    
    BOOL sign = YES;
    CGPoint panPoint = [panGesture locationInView:panGesture.view];
    for (int i = 0; i < 9; i++) {
        if ([CPMainPassManager passwordPointWithCenter:((UIView *)[self.passwordPointViews objectAtIndex:i]).center containsCGPoint:panPoint]) {
            if (self.panningPoints && (!self.panningPoints.count || ((NSNumber *)self.panningPoints.lastObject).intValue != i)) {
                UIView *passwordPoint = ((UIView *)[self.passwordPointViews objectAtIndex:i]);
                
                [self.panningPoints addObject:[NSNumber numberWithInt:i]];
                [CPMainPassManager addPoint:passwordPoint.center toPointArray:self.pointsContainer.points atState:self.lastPointState];
                self.lastPointState = CPMainPasswordCanvasLastPointStatePassPoint;
                
                passwordPoint.backgroundColor = [UIColor yellowColor];
                [UIView animateWithDuration:1.0 animations:^{
                    passwordPoint.backgroundColor = [UIColor grayColor];
                }];
            } else if (self.lastPointState == CPMainPasswordCanvasLastPointStateMouse) {
                [self.pointsContainer.points removeLastObject];
                self.lastPointState = CPMainPasswordCanvasLastPointStatePassPoint;
            }
            sign = NO;
        }
    }
    
    if (sign) {
        [CPMainPassManager addPoint:panPoint toPointArray:self.pointsContainer.points atState:self.lastPointState];
        self.lastPointState = CPMainPasswordCanvasLastPointStateMouse;
    }
    
    [self.pointsContainer setNeedsDisplay];
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        if (self.panningPoints && self.panningPoints.count) {
            switch (self.state) {
                case CPMainPasswordStateChecking:
                    if ([CPMainPassManager intArray:self.panningPoints isEqualToArray:[CPUserDefaultManager mainPass]]) {
                        [self passwordCheckingSucceeded];
                    } else {
                        [self passwordCheckingFailed];
                    }
                    break;
                    
                case CPMainPasswordStateConfirming:
                    if ([CPMainPassManager intArray:self.panningPoints isEqualToArray:self.passwords]) {
                        [self passwordCheckingSucceeded];
                    } else {
                        [self passwordCheckingFailed];
                    }
                    break;
                    
                case CPMainPasswordStateSetting:
                {
                    self.passwords = self.panningPoints;
                    self.stateLabel.text = @"Please input the main password again to confirm";
                    [UIView animateWithDuration:0.5 animations:^{
                        self.redrawButton.alpha = 1.0;
                    } completion:^(BOOL finished) {
                        self.redrawButton.enabled = YES;
                    }];
                    self.state = CPMainPasswordStateConfirming;
                    break;
                }
                    
                default:
                    NSAssert(NO, @"Unknown main password manager state!");
                    break;
            }            
        }
    }
}

- (void)redrawButtonPressed:(id)sender {
    if (self.state == CPMainPasswordStateConfirming) {
        [UIView animateWithDuration:0.5 animations:^{
        self.redrawButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.redrawButton.enabled = NO;
    }];
        self.stateLabel.text = @"Please set a main password";
        self.state = CPMainPasswordStateSetting;
    }
}

- (void)passwordCheckingSucceeded {
    [CPUserDefaultManager setMainPass:self.passwords];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.outerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self unloadAnimated:YES];
    }];
}

- (void)passwordCheckingFailed {
    [UIView animateWithDuration:0.25 animations:^{
        self.outerView.backgroundColor = [UIColor redColor];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.outerView.backgroundColor = [UIColor whiteColor];
        }];
    }];
}

@end