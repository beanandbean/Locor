//
//  CPPassCell.m
//  Locor
//
//  Created by wangyw on 6/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCellManager.h"

#import "CPLocorConfig.h"

#import "CPAppearanceManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPNotificationCenter.h"

#import "CPProcessManager.h"
#import "CPDraggingPassCellProcess.h"
#import "CPRemovingPassCellProcess.h"

@interface CPPassCellManager ()

@property (weak, nonatomic) CPViewManager<CPPassCellDelegate> *delegate;

@property (weak, nonatomic) UIView *frontLayer;
@property (weak, nonatomic) UIView *backLayer;

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

- (void)createGestureRecognizers;

- (void)handleEditingGesture:(UITapGestureRecognizer *)tapGestureRecognizer;
- (void)handleCopyPasswordGesture:(UITapGestureRecognizer *)tapGestureRecognizer;
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture;
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture;

@end

@implementation CPPassCellManager

- (id)initWithSupermanager:(CPViewManager<CPPassCellDelegate> *)supermanager superview:(UIView *)superview frontLayer:(UIView *)frontLayer backLayer:(UIView *)backLayer andIndex:(NSUInteger)index {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        self.delegate = supermanager;
        self.frontLayer = frontLayer;
        self.backLayer = backLayer;
        self.index = index;
    }
    return self;
}

- (UIColor *)backgroundColor {
    return self.passCellView.backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.passCellView.backgroundColor = backgroundColor;
}

- (void)setAlpha:(CGFloat)alpha {
    self.passCellView.alpha = alpha;
    self.iconImage.alpha = alpha;
}

- (void)setHidden:(BOOL)hidden {
    self.passCellView.hidden = hidden;
    self.iconImage.hidden = hidden;
}

- (void)setIcon:(NSString *)icon {
    self.iconImage.image = [UIImage imageNamed:icon];
}

- (void)loadAnimated:(BOOL)animated {
    [super loadAnimated:animated];
    
    [self.backLayer addSubview:self.passCellView];
    [self.frontLayer addSubview:self.iconView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.iconView edgesAlignToView:self.passCellView]];
    
    [self.iconView addSubview:self.iconImage];
    [self.iconView addConstraints:self.iconImagePositionConstraints];
    
    [self createGestureRecognizers];
}

- (void)createGestureRecognizers {
    UITapGestureRecognizer *editing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditingGesture:)];
    editing.numberOfTapsRequired = EDITING_TAP_NUMBER;
    [self.iconView addGestureRecognizer:editing];
    
    UITapGestureRecognizer *copyPassword = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCopyPasswordGesture:)];
    copyPassword.numberOfTapsRequired = COPY_PASSWORD_TAP_NUMBER;
    [self.iconView addGestureRecognizer:copyPassword];
    
    if (EDITING_TAP_NUMBER < COPY_PASSWORD_TAP_NUMBER) {
        [editing requireGestureRecognizerToFail:copyPassword];
    } else {
        [copyPassword requireGestureRecognizerToFail:editing];
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPress.delegate = self;
    [self.iconView addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    pan.delegate = self;
    [self.iconView addGestureRecognizer:pan];
}

- (void)handleEditingGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.delegate tapPassCell:self];
}

