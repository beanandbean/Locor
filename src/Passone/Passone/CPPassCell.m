//
//  CPPassCell.m
//  Passone
//
//  Created by wangyw on 6/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCell.h"

#import "CPPassoneConfig.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPAppearanceManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPNotificationCenter.h"

#import "CPProcessManager.h"
#import "CPDraggingPassCellProcess.h"
#import "CPRemovingPassCellProcess.h"

@interface CPPassCell ()

@property (weak, nonatomic) id<CPPassCellDelegate> delegate;

@property (strong, nonatomic) NSString *iconName;

@property (nonatomic) int removingDirection;
@property (strong, nonatomic) UIView *removingView;
@property (strong, nonatomic) UILabel *removingLabel1;
@property (strong, nonatomic) UILabel *removingLabel2;
@property (strong, nonatomic) NSArray *removingConstraints;
@property (strong, nonatomic) NSArray *removingLabelConstraints;

@end

@implementation CPPassCell

- (id)initWithIndex:(NSUInteger)index delegate:(id<CPPassCellDelegate>)delegate {
    self = [super init];
    if (self) {
        self.index = index;
        self.delegate = delegate;
        self.clipsToBounds = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:index];
        self.backgroundColor = password.displayColor;
        self.iconName = password.icon;
        
        NSMutableArray *gestureArray = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null], nil];
        
        UITapGestureRecognizer *editing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditingGesture:)];
        editing.numberOfTapsRequired = EDITING_TAP_NUMBER;
        [self addGestureRecognizer:editing];
        [gestureArray replaceObjectAtIndex:EDITING_TAP_NUMBER - 1 withObject:editing];
        
        UITapGestureRecognizer *copyPassword = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCopyPasswordGesture:)];
        copyPassword.numberOfTapsRequired = COPY_PASSWORD_TAP_NUMBER;
        [self addGestureRecognizer:copyPassword];
        [gestureArray replaceObjectAtIndex:COPY_PASSWORD_TAP_NUMBER - 1 withObject:copyPassword];
        
        [[gestureArray objectAtIndex:0] requireGestureRecognizerToFail:[gestureArray objectAtIndex:1]];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        longPress.delegate = self;
        [self addGestureRecognizer: longPress];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delegate = self;
        [self addGestureRecognizer: pan];
    }
    return self;
}

- (void)handleEditingGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.delegate tapPassCell:self];
}

