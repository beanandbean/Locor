//
//  CPPassCellManager.m
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

enum REMOVING_DIRECTION {
    REMOVING_DIRECTION_NONE = -1,
    REMOVING_DIRECTION_HORIZONTAL = 0,
    REMOVING_DIRECTION_VERTICAL
};

@interface CPPassCellManager ()

@property (weak, readonly, nonatomic) CPViewManager<CPPassCellDelegate> *delegate;

@property (weak, readonly, nonatomic) UIView *frontLayer;
@property (weak, readonly, nonatomic) UIView *backLayer;

@property (weak, nonatomic) CPPassword *password;

@property (strong, nonatomic) UIView *iconView;
@property (strong, nonatomic) NSArray *iconImagePositionConstraints;

@property (nonatomic) int removingDirection;

@property (strong, nonatomic) UIView *removingView;
@property (strong, nonatomic) NSArray *removingViewPositionConstraints;

@property (strong, nonatomic) UIView *removingIconContainer1;
@property (strong, nonatomic) UIView *removingIconContainer2;
@property (strong, nonatomic) UIImageView *removingIcon1;
@property (strong, nonatomic) UIImageView *removingIcon2;
@property (strong, nonatomic) NSArray *removingIconConstraints;

@property (strong, nonatomic) UILabel *removingLabel1;
@property (strong, nonatomic) UILabel *removingLabel2;
@property (strong, nonatomic) NSArray *removingLabelConstraints;

@end

@implementation CPPassCellManager

- (id)initWithSupermanager:(CPViewManager<CPPassCellDelegate> *)supermanager superview:(UIView *)superview frontLayer:(UIView *)frontLayer backLayer:(UIView *)backLayer andIndex:(NSUInteger)index {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        _delegate = supermanager;
        _frontLayer = frontLayer;
        _backLayer = backLayer;
        _index = index;
        self.password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    }
    return self;
}

- (void)refreshAppearance {
    self.password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    self.passCellView.backgroundColor = self.password.displayColor;
    self.iconImage.image = [UIImage imageNamed:self.password.displayIcon];
}

- (void)setAlpha:(CGFloat)alpha {
    self.passCellView.alpha = alpha;
    self.iconImage.alpha = alpha;
}