- (void)handleCopyPasswordGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    // TODO: Not copy to clipboard if password is not used.
    [UIPasteboard generalPasteboard].string = ((CPPassword *)[[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index]).text;
    [CPNotificationCenter insertNotification:[NSString stringWithFormat:@"Password No %d copied to clipboard.", self.index]];
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
            [self.passCellView addSubview:self.removingView];
            CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
            self.passCellView.backgroundColor = password.reversedColor;

            [self.passCellView addConstraints:self.removingConstraints];
            [self.passCellView layoutIfNeeded];
            
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
                    
                    [self.removingIconContainer1 addSubview:self.removingIcon1];
                    [self.removingIconContainer2 addSubview:self.removingIcon2];
                    
                    [self.removingIconContainer1 addConstraints:[CPAppearanceManager constraintsWithView:self.removingIcon1 centerAlignToView:self.removingIconContainer1]];
                    [self.removingIconContainer2 addConstraints:[CPAppearanceManager constraintsWithView:self.removingIcon2 centerAlignToView:self.removingIconContainer2]];
                    
                    NSLayoutConstraint *iconWidthConstraint1 = [CPAppearanceManager constraintWithView:self.removingIconContainer1 alignToView:self.iconView attribute:NSLayoutAttributeWidth];
                    [self.iconView addConstraint:iconWidthConstraint1];
                    NSLayoutConstraint *iconWidthConstraint2 = [CPAppearanceManager constraintWithView:self.removingIconContainer2 alignToView:self.iconView attribute:NSLayoutAttributeWidth];
                    [self.iconView addConstraint:iconWidthConstraint2];
                    NSLayoutConstraint *iconHeightConstraint1 = [CPAppearanceManager constraintWithView:self.removingIconContainer1 alignToView:self.iconView attribute:NSLayoutAttributeHeight];
                    [self.iconView addConstraint:iconHeightConstraint1];
                    NSLayoutConstraint *iconHeightConstraint2 = [CPAppearanceManager constraintWithView:self.removingIconContainer2 alignToView:self.iconView attribute:NSLayoutAttributeHeight];
                    [self.iconView addConstraint:iconHeightConstraint2];
                    
                    [self.iconView addSubview:self.removingLabel1];
                    [self.iconView addSubview:self.removingLabel2];
                    
                    NSLayoutConstraint *icon1Constraint, *icon2Constraint, *iconCenterConstraint1, *iconCenterConstraint2;
                    
                    if (fabsf(translation.x) > fabsf(translation.y)) {
                        self.removingDirection = 1;
                        
                        icon1Constraint = [CPAppearanceManager constraintWithView:self.removingIconContainer1 attribute:NSLayoutAttributeRight alignToView:self.iconView attribute:NSLayoutAttributeLeft];
                        [self.iconView addConstraint:icon1Constraint];
                        icon2Constraint = [CPAppearanceManager constraintWithView:self.removingIconContainer2 attribute:NSLayoutAttributeLeft alignToView:self.iconView attribute:NSLayoutAttributeRight];
                        [self.iconView addConstraint:icon2Constraint];
                        iconCenterConstraint1 = [CPAppearanceManager constraintWithView:self.removingIconContainer1 alignToView:self.iconView attribute:NSLayoutAttributeCenterY];
                        [self.iconView addConstraint:iconCenterConstraint1];
                        iconCenterConstraint2 = [CPAppearanceManager constraintWithView:self.removingIconContainer2 alignToView:self.iconView attribute:NSLayoutAttributeCenterY];
                        [self.iconView addConstraint:iconCenterConstraint2];
                        
                        [self.removingLabel1 setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                        [self.removingLabel2 setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                        
                        NSLayoutConstraint *labelCenterConstraint1 = [CPAppearanceManager constraintWithView:self.removingLabel1 alignToView:self.iconView attribute:NSLayoutAttributeCenterY];
                        [self.iconView addConstraint:labelCenterConstraint1];
                        NSLayoutConstraint *labelCenterConstraint2 = [CPAppearanceManager constraintWithView:self.removingLabel2 alignToView:self.iconView attribute:NSLayoutAttributeCenterY];
                        [self.iconView addConstraint:labelCenterConstraint2];
                        NSLayoutConstraint *labelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.removingLabel1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE];
                        [self.iconView addConstraint:labelLeftConstraint];
                        NSLayoutConstraint *labelRightConstraint = [NSLayoutConstraint constraintWithItem:self.removingLabel2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeRight multiplier:1.0 constant:PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE];
                        [self.iconView addConstraint:labelRightConstraint];
                        self.removingLabelConstraints = [NSArray arrayWithObjects:labelLeftConstraint, labelRightConstraint, labelCenterConstraint1, labelCenterConstraint2, nil];
                    } else {
                        self.removingDirection = 0;

                        icon1Constraint = [CPAppearanceManager constraintWithView:self.removingIconContainer1 attribute:NSLayoutAttributeBottom alignToView:self.iconView attribute:NSLayoutAttributeTop];
                        [self.iconView addConstraint:icon1Constraint];
                        icon2Constraint = [CPAppearanceManager constraintWithView:self.removingIconContainer2 attribute:NSLayoutAttributeTop alignToView:self.iconView attribute:NSLayoutAttributeBottom];
                        [self.iconView addConstraint:icon2Constraint];
                        iconCenterConstraint1 = [CPAppearanceManager constraintWithView:self.removingIconContainer1 alignToView:self.iconView attribute:NSLayoutAttributeCenterX];
                        [self.iconView addConstraint:iconCenterConstraint1];
                        iconCenterConstraint2 = [CPAppearanceManager constraintWithView:self.removingIconContainer2 alignToView:self.iconView attribute:NSLayoutAttributeCenterX];
                        [self.iconView addConstraint:iconCenterConstraint2];
                        
                        NSLayoutConstraint *labelCenterConstraint1 = [CPAppearanceManager constraintWithView:self.removingLabel1 alignToView:self.iconView attribute:NSLayoutAttributeCenterX];
                        [self.iconView addConstraint:labelCenterConstraint1];
                        NSLayoutConstraint *labelCenterConstraint2 = [CPAppearanceManager constraintWithView:self.removingLabel2 alignToView:self.iconView attribute:NSLayoutAttributeCenterX];
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
                    constant = abs(translation.x) > self.passCellView.bounds.size.width ? translation.x >= 0 ? self.passCellView.bounds.size.width : -self.passCellView.bounds.size.width : translation.x;
                    if (abs(translation.x) < self.passCellView.bounds.size.width / 2) {
                        self.removingLabel1.text = swipe;
                        self.removingLabel2.text = swipe;
                    } else {
                        self.removingLabel1.text = release;
                        self.removingLabel2.text = release;
                    }
                } else {
                    constant = abs(translation.y) > self.passCellView.bounds.size.height ? translation.y >= 0 ? self.passCellView.bounds.size.height : -self.passCellView.bounds.size.height : translation.y;
                    if (abs(translation.y) < self.passCellView.bounds.size.height / 2) {
                        self.removingLabel1.text = swipe;
                        self.removingLabel2.text = swipe;
                    } else {
                        self.removingLabel1.text = release;
                        self.removingLabel2.text = release;
                    }
                }
                ((NSLayoutConstraint *)[self.removingConstraints objectAtIndex:self.removingDirection]).constant = constant;
                ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:1 - self.removingDirection]).constant = constant;
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
                if ((self.removingDirection && abs(translation.x) >= self.passCellView.bounds.size.width / 2) || (!self.removingDirection && abs(translation.y) >= self.passCellView.bounds.size.height / 2)) {
                    if ([[CPPassDataManager defaultManager] canToggleRemoveStateOfPasswordAtIndex:self.index]) {
                        float constant = 0;
                        if (self.removingDirection) {
                            constant = translation.x >= 0 ? self.passCellView.bounds.size.width : -self.passCellView.bounds.size.width;
                        } else {
                            constant = translation.y >= 0 ? self.passCellView.bounds.size.height : -self.passCellView.bounds.size.height;
                        }
                        ((NSLayoutConstraint *)[self.removingConstraints objectAtIndex:self.removingDirection]).constant = constant;
                        ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:1 - self.removingDirection]).constant = constant;
                        ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:0]).constant = constant;
                        ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:1]).constant = constant;
                        ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:0]).constant = constant - PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                        ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:1]).constant = constant + PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                        [CPAppearanceManager animateWithDuration:0.3 animations:^{
                            [self.superview.superview layoutIfNeeded];
                            self.removingLabel1.alpha = 0.0;
                            self.removingLabel2.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            [self.passCellView removeConstraints:self.removingConstraints];
                            
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
                            ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:1 - self.removingDirection]).constant = 0.0;
                            
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
                        ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:1 - self.removingDirection]).constant = 0.0;
                        ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:0]).constant = 0.0;
                        ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:1]).constant = 0.0;
                        ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:0]).constant = -PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                        ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:1]).constant = PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                        [CPAppearanceManager animateWithDuration:0.3 animations:^{
                            [self.superview.superview layoutIfNeeded];
                        } completion:^(BOOL finished) {
                            CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
                            self.passCellView.backgroundColor = password.displayColor;
                            
                            [self.passCellView removeConstraints:self.removingConstraints];
                            
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
                    ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:1 - self.removingDirection]).constant = 0.0;
                    ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:0]).constant = 0.0;
                    ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:1]).constant = 0.0;
                    ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:0]).constant = -PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                    ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:1]).constant = PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
                    [CPAppearanceManager animateWithDuration:0.3 animations:^{
                        [self.superview.superview layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
                        self.passCellView.backgroundColor = password.displayColor;
                        
                        [self.passCellView removeConstraints:self.removingConstraints];
                        
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

#pragma mark - UIGestureRecognizerDelegate implement

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) || ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])) {
        return YES;
    } else {
        return NO;
    }
}

