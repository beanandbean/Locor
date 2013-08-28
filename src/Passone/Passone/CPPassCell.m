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

@property (strong, nonatomic) UIView *iconView;
@property (strong, nonatomic) NSArray *iconImagePositionConstraints;

@property (nonatomic) int removingDirection;
@property (strong, nonatomic) UIView *removingView;
@property (strong, nonatomic) UIView *removingIconContainer1;
@property (strong, nonatomic) UIView *removingIconContainer2;
@property (strong, nonatomic) UIImageView *removingIcon1;
@property (strong, nonatomic) UIImageView *removingIcon2;
@property (strong, nonatomic) UILabel *removingLabel1;
@property (strong, nonatomic) UILabel *removingLabel2;
@property (strong, nonatomic) NSArray *removingConstraints;
@property (strong, nonatomic) NSArray *removingIconConstraints;
@property (strong, nonatomic) NSArray *removingLabelConstraints;

@end

@implementation CPPassCell

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    if (self.iconImage) {
        self.iconImage.alpha = alpha;
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (self.iconImage) {
        self.iconImage.hidden = hidden;
    }
}

- (void)setIcon:(NSString *)icon {
    self.iconImage.image = [UIImage imageNamed:icon];
}

- (id)initWithIndex:(NSUInteger)index delegate:(id<CPPassCellDelegate>)delegate {
    self = [super init];
    if (self) {
        self.index = index;
        self.delegate = delegate;
        self.clipsToBounds = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:index];
        self.backgroundColor = password.displayColor;
        self.iconView = [[UIView alloc] init];
        self.iconView.clipsToBounds = YES;
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.delegate.iconLayer addSubview:self.iconView];
        [self.delegate.iconLayer.superview addConstraints:[CPAppearanceManager constraintsForView:self.iconView toEqualToView:self]];
        
        self.iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:password.displayIcon]];
        self.iconImage.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.iconView addSubview:self.iconImage];
        
        self.iconImagePositionConstraints = [NSArray arrayWithObjects:
                                             [NSLayoutConstraint constraintWithItem:self.iconImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],
                                             [NSLayoutConstraint constraintWithItem:self.iconImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
                                             nil];
        [self.iconView addConstraints:self.iconImagePositionConstraints];
        
        NSMutableArray *gestureArray = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null], nil];
        
        UITapGestureRecognizer *editing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditingGesture:)];
        editing.numberOfTapsRequired = EDITING_TAP_NUMBER;
        [self.iconView addGestureRecognizer:editing];
        [gestureArray replaceObjectAtIndex:EDITING_TAP_NUMBER - 1 withObject:editing];
        
        UITapGestureRecognizer *copyPassword = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCopyPasswordGesture:)];
        copyPassword.numberOfTapsRequired = COPY_PASSWORD_TAP_NUMBER;
        [self.iconView addGestureRecognizer:copyPassword];
        [gestureArray replaceObjectAtIndex:COPY_PASSWORD_TAP_NUMBER - 1 withObject:copyPassword];
        
        [[gestureArray objectAtIndex:0] requireGestureRecognizerToFail:[gestureArray objectAtIndex:1]];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        longPress.delegate = self;
        [self.iconView addGestureRecognizer:longPress];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delegate = self;
        [self.iconView addGestureRecognizer:pan];
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
            
            self.removingIconContainer1 = [[UIView alloc] init];
            self.removingIconContainer1.translatesAutoresizingMaskIntoConstraints = NO;
            self.removingIconContainer2 = [[UIView alloc] init];
            self.removingIconContainer2.translatesAutoresizingMaskIntoConstraints = NO;
            
            self.removingIcon1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:password.reversedIcon]];
            self.removingIcon1.translatesAutoresizingMaskIntoConstraints = NO;
            self.removingIcon2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:password.reversedIcon]];
            self.removingIcon2.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self.removingIconContainer1 addSubview:self.removingIcon1];
            [self.removingIconContainer2 addSubview:self.removingIcon2];
            
            [self.removingIconContainer1 addConstraint:[NSLayoutConstraint constraintWithItem:self.removingIcon1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.removingIconContainer1 attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
            [self.removingIconContainer1 addConstraint:[NSLayoutConstraint constraintWithItem:self.removingIcon1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.removingIconContainer1 attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
            [self.removingIconContainer2 addConstraint:[NSLayoutConstraint constraintWithItem:self.removingIcon2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.removingIconContainer2 attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
            [self.removingIconContainer2 addConstraint:[NSLayoutConstraint constraintWithItem:self.removingIcon2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.removingIconContainer2 attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
            
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
                    [self.iconView addSubview:self.removingIconContainer1];
                    [self.iconView addSubview:self.removingIconContainer2];
                    
                    NSLayoutConstraint *iconWidthConstraint1 = [NSLayoutConstraint constraintWithItem:self.removingIconContainer1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
                    [self.iconView addConstraint:iconWidthConstraint1];
                    NSLayoutConstraint *iconWidthConstraint2 = [NSLayoutConstraint constraintWithItem:self.removingIconContainer2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
                    [self.iconView addConstraint:iconWidthConstraint2];
                    NSLayoutConstraint *iconHeightConstraint1 = [NSLayoutConstraint constraintWithItem:self.removingIconContainer1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
                    [self.iconView addConstraint:iconHeightConstraint1];
                    NSLayoutConstraint *iconHeightConstraint2 = [NSLayoutConstraint constraintWithItem:self.removingIconContainer2 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
                    [self.iconView addConstraint:iconHeightConstraint2];
                    
                    [self.iconView addSubview:self.removingLabel1];
                    [self.iconView addSubview:self.removingLabel2];
                    
                    NSLayoutConstraint *icon1Constraint, *icon2Constraint, *iconCenterConstraint1, *iconCenterConstraint2;
                    
                    if (fabsf(translation.x) > fabsf(translation.y)) {
                        self.removingDirection = 1;
                        
                        icon1Constraint = [NSLayoutConstraint constraintWithItem:self.removingIconContainer1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:icon1Constraint];
                        icon2Constraint = [NSLayoutConstraint constraintWithItem:self.removingIconContainer2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:icon2Constraint];
                        iconCenterConstraint1 = [NSLayoutConstraint constraintWithItem:self.removingIconContainer1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:iconCenterConstraint1];
                        iconCenterConstraint2 = [NSLayoutConstraint constraintWithItem:self.removingIconContainer2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:iconCenterConstraint2];
                        
                        [self.removingLabel1 setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                        [self.removingLabel2 setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                        
                        NSLayoutConstraint *labelCenterConstraint1 = [NSLayoutConstraint constraintWithItem:self.removingLabel1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:labelCenterConstraint1];
                        NSLayoutConstraint *labelCenterConstraint2 = [NSLayoutConstraint constraintWithItem:self.removingLabel2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:labelCenterConstraint2];
                        NSLayoutConstraint *labelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.removingLabel1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE];
                        [self.iconView addConstraint:labelLeftConstraint];
                        NSLayoutConstraint *labelRightConstraint = [NSLayoutConstraint constraintWithItem:self.removingLabel2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeRight multiplier:1.0 constant:PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE];
                        [self.iconView addConstraint:labelRightConstraint];
                        self.removingLabelConstraints = [NSArray arrayWithObjects:labelLeftConstraint, labelRightConstraint, labelCenterConstraint1, labelCenterConstraint2, nil];
                    } else {
                        self.removingDirection = 0;

                        icon1Constraint = [NSLayoutConstraint constraintWithItem:self.removingIconContainer1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:icon1Constraint];
                        icon2Constraint = [NSLayoutConstraint constraintWithItem:self.removingIconContainer2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:icon2Constraint];
                        iconCenterConstraint1 = [NSLayoutConstraint constraintWithItem:self.removingIconContainer1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:iconCenterConstraint1];
                        iconCenterConstraint2 = [NSLayoutConstraint constraintWithItem:self.removingIconContainer2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:iconCenterConstraint2];
                        
                        NSLayoutConstraint *labelCenterConstraint1 = [NSLayoutConstraint constraintWithItem:self.removingLabel1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:labelCenterConstraint1];
                        NSLayoutConstraint *labelCenterConstraint2 = [NSLayoutConstraint constraintWithItem:self.removingLabel2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
                        [self.iconView addConstraint:labelCenterConstraint2];
                        NSLayoutConstraint *labelBottomConstraint = [NSLayoutConstraint constraintWithItem:self.removingLabel1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE];
                        [self.iconView addConstraint:labelBottomConstraint];
                        NSLayoutConstraint *labelTopConstraint = [NSLayoutConstraint constraintWithItem:self.removingLabel2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE];
                        [self.iconView addConstraint:labelTopConstraint];
                        self.removingLabelConstraints = [NSArray arrayWithObjects:labelBottomConstraint, labelTopConstraint, labelCenterConstraint1, labelCenterConstraint2, nil];
                    }
                    
                    self.removingIconConstraints = [NSArray arrayWithObjects:icon1Constraint, icon2Constraint, iconCenterConstraint1, iconCenterConstraint2, iconWidthConstraint1, iconWidthConstraint2, iconHeightConstraint1, iconHeightConstraint2, nil];
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
                if (self.removingDirection) {
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
                ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:self.removingDirection]).constant = constant;
                ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:0]).constant = constant;
                ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:1]).constant = constant;
                ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:0]).constant = constant - PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:1]).constant = constant + PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                [self.superview.superview layoutIfNeeded];
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
                if ((self.removingDirection && abs(translation.x) >= self.bounds.size.width / 2) || (!self.removingDirection && abs(translation.y) >= self.bounds.size.height / 2)) {
                    if ([[CPPassDataManager defaultManager] canToggleRemoveStateOfPasswordAtIndex:self.index]) {
                        float constant = 0;
                        if (self.removingDirection) {
                            constant = translation.x >= 0 ? self.bounds.size.width : -self.bounds.size.width;
                        } else {
                            constant = translation.y >= 0 ? self.bounds.size.height : -self.bounds.size.height;
                        }
                        ((NSLayoutConstraint *)[self.removingConstraints objectAtIndex:self.removingDirection]).constant = constant;
                        ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:self.removingDirection]).constant = constant;
                        ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:0]).constant = constant;
                        ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:1]).constant = constant;
                        ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:0]).constant = constant - PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                        ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:1]).constant = constant + PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                        [CPAppearanceManager animateWithDuration:0.3 animations:^{
                            [self.superview.superview layoutIfNeeded];
                            self.removingLabel1.alpha = 0.0;
                            self.removingLabel2.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            [self removeConstraints:self.removingConstraints];
                            
                            if (self.removingIconConstraints) {
                                [self.iconView removeConstraints:self.removingIconConstraints];
                                self.removingIconConstraints = nil;
                                
                                [self.removingIconContainer1 removeFromSuperview];
                                [self.removingIconContainer2 removeFromSuperview];
                            }
                            
                            if (self.removingLabelConstraints) {
                                [self.iconView removeConstraints:self.removingLabelConstraints];
                                self.removingLabelConstraints = nil;
                                
                                [self.removingLabel1 removeFromSuperview];
                                [self.removingLabel2 removeFromSuperview];
                            }
                            
                            [self.removingView removeFromSuperview];
                            
                            self.iconImage.image = self.removingIcon1.image;
                            ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:self.removingDirection]).constant = 0.0;
                            
                            self.removingDirection = -1;
                            self.removingView = nil;
                            self.removingIconContainer1 = nil;
                            self.removingIconContainer2 = nil;
                            self.removingIcon1 = nil;
                            self.removingIcon2 = nil;
                            self.removingLabel1 = nil;
                            self.removingLabel2 = nil;
                            self.removingConstraints = nil;
                        }];
                    } else {
                        ((NSLayoutConstraint *)[self.removingConstraints objectAtIndex:self.removingDirection]).constant = 0.0;
                        ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:self.removingDirection]).constant = 0.0;
                        ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:0]).constant = 0.0;
                        ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:1]).constant = 0.0;
                        ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:0]).constant = -PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                        ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:1]).constant = PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                        [CPAppearanceManager animateWithDuration:0.3 animations:^{
                            [self.superview.superview layoutIfNeeded];
                        } completion:^(BOOL finished) {
                            CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
                            self.backgroundColor = password.displayColor;
                            
                            [self removeConstraints:self.removingConstraints];
                            
                            if (self.removingIconConstraints) {
                                [self.iconView removeConstraints:self.removingIconConstraints];
                                self.removingIconConstraints = nil;
                                
                                [self.removingIconContainer1 removeFromSuperview];
                                [self.removingIconContainer2 removeFromSuperview];
                            }
                                                       
                            if (self.removingLabelConstraints) {
                                [self.iconView removeConstraints:self.removingLabelConstraints];
                                self.removingLabelConstraints = nil;
                                
                                [self.removingLabel1 removeFromSuperview];
                                [self.removingLabel2 removeFromSuperview];
                            }
                            
                            [self.removingView removeFromSuperview];
                            
                            self.removingDirection = -1;
                            self.removingView = nil;
                            self.removingIconContainer1 = nil;
                            self.removingIconContainer2 = nil;
                            self.removingIcon1 = nil;
                            self.removingIcon2 = nil;
                            self.removingLabel1 = nil;
                            self.removingLabel2 = nil;
                            self.removingConstraints = nil;
                        }];
                    }
                    [[CPPassDataManager defaultManager] toggleRemoveStateOfPasswordAtIndex:self.index];
                } else {
                    ((NSLayoutConstraint *)[self.removingConstraints objectAtIndex:self.removingDirection]).constant = 0.0;
                    ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:self.removingDirection]).constant = 0.0;
                    ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:0]).constant = 0.0;
                    ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:1]).constant = 0.0;
                    ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:0]).constant = -PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                    ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:1]).constant = PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                    [CPAppearanceManager animateWithDuration:0.3 animations:^{
                        [self.superview.superview layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
                        self.backgroundColor = password.displayColor;
                        
                        [self removeConstraints:self.removingConstraints];
                        
                        if (self.removingIconConstraints) {
                            [self.iconView removeConstraints:self.removingIconConstraints];
                            self.removingIconConstraints = nil;
                            
                            [self.removingIconContainer1 removeFromSuperview];
                            [self.removingIconContainer2 removeFromSuperview];
                        }
                        
                        if (self.removingLabelConstraints) {
                            [self.iconView removeConstraints:self.removingLabelConstraints];
                            self.removingLabelConstraints = nil;
                            
                            [self.removingLabel1 removeFromSuperview];
                            [self.removingLabel2 removeFromSuperview];
                        }
                        
                        [self.removingView removeFromSuperview];
                        
                        self.removingDirection = -1;
                        self.removingView = nil;
                        self.removingIconContainer1 = nil;
                        self.removingIconContainer2 = nil;
                        self.removingIcon1 = nil;
                        self.removingIcon2 = nil;
                        self.removingLabel1 = nil;
                        self.removingLabel2 = nil;
                        self.removingConstraints = nil;
                    }];
                }
            }];
        }
    }
}

@end
