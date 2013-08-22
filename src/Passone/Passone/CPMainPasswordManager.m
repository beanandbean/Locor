//
//  CPMainPasswordManager.m
//  Passone
//
//  Created by wangsw on 8/15/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CPMainPasswordManager.h"

#import "CPMainPasswordCanvas.h"

#import "CPNotificationCenter.h"

typedef enum {
    CPMainPasswordStateSetting,
    CPMainPasswordStateConfirming,
    CPMainPasswordStateChecking
} CPMainPasswordState;

typedef enum {
    CPMainPasswordCanvasLastPointStateMouse,
    CPMainPasswordCanvasLastPointStatePassPoint
} CPMainPasswordCanvasLastPointState;

@interface CPMainPasswordManager ()

@property (nonatomic) CPMainPasswordState state;

@property (weak, nonatomic) UIView *superview;

@property (strong, nonatomic) UIView *outerview;
@property (strong, nonatomic) NSArray *outerConstraints;

@property (nonatomic) CPMainPasswordCanvas *pointsContainer;

@property (strong, nonatomic) UILabel *stateLabel;
@property (strong, nonatomic) UIButton *redrawButton;

@property (strong, nonatomic) NSArray *passwordPoints;

@property (strong, nonatomic) NSArray *correctPoints;
@property (strong, nonatomic) NSMutableArray *panningPoints;

@property (nonatomic) CPMainPasswordCanvasLastPointState lastPointState;

+ (float)pointSize;

+ (BOOL)passwordPointWithCenter:(CGPoint)passCenter containsCGPoint:(CGPoint)point;

+ (BOOL)intArray:(NSArray *)array1 isEqualToArray:(NSArray *)array2;

+ (void)addPoint:(CGPoint)point toPointArray:(NSMutableArray *)array atState:(CPMainPasswordCanvasLastPointState)state;

- (void)showPasswordInput;

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture;

- (void)passwordCheckingSucceeded;
- (void)passwordCheckingFailed;

@end

@implementation CPMainPasswordManager

+ (float)pointSize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 100.0;
    } else {
        return 50.0;
    }
}