#pragma - mark mark lazy init

- (UIView *)passCellView {
    if (!_passCellView) {
        _passCellView = [[UIView alloc] init];
        _passCellView.clipsToBounds = YES;
        _passCellView.translatesAutoresizingMaskIntoConstraints = NO;
        
        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
        _passCellView.backgroundColor = password.displayColor;
    }
    return _passCellView;
}

- (UIImageView *)iconImage {
    if (!_iconImage) {
        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
        _iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:password.displayIcon]];
        _iconImage.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _iconImage;
}

- (UIView *)iconView {
    if (!_iconView) {
        _iconView = [[UIView alloc] init];
        _iconView.clipsToBounds = YES;
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _iconView;
}

- (NSArray *)iconImagePositionConstraints {
    if (!_iconImagePositionConstraints) {
        _iconImagePositionConstraints = [CPAppearanceManager constraintsWithView:self.iconImage centerAlignToView:self.iconView];
    }
    return _iconImagePositionConstraints;
}

- (UIView *)removingView {
    if (!_removingView) {
        _removingView = [[UIView alloc] init];
        self.removingView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // TODO: When removing pass cell, use images instead of single-colored views.
        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
        self.removingView.backgroundColor = password.displayColor;
    }
    return _removingView;
}

- (NSArray *)removingConstraints {
    if (!_removingConstraints) {
        _removingConstraints = [CPAppearanceManager constraintsWithView:self.removingView edgesAlignToView:self.passCellView];
    }
    return _removingConstraints;
}

- (UIView *)removingIconContainer1 {
    if (!_removingIconContainer1) {
        _removingIconContainer1 = [[UIView alloc] init];
        _removingIconContainer1.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _removingIconContainer1;
}

- (UIView *)removingIconContainer2 {
    if (!_removingIconContainer2) {
        _removingIconContainer2 = [[UIView alloc] init];
        _removingIconContainer2.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _removingIconContainer2;
}

- (UIImageView *)removingIcon1 {
    if (!_removingIcon1) {
        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
        _removingIcon1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:password.reversedIcon]];
        _removingIcon1.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _removingIcon1;
}

- (UIImageView *)removingIcon2 {
    if (!_removingIcon2) {
        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
        _removingIcon2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:password.reversedIcon]];
        _removingIcon2.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _removingIcon2;
}

- (UILabel *)removingLabel1 {
    if (!_removingLabel1) {
        // TODO: Adjust font of pass cell removing label.        
        _removingLabel1 = [[UILabel alloc] init];
        _removingLabel1.textColor = [UIColor whiteColor];
        _removingLabel1.backgroundColor = [UIColor clearColor];
        _removingLabel1.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _removingLabel1;
}

- (UILabel *)removingLabel2 {
    if (!_removingLabel2) {
        _removingLabel2 = [[UILabel alloc] init];
        _removingLabel2.textColor = [UIColor whiteColor];
        _removingLabel2.backgroundColor = [UIColor clearColor];
        _removingLabel2.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _removingLabel2;
}

@end