- (void)setHidden:(BOOL)hidden {
    self.passCellView.hidden = hidden;
    self.iconImage.hidden = hidden;
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

- (void)createRemovingViews {    
    [self.passCellView addSubview:self.removingView];
    self.passCellView.backgroundColor = self.password.reversedColor;
    [self.passCellView addConstraints:self.removingViewPositionConstraints];
    [self.passCellView addConstraints:[CPAppearanceManager constraintsWithView:self.removingView alignToView:self.passCellView attribute:NSLayoutAttributeWidth, NSLayoutAttributeHeight, ATTR_END]];
    
    [self.removingIconContainer1 addSubview:self.removingIcon1];
    [self.removingIconContainer2 addSubview:self.removingIcon2];
    [self.iconView addSubview:self.removingIconContainer1];
    [self.iconView addSubview:self.removingIconContainer2];
    [self.iconView addSubview:self.removingLabel1];
    [self.iconView addSubview:self.removingLabel2];
    
    [self.removingIconContainer1 addConstraints:[CPAppearanceManager constraintsWithView:self.removingIcon1 centerAlignToView:self.removingIconContainer1]];
    [self.removingIconContainer2 addConstraints:[CPAppearanceManager constraintsWithView:self.removingIcon2 centerAlignToView:self.removingIconContainer2]];
    [self.iconView addConstraints:self.removingIconConstraints];
    [self.iconView addConstraints:self.removingLabelConstraints];
    [self.iconView addConstraints:[CPAppearanceManager constraintsWithView:self.removingIconContainer1 alignToView:self.iconView attribute:NSLayoutAttributeWidth, NSLayoutAttributeHeight, ATTR_END]];
    [self.iconView addConstraints:[CPAppearanceManager constraintsWithView:self.removingIconContainer2 alignToView:self.iconView attribute:NSLayoutAttributeWidth, NSLayoutAttributeHeight, ATTR_END]];

    switch (self.removingDirection) {
        case REMOVING_DIRECTION_HORIZONTAL:
            [self.iconView addConstraints:[NSArray arrayWithObjects:
                                           [CPAppearanceManager constraintWithView:self.removingIconContainer1 alignToView:self.iconView attribute:NSLayoutAttributeCenterY],
                                           [CPAppearanceManager constraintWithView:self.removingIconContainer2 alignToView:self.iconView attribute:NSLayoutAttributeCenterY],
                                           nil]];
            [self.iconView addConstraints:[NSArray arrayWithObjects:
                                           [CPAppearanceManager constraintWithView:self.removingLabel1 alignToView:self.iconView attribute:NSLayoutAttributeCenterY],
                                           [CPAppearanceManager constraintWithView:self.removingLabel2 alignToView:self.iconView attribute:NSLayoutAttributeCenterY],
                                           nil]];
            break;
        case REMOVING_DIRECTION_VERTICAL:
            [self.iconView addConstraints:[NSArray arrayWithObjects:
                                           [CPAppearanceManager constraintWithView:self.removingIconContainer1 alignToView:self.iconView attribute:NSLayoutAttributeCenterX],
                                           [CPAppearanceManager constraintWithView:self.removingIconContainer2 alignToView:self.iconView attribute:NSLayoutAttributeCenterX],
                                           nil]];
            [self.iconView addConstraints:[NSArray arrayWithObjects:
                                           [CPAppearanceManager constraintWithView:self.removingLabel1 alignToView:self.iconView attribute:NSLayoutAttributeCenterX],
                                           [CPAppearanceManager constraintWithView:self.removingLabel2 alignToView:self.iconView attribute:NSLayoutAttributeCenterX],
                                           nil]];
            break;
        default:
            NSAssert(NO, @"");
            break;
    }
}

- (void)removeRemovingViews {
    [self.removingView removeFromSuperview];
    [self.removingIconContainer1 removeFromSuperview];
    [self.removingIconContainer2 removeFromSuperview];
    [self.removingLabel1 removeFromSuperview];
    [self.removingLabel2 removeFromSuperview];
    
    self.removingDirection = REMOVING_DIRECTION_NONE;
    self.removingView = nil;
    self.removingIconContainer1 = nil;
    self.removingIconContainer2 = nil;
    self.removingIcon1 = nil;
    self.removingIcon2 = nil;
    self.removingLabel1 = nil;
    self.removingLabel2 = nil;
    self.removingViewPositionConstraints = nil;
    self.removingIconConstraints = nil;
    self.removingLabelConstraints = nil;
}

- (void)updateRemovingConstraintsByConstant:(float)constant {
    NSAssert(self.removingDirection == REMOVING_DIRECTION_HORIZONTAL || self.removingDirection == REMOVING_DIRECTION_VERTICAL, @"");
    
    ((NSLayoutConstraint *)[self.removingViewPositionConstraints objectAtIndex:self.removingDirection]).constant = constant;
    ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:self.removingDirection]).constant = constant;
    ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:0]).constant = constant;
    ((NSLayoutConstraint *)[self.removingIconConstraints objectAtIndex:1]).constant = constant;
    ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:0]).constant = constant - PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
    ((NSLayoutConstraint *)[self.removingLabelConstraints objectAtIndex:1]).constant = constant + PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE;
}

- (void)handleEditingGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.delegate tapPassCell:self];
}

