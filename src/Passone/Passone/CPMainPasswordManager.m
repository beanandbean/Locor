//
//  CPMainPasswordManager.m
//  Passone
//
//  Created by wangsw on 8/15/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainPasswordManager.h"

#import "CPNotificationCenter.h"

typedef enum {
    CPMainPasswordStateSetting,
    CPMainPasswordStateConfirming,
    CPMainPasswordStateChecking
} CPMainPasswordState;

@interface CPMainPasswordManager ()

@property (nonatomic) CPMainPasswordState state;

@property (weak, nonatomic) UIView *superview;

@property (strong, nonatomic) UIView *outerview;
@property (strong, nonatomic) NSArray *outerConstraints;

@property (strong, nonatomic) UILabel *stateLabel;

@property (strong, nonatomic) NSArray *passwordPoints;

@property (strong, nonatomic) NSArray *correctPoints;
@property (strong, nonatomic) NSMutableArray *panningPoints;

+ (float)pointSize;

+ (BOOL)intArray:(NSArray *)array1 isEqualToArray:(NSArray *)array2;

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
    self.outerview.translatesAutoresizingMaskIntoConstraints = NO;
    self.outerview.backgroundColor = [UIColor whiteColor];
    
    [self.superview addSubview:self.outerview];
    
    self.outerConstraints = [NSArray arrayWithObjects:
                             [NSLayoutConstraint constraintWithItem:self.outerview attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                             [NSLayoutConstraint constraintWithItem:self.outerview attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                             [NSLayoutConstraint constraintWithItem:self.outerview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                             [NSLayoutConstraint constraintWithItem:self.outerview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                             nil];
    [self.superview addConstraints:self.outerConstraints];
    
    UIView *outerview = [[UIView alloc] init];
    outerview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [outerview addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    
    [self.outerview addSubview:outerview];
    
    NSLayoutConstraint *lowPriorityWidthEqualConstraint = [NSLayoutConstraint constraintWithItem:outerview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.outerview attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-20.0];
    lowPriorityWidthEqualConstraint.priority = 999;
    NSLayoutConstraint *lowPriorityHeightEqualConstraint = [NSLayoutConstraint constraintWithItem:outerview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.outerview attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-20.0];
    lowPriorityHeightEqualConstraint.priority = 999;
    
    NSArray *outerConstraints = [NSArray arrayWithObjects:
                                 [NSLayoutConstraint constraintWithItem:outerview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.outerview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
                                 [NSLayoutConstraint constraintWithItem:outerview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.outerview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],
                                 [NSLayoutConstraint constraintWithItem:outerview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.outerview attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-20.0],
                                 [NSLayoutConstraint constraintWithItem:outerview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.outerview attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-20.0],
                                 [NSLayoutConstraint constraintWithItem:outerview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:outerview attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],
                                 lowPriorityWidthEqualConstraint, lowPriorityHeightEqualConstraint, nil];
    [self.outerview addConstraints:outerConstraints];
    
    self.stateLabel = [[UILabel alloc] init];
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
    
    [self.outerview addConstraint:[NSLayoutConstraint constraintWithItem:self.stateLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:outerview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.outerview addConstraint:[NSLayoutConstraint constraintWithItem:self.stateLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:outerview attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0]];
    
    NSMutableArray *constraintViews = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        UIView *constraintView = [[UIView alloc] init];
        constraintView.translatesAutoresizingMaskIntoConstraints = NO;
        [constraintViews addObject:constraintView];
        [outerview addSubview:constraintView];
        
        if (i) {
            [outerview addConstraint:[NSLayoutConstraint constraintWithItem:constraintView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:i - 1] attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
            [outerview addConstraint:[NSLayoutConstraint constraintWithItem:constraintView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:i - 1] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
            [outerview addConstraint:[NSLayoutConstraint constraintWithItem:constraintView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:i - 1] attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
            [outerview addConstraint:[NSLayoutConstraint constraintWithItem:constraintView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:i - 1] attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        }
    }
    [outerview addConstraint:[NSLayoutConstraint constraintWithItem:[constraintViews objectAtIndex:0] attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:outerview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [outerview addConstraint:[NSLayoutConstraint constraintWithItem:[constraintViews objectAtIndex:0] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:outerview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [outerview addConstraint:[NSLayoutConstraint constraintWithItem:[constraintViews objectAtIndex:2] attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:outerview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [outerview addConstraint:[NSLayoutConstraint constraintWithItem:[constraintViews objectAtIndex:2] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:outerview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    NSMutableArray *passwordPoints = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            UIView *passwordPoint = [[UIView alloc] init];
            passwordPoint.translatesAutoresizingMaskIntoConstraints = NO;
            [passwordPoints addObject:passwordPoint];
            [outerview addSubview:passwordPoint];
            
            passwordPoint.backgroundColor = [UIColor blackColor];
            
            [outerview addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:j] attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
            [outerview addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:[constraintViews objectAtIndex:i] attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
            [outerview addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:[CPMainPasswordManager pointSize]]];
            [outerview addConstraint:[NSLayoutConstraint constraintWithItem:passwordPoint attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:[CPMainPasswordManager pointSize]]];
        }
    }
    self.passwordPoints = passwordPoints;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.panningPoints = [NSMutableArray array];
    }
    
    CGPoint panPoint = [panGesture locationInView:panGesture.view];
    for (int i = 0; i < 9; i++) {
        if (self.panningPoints && (!self.panningPoints.count || ((NSNumber *)self.panningPoints.lastObject).intValue != i) && CGRectContainsPoint(((UIView *)[self.passwordPoints objectAtIndex:i]).frame, panPoint)) {
            [self.panningPoints addObject:[NSNumber numberWithInt:i]];
            ((UIView *)[self.passwordPoints objectAtIndex:i]).backgroundColor = [UIColor redColor];
            [UIView animateWithDuration:1.0 animations:^{
                ((UIView *)[self.passwordPoints objectAtIndex:i]).backgroundColor = [UIColor blackColor];
            }];
        }
    }
    
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
                    self.correctPoints = self.panningPoints;
                    self.stateLabel.text = @"Please input the main password again to confirm";
                    self.state = CPMainPasswordStateConfirming;
                    break;
                    
                default:
                    NSAssert(NO, @"Unknown main password manager state!");
                    break;
            }            
        }
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