- (void)handleCopyPasswordGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    // TODO: Not copy to clipboard if password is not used.
    [UIPasteboard generalPasteboard].string = ((CPPassword *)[[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index]).text;
    [CPNotificationCenter insertNotification:[NSString stringWithFormat:@"Password No %d copied to clipboard.", self.index]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) || ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])) {
        return YES;
    } else {
        return NO;
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        // [self.delegate swipePassCell:self];
        [CPProcessManager startProcess:DRAGGING_PASS_CELL_PROCESS withPreparation:^{
            [self.delegate startDragPassCell:self];
        }];
    } else if (longPressGesture.state == UIGestureRecognizerStateEnded || longPressGesture.state == UIGestureRecognizerStateCancelled || longPressGesture.state == UIGestureRecognizerStateFailed) {
        if ([CPProcessManager isInProcess:DRAGGING_PASS_CELL_PROCESS] && [self.delegate canStopDragPassCell:self]) {
            [CPProcessManager stopProcess:DRAGGING_PASS_CELL_PROCESS withPreparation:^{
                [self.delegate stopDragPassCell:self];
            }];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [CPProcessManager startProcess:REMOVING_PASS_CELL_PROCESS withPreparation:^{
            self.removingView = [[UIView alloc] init];
            [self addSubview:self.removingView];
            
            // TODO: When removing pass cell, use images instead of single-colored views.
            CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
            self.removingView.backgroundColor = password.displayColor;
            self.backgroundColor = password.reversedColor;
            
            self.removingView.translatesAutoresizingMaskIntoConstraints = NO;
            NSLayoutConstraint *removingTopConstraint = [NSLayoutConstraint constraintWithItem:self.removingView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
            [self addConstraint:removingTopConstraint];
            NSLayoutConstraint *removingLeftConstraint = [NSLayoutConstraint constraintWithItem:self.removingView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
            [self addConstraint:removingLeftConstraint];
            NSLayoutConstraint *removingWidthConstraint = [NSLayoutConstraint constraintWithItem:self.removingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
            [self addConstraint:removingWidthConstraint];
            NSLayoutConstraint *removingHeightConstraint = [NSLayoutConstraint constraintWithItem:self.removingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
            [self addConstraint:removingHeightConstraint];
            self.removingConstraints = [NSArray arrayWithObjects:removingTopConstraint, removingLeftConstraint, removingWidthConstraint, removingHeightConstraint, nil];
            [self layoutIfNeeded];
            
            // TODO: Adjust font of pass cell removing label.
            self.removingLabel1 = [[UILabel alloc] init];
            self.removingLabel1.textColor = [UIColor whiteColor];
            self.removingLabel1.backgroundColor = [UIColor clearColor];
            self.removingLabel1.translatesAutoresizingMaskIntoConstraints = NO;
            self.removingLabel2 = [[UILabel alloc] init];
            self.removingLabel2.textColor = [UIColor whiteColor];
            self.removingLabel2.backgroundColor = [UIColor clearColor];
            self.removingLabel2.translatesAutoresizingMaskIntoConstraints = NO;
            
            self.removingDirection = -1;
        }];
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        if ([CPProcessManager isInProcess:DRAGGING_PASS_CELL_PROCESS]) {
            CGPoint location = [panGesture locationInView:panGesture.view];
            [self.delegate dragPassCell:self location:location translation:translation];
            [panGesture setTranslation:CGPointZero inView:panGesture.view];
        } else if ([CPProcessManager isInProcess:REMOVING_PASS_CELL_PROCESS]) {
            if (self.removingView) {
                if (self.removingDirection == -1) {
                    if (fabsf(translation.x) > fabsf(translation.y)) {
                        self.removingDirection = 1;
                        
                        [self.removingLabel1 setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
                        [self.removingLabel2 setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
                        
                        [self addSubview:self.removingLabel1];
                        [self addSubview:self.removingLabel2];
                        
                        NSLayoutConstraint *labelCenterConstraint1 = [NSLayoutConstraint constraintWithItem:self.removingLabel1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.removingView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
                        [self addConstraint:labelCenterConstraint1];
                        NSLayoutConstraint *labelCenterConstraint2 = [NSLayoutConstraint constraintWithItem:self.removingLabel2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.removingView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
                        [self addConstraint:labelCenterConstraint2];
                        NSLayoutConstraint *labelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.removingLabel1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.removingView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-5.0];
                        [self addConstraint:labelLeftConstraint];
                        NSLayoutConstraint *labelRightConstraint = [NSLayoutConstraint constraintWithItem:self.removingLabel2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.removingView attribute:NSLayoutAttributeRight multiplier:1.0 constant:5.0];
                        [self addConstraint:labelRightConstraint];
                        self.removingLabelConstraints = [NSArray arrayWithObjects:labelCenterConstraint1, labelCenterConstraint2, labelLeftConstraint, labelRightConstraint, nil];
                    } else {
                        self.removingDirection = 0;
                        
                        [self addSubview:self.removingLabel1];
                        [self addSubview:self.removingLabel2];
                        
                        NSLayoutConstraint *labelCenterConstraint1 = [NSLayoutConstraint constraintWithItem:self.removingLabel1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.removingView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
                        [self addConstraint:labelCenterConstraint1];
                        NSLayoutConstraint *labelCenterConstraint2 = [NSLayoutConstraint constraintWithItem:self.removingLabel2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.removingView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
                        [self addConstraint:labelCenterConstraint2];
                        NSLayoutConstraint *labelBottomConstraint = [NSLayoutConstraint constraintWithItem:self.removingLabel1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.removingView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-5.0];
                        [self addConstraint:labelBottomConstraint];
                        NSLayoutConstraint *labelTopConstraint = [NSLayoutConstraint constraintWithItem:self.removingLabel2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.removingView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.0];
                        [self addConstraint:labelTopConstraint];
                        self.removingLabelConstraints = [NSArray arrayWithObjects:labelCenterConstraint1, labelCenterConstraint2, labelBottomConstraint, labelTopConstraint, nil];
                    }
                }
                
                // TODO: Change behavior of pass cell removing view & label if cannot toggle remove state.
                
                float constant = 0.0;
                NSString *action;
                CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
                if (password.isUsed.boolValue) {
                    action = @"remove";
                } else {
                    action = @"recover";
                }
                NSString *swipe = [NSString stringWithFormat:@"Swipe to %@", action];
                NSString *release = [NSString stringWithFormat:@"Release to %@", action];
                if (self.removingDirection % 2) {
                    constant = abs(translation.x) > self.bounds.size.width ? translation.x >= 0 ? self.bounds.size.width : -self.bounds.size.width : translation.x;
                    if (abs(translation.x) < self.bounds.size.width / 2) {
                        self.removingLabel1.text = swipe;
                        self.removingLabel2.text = swipe;
                    } else {
                        self.removingLabel1.text = release;
                        self.removingLabel2.text = release;
                    }
                } else {
                    constant = abs(translation.y) > self.bounds.size.height ? translation.y >= 0 ? self.bounds.size.height : -self.bounds.size.height : translation.y;
                    if (abs(translation.y) < self.bounds.size.height / 2) {
                        self.removingLabel1.text = swipe;
                        self.removingLabel2.text = swipe;
                    } else {
                        self.removingLabel1.text = release;
                        self.removingLabel2.text = release;
                    }
                }
                ((NSLayoutConstraint *)[self.removingConstraints objectAtIndex:self.removingDirection]).constant = constant;
                [self layoutIfNeeded];
            }
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        if ([CPProcessManager isInProcess:DRAGGING_PASS_CELL_PROCESS] && [self.delegate canStopDragPassCell:self]) {
            [CPProcessManager stopProcess:DRAGGING_PASS_CELL_PROCESS withPreparation:^{
                [self.delegate stopDragPassCell:self];
            }];
        }
        if ([CPProcessManager isInProcess:REMOVING_PASS_CELL_PROCESS] && self.removingView) {
            [CPProcessManager stopProcess:REMOVING_PASS_CELL_PROCESS withPreparation:^{
                CGPoint translation = [panGesture translationInView:panGesture.view];
                if ((self.removingDirection % 2 && abs(translation.x) >= self.bounds.size.width / 2) || (!self.removingDirection % 2 && abs(translation.y) >= self.bounds.size.height / 2)) {
                    if ([[CPPassDataManager defaultManager] canToggleRemoveStateOfPasswordAtIndex:self.index]) {
                        float constant = 0;
                        if (self.removingDirection % 2) {
                            constant = translation.x >= 0 ? self.bounds.size.width : -self.bounds.size.width;
                        } else {
                            constant = translation.y >= 0 ? self.bounds.size.height : -self.bounds.size.height;
                        }
                        ((NSLayoutConstraint *)[self.removingConstraints objectAtIndex:self.removingDirection]).constant = constant;
                        [CPAppearanceManager animateWithDuration:0.3 animations:^{
                            [self layoutIfNeeded];
                            self.removingLabel1.alpha = 0.0;
                            self.removingLabel2.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            [self.removingView removeFromSuperview];
                            [self.removingLabel1 removeFromSuperview];
                            [self.removingLabel2 removeFromSuperview];
                            [self removeConstraints:self.removingConstraints];
                            self.removingDirection = -1;
                            self.removingView = nil;
                            self.removingLabel1 = nil;
                            self.removingLabel2 = nil;
                            self.removingConstraints = nil;
                            
                            if (self.removingLabelConstraints) {
                                [self removeConstraints:self.removingLabelConstraints];
                                self.removingLabelConstraints = nil;
                            }
                        }];
                    } else {
                        ((NSLayoutConstraint *)[self.removingConstraints objectAtIndex:self.removingDirection]).constant = 0;
                        [CPAppearanceManager animateWithDuration:0.3 animations:^{
                            [self layoutIfNeeded];
                            self.removingLabel1.alpha = 0.0;
                            self.removingLabel2.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
                            self.backgroundColor = password.displayColor;
                            
                            [self.removingView removeFromSuperview];
                            [self.removingLabel1 removeFromSuperview];
                            [self.removingLabel2 removeFromSuperview];
                            [self removeConstraints:self.removingConstraints];
                            self.removingDirection = -1;
                            self.removingView = nil;
                            self.removingLabel1 = nil;
                            self.removingLabel2 = nil;
                            self.removingConstraints = nil;
                            
                            if (self.removingLabelConstraints) {
                                [self removeConstraints:self.removingLabelConstraints];
                                self.removingLabelConstraints = nil;
                            }
                        }];
                    }
                    [[CPPassDataManager defaultManager] toggleRemoveStateOfPasswordAtIndex:self.index];
                } else {
                    ((NSLayoutConstraint *)[self.removingConstraints objectAtIndex:self.removingDirection]).constant = 0;
                    [CPAppearanceManager animateWithDuration:0.3 animations:^{
                        [self layoutIfNeeded];
                        self.removingLabel1.alpha = 0.0;
                        self.removingLabel2.alpha = 0.0;
                    } completion:^(BOOL finished) {
                        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
                        self.backgroundColor = password.displayColor;
                        
                        [self.removingView removeFromSuperview];
                        [self.removingLabel1 removeFromSuperview];
                        [self.removingLabel2 removeFromSuperview];
                        [self removeConstraints:self.removingConstraints];
                        self.removingDirection = -1;
                        self.removingView = nil;
                        self.removingLabel1 = nil;
                        self.removingLabel2 = nil;
                        self.removingConstraints = nil;
                        
                        if (self.removingLabelConstraints) {
                            [self removeConstraints:self.removingLabelConstraints];
                            self.removingLabelConstraints = nil;
                        }
                    }];
                }
            }];
        }
    }
}

@end