+ (BOOL)passwordPointWithCenter:(CGPoint)passCenter containsCGPoint:(CGPoint)point {
    return sqrtf((passCenter.x - point.x) * (passCenter.x - point.x) + (passCenter.y - point.y) * (passCenter.y - point.y)) < [CPMainPasswordManager pointSize] / 2;
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

- (id)initWithSuperview:(UIView *)superview {
    self = [super init];
    if (self) {
        self.superview = superview;
        [self showPasswordInput];
    }
    return self;
}

- (void)showPasswordInput {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* passwordFilePath = [documentsPath stringByAppendingPathComponent:@"mainpass.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:passwordFilePath]) {
        self.state = CPMainPasswordStateChecking;
        self.correctPoints = [NSArray arrayWithContentsOfFile:passwordFilePath];
    } else {
        self.state = CPMainPasswordStateSetting;
    }
    
    self.outerview = [[UIView alloc] init];
    self.outerview.backgroundColor = [UIColor whiteColor];
    self.outerview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.superview addSubview:self.outerview];
    
    self.outerConstraints = [NSArray arrayWithObjects:
                             [NSLayoutConstraint constraintWithItem:self.outerview attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                             [NSLayoutConstraint constraintWithItem:self.outerview attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                             [NSLayoutConstraint constraintWithItem:self.outerview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                             [NSLayoutConstraint constraintWithItem:self.outerview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                             nil];
    [self.superview addConstraints:self.outerConstraints];
    
    self.pointsContainer = [[CPMainPasswordCanvas alloc] init];
    
    [self.pointsContainer addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    
    [self.outerview addSubview:self.pointsContainer];
    
    NSLayoutConstraint *lowPriorityWidthEqualConstraint = [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.outerview attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-20.0];
    lowPriorityWidthEqualConstraint.priority = 999;
    NSLayoutConstraint *lowPriorityHeightEqualConstraint = [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.outerview attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-60.0];
    lowPriorityHeightEqualConstraint.priority = 999;
    
    NSArray *outerConstraints = [NSArray arrayWithObjects:
                                 [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.outerview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
                                 [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.outerview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:20.0],
                                 [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.outerview attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-20.0],
                                 [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.outerview attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-60.0],
                                 [NSLayoutConstraint constraintWithItem:self.pointsContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],
                                 lowPriorityWidthEqualConstraint, lowPriorityHeightEqualConstraint, nil];
    [self.outerview addConstraints:outerConstraints];
    
    self.stateLabel = [[UILabel alloc] init];
    self.stateLabel.font = [UIFont boldSystemFontOfSize:30.0];
    
    // TODO: Adjust font of label in main password input view.
    
    self.stateLabel.backgroundColor = [UIColor clearColor];
    self.stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.outerview addSubview:self.stateLabel];
    
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
    
    [self.outerview addConstraint:[NSLayoutConstraint constraintWithItem:self.stateLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.outerview addConstraint:[NSLayoutConstraint constraintWithItem:self.stateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:-40.0]];
    
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
    
    [self.outerview addSubview:self.redrawButton];
    
    [self.outerview addConstraint:[NSLayoutConstraint constraintWithItem:self.redrawButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeRight multiplier:1.0 constant:-100.0]];
    [self.outerview addConstraint:[NSLayoutConstraint constraintWithItem:self.redrawButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.pointsContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.outerview addConstraint:[NSLayoutConstraint constraintWithItem:self.redrawButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:predictedSize.width + 20.0]];
    
    [self.outerview layoutIfNeeded];

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
            
            passwordPoint.layer.cornerRadius = [CPMainPasswordManager pointSize] / 2;
            passwordPoint.layer.borderWidth = [CPMainPasswordManager pointSize] / 6;
            passwordPoint.layer.borderColor = [UIColor blackColor].CGColor;
            
            [passwordPoints addObject:passwordPoint];
            [self.pointsContainer addSubview:passwordPoint];
            
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:j] attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:i] attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:[CPMainPasswordManager pointSize]]];
            [self.pointsContainer addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:[CPMainPasswordManager pointSize]]];
        }
    }
    self.passwordPoints = passwordPoints;
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
        if ([CPMainPasswordManager passwordPointWithCenter:((UIView *)[self.passwordPoints objectAtIndex:i]).center containsCGPoint:panPoint]) {
            if (self.panningPoints && (!self.panningPoints.count || ((NSNumber *)self.panningPoints.lastObject).intValue != i)) {
                UIView *passwordPoint = ((UIView *)[self.passwordPoints objectAtIndex:i]);
                
                [self.panningPoints addObject:[NSNumber numberWithInt:i]];
                [CPMainPasswordManager addPoint:passwordPoint.center toPointArray:self.pointsContainer.points atState:self.lastPointState];
                self.lastPointState = CPMainPasswordCanvasLastPointStatePassPoint;
                
                passwordPoint.backgroundColor = [UIColor yellowColor];
                [UIView animateWithDuration:1.0 animations:^{
                    passwordPoint.backgroundColor = [UIColor grayColor];
                }];
            }
            sign = NO;
        }
    }
    
    if (sign) {
        [CPMainPasswordManager addPoint:panPoint toPointArray:self.pointsContainer.points atState:self.lastPointState];
        self.lastPointState = CPMainPasswordCanvasLastPointStateMouse;
    }
    
    [self.pointsContainer setNeedsDisplay];
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        if (self.panningPoints && self.panningPoints.count) {
            switch (self.state) {
                case CPMainPasswordStateChecking:
                    if ([CPMainPasswordManager intArray:self.panningPoints isEqualToArray:self.correctPoints]) {
                        [self passwordCheckingSucceeded];
                    } else {
                        [self passwordCheckingFailed];
                    }
                    break;
                    
                case CPMainPasswordStateConfirming:
                    if ([CPMainPasswordManager intArray:self.panningPoints isEqualToArray:self.correctPoints]) {
                        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                        NSString* passwordFilePath = [documentsPath stringByAppendingPathComponent:@"mainpass.plist"];
                        [self.correctPoints writeToFile:passwordFilePath atomically:YES];
                        [self passwordCheckingSucceeded];
                    } else {
                        [self passwordCheckingFailed];
                    }
                    break;
                    
                case CPMainPasswordStateSetting:
                {
                    self.correctPoints = self.panningPoints;
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
    [UIView animateWithDuration:1.0 animations:^{
        self.outerview.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.superview removeConstraints:self.outerConstraints];
        [self.outerview removeFromSuperview];
    }];
}

- (void)passwordCheckingFailed {
    [CPNotificationCenter insertNotification:@"Sorry, the password is wrong, please input again"];
    [UIView animateWithDuration:0.25 animations:^{
        self.outerview.backgroundColor = [UIColor redColor];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.outerview.backgroundColor = [UIColor whiteColor];
        }];
    }];
}

@end