- (void)handleCopyPasswordGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    // TODO: Not copy to clipboard if password is not used.
    [UIPasteboard generalPasteboard].string = self.password.text;
    [CPNotificationCenter insertNotification:[NSString stringWithFormat:@"Password No %d copied to clipboard.", self.index]];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [CPProcessManager startProcess:DRAGGING_PASS_CELL_PROCESS withPreparation:^{
            [self.delegate startDragPassCell:self];
        }];
    } else if (longPressGesture.state == UIGestureRecognizerStateEnded || longPressGesture.state == UIGestureRecognizerStateCancelled || longPressGesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_CELL_PROCESS) && [self.delegate canStopDragPassCell:self]) {
            [CPProcessManager stopProcess:DRAGGING_PASS_CELL_PROCESS withPreparation:^{
                [self.delegate stopDragPassCell:self];
            }];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [CPProcessManager startProcess:REMOVING_PASS_CELL_PROCESS withPreparation:^{
            self.removingDirection = REMOVING_DIRECTION_NONE;
        }];
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        if (IS_IN_PROCESS(DRAGGING_PASS_CELL_PROCESS)) {
            CGPoint location = [panGesture locationInView:panGesture.view];
            [self.delegate dragPassCell:self location:location translation:translation];
            [panGesture setTranslation:CGPointZero inView:panGesture.view];
        } else if (IS_IN_PROCESS(REMOVING_PASS_CELL_PROCESS)) {
            if (self.removingDirection == REMOVING_DIRECTION_NONE) {
                if (fabsf(translation.x) > fabsf(translation.y)) {
                    self.removingDirection = REMOVING_DIRECTION_HORIZONTAL;
                    [self.removingLabel1 setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                    [self.removingLabel2 setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                    
                } else {
                    self.removingDirection = REMOVING_DIRECTION_VERTICAL;
                }
                
                [self createRemovingViews];
            }
            
            // TODO: Change behavior of pass cell removing view & label if cannot toggle remove state.
            
            float constant = 0.0;
            NSString *action;
            if (self.password.isUsed.boolValue) {
                action = @"remove";
            } else {
                action = @"recover";
            }
            NSString *swipe = [NSString stringWithFormat:@"Swipe to %@", action];
            NSString *release = [NSString stringWithFormat:@"Release to %@", action];
            switch (self.removingDirection) {
                case REMOVING_DIRECTION_HORIZONTAL:
                    constant = abs(translation.x) > self.passCellView.bounds.size.width ? translation.x >= 0 ? self.passCellView.bounds.size.width : -self.passCellView.bounds.size.width : translation.x;
                    if (abs(translation.x) < self.passCellView.bounds.size.width / 2) {
                        self.removingLabel1.text = swipe;
                        self.removingLabel2.text = swipe;
                    } else {
                        self.removingLabel1.text = release;
                        self.removingLabel2.text = release;
                    }
                    break;
                case REMOVING_DIRECTION_VERTICAL:
                    constant = abs(translation.y) > self.passCellView.bounds.size.height ? translation.y >= 0 ? self.passCellView.bounds.size.height : -self.passCellView.bounds.size.height : translation.y;
                    if (abs(translation.y) < self.passCellView.bounds.size.height / 2) {
                        self.removingLabel1.text = swipe;
                        self.removingLabel2.text = swipe;
                    } else {
                        self.removingLabel1.text = release;
                        self.removingLabel2.text = release;
                    }
                    break;
                default:
                    NSAssert(NO, @"");
                    break;
            }
            [self updateRemovingConstraintsByConstant:constant];
            [self.superview layoutIfNeeded];
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_CELL_PROCESS) && [self.delegate canStopDragPassCell:self]) {
            [CPProcessManager stopProcess:DRAGGING_PASS_CELL_PROCESS withPreparation:^{
                [self.delegate stopDragPassCell:self];
            }];
        }
        if (IS_IN_PROCESS(REMOVING_PASS_CELL_PROCESS) && self.removingView) {
            [CPProcessManager stopProcess:REMOVING_PASS_CELL_PROCESS withPreparation:^{
                CGPoint translation = [panGesture translationInView:panGesture.view];
                if ((self.removingDirection == REMOVING_DIRECTION_HORIZONTAL && abs(translation.x) >= self.passCellView.bounds.size.width / 2)
                    || (self.removingDirection == REMOVING_DIRECTION_VERTICAL && abs(translation.y) >= self.passCellView.bounds.size.height / 2)) {
                    if ([[CPPassDataManager defaultManager] canToggleRemoveStateOfPasswordAtIndex:self.index]) {
                        float constant = 0;
                        switch (self.removingDirection) {
                            case REMOVING_DIRECTION_HORIZONTAL:
                                constant = translation.x >= 0 ? self.passCellView.bounds.size.width : -self.passCellView.bounds.size.width;
                                break;
                            case REMOVING_DIRECTION_VERTICAL:
                                constant = translation.y >= 0 ? self.passCellView.bounds.size.height : -self.passCellView.bounds.size.height;
                                break;
                            default:
                                NSAssert(NO, @"");
                                break;
                        }
                        [CPAppearanceManager animateWithDuration:0.3 animations:^{
                            [self updateRemovingConstraintsByConstant:constant];
                            [self.superview layoutIfNeeded];
                            self.removingLabel1.alpha = 0.0;
                            self.removingLabel2.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            self.iconImage.image = self.removingIcon1.image;
                            ((NSLayoutConstraint *)[self.iconImagePositionConstraints objectAtIndex:self.removingDirection]).constant = 0.0;
                            
                            [self removeRemovingViews];
                        }];
                    } else {
                        [CPAppearanceManager animateWithDuration:0.3 animations:^{
                            [self updateRemovingConstraintsByConstant:0.0];
                            [self.superview layoutIfNeeded];
                        } completion:^(BOOL finished) {
                            self.passCellView.backgroundColor = self.password.displayColor;
                            [self removeRemovingViews];
                        }];
                    }
                    [[CPPassDataManager defaultManager] toggleRemoveStateOfPasswordAtIndex:self.index];
                } else {
                    [CPAppearanceManager animateWithDuration:0.3 animations:^{
                        [self updateRemovingConstraintsByConstant:0.0];
                        [self.superview.superview layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        self.passCellView.backgroundColor = self.password.displayColor;
                        [self removeRemovingViews];
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
        _passCellView.backgroundColor = self.password.displayColor;
    }
    return _passCellView;
}

- (UIImageView *)iconImage {
    if (!_iconImage) {
        _iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.password.displayIcon]];
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
        self.removingView.backgroundColor = self.password.displayColor;
    }
    return _removingView;
}

- (NSArray *)removingViewPositionConstraints {
    if (!_removingViewPositionConstraints) {
        _removingViewPositionConstraints = [CPAppearanceManager constraintsWithView:self.removingView centerAlignToView:self.passCellView];
    }
    return _removingViewPositionConstraints;
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
        _removingIcon1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.password.reversedIcon]];
        _removingIcon1.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _removingIcon1;
}

- (UIImageView *)removingIcon2 {
    if (!_removingIcon2) {
        _removingIcon2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.password.reversedIcon]];
        _removingIcon2.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _removingIcon2;
}

- (NSArray *)removingIconConstraints {
    if (!_removingIconConstraints) {
        switch (self.removingDirection) {
            case REMOVING_DIRECTION_HORIZONTAL:
                _removingIconConstraints = [NSArray arrayWithObjects:
                                            [CPAppearanceManager constraintWithView:self.removingIconContainer1 attribute:NSLayoutAttributeRight alignToView:self.iconView attribute:NSLayoutAttributeLeft],
                                            [CPAppearanceManager constraintWithView:self.removingIconContainer2 attribute:NSLayoutAttributeLeft alignToView:self.iconView attribute:NSLayoutAttributeRight],
                                            nil];
                break;
            case REMOVING_DIRECTION_VERTICAL:
                _removingIconConstraints = [NSArray arrayWithObjects:
                                            [CPAppearanceManager constraintWithView:self.removingIconContainer1 attribute:NSLayoutAttributeBottom alignToView:self.iconView attribute:NSLayoutAttributeTop],
                                            [CPAppearanceManager constraintWithView:self.removingIconContainer2 attribute:NSLayoutAttributeTop alignToView:self.iconView attribute:NSLayoutAttributeBottom],
                                            nil];
                break;
            default:
                NSAssert(NO, @"");
                break;
        }
    }
    return _removingIconConstraints;
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

- (NSArray *)removingLabelConstraints {
    if (!_removingLabelConstraints) {
        switch (self.removingDirection) {
            case REMOVING_DIRECTION_HORIZONTAL:
                _removingLabelConstraints = [NSArray arrayWithObjects:
                                             [NSLayoutConstraint constraintWithItem:self.removingLabel1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE],
                                             [NSLayoutConstraint constraintWithItem:self.removingLabel2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeRight multiplier:1.0 constant:PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE],
                                             nil];
                break;
            case REMOVING_DIRECTION_VERTICAL:
                _removingLabelConstraints = [NSArray arrayWithObjects:
                                             [NSLayoutConstraint constraintWithItem:self.removingLabel1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE],
                                             [NSLayoutConstraint constraintWithItem:self.removingLabel2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE],
                                             nil];
                break;
            default:
                break;
        }
    }
    return _removingLabelConstraints;
}

@end
