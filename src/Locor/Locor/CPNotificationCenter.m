//
//  CPNotificationCenter.m
//  Locor
//
//  Created by wangsw on 6/28/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPNotificationCenter.h"

#import "CPLocorConfig.h"
#import "CPAppearanceManager.h"

@interface CPNotificationCenter ()

@property (nonatomic) float bottomHeight;
@property (nonatomic) int forceRemovedCount;
@property (strong, nonatomic) UILabel *notification;
@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *rightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;

@end

@implementation CPNotificationCenter

static CPNotificationCenter *_center;

+ (void)insertNotification:(NSString *)notification {
    NSAssert(_center, @"");
    [_center insertNotification:notification];
}

- (id)initWithSupermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        NSAssert(!_center, @"Can only create one notification center");
        _center = self;
        self.bottomHeight = -BOX_SEPARATOR_SIZE;
        self.forceRemovedCount = 0;
    }
    return self;
}

- (void)loadAnimated:(BOOL)animated {
    [super loadAnimated:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidResize:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)unloadAnimated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [super unloadAnimated:animated];
}

- (void)keyboardDidResize:(NSNotification *)notification {
    NSValue *rectObj = [notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    
    if (rectObj) {
        CGRect rect = rectObj.CGRectValue;
        float transformedY = [self.superview convertPoint:rect.origin fromView:nil].y;
        self.bottomHeight = transformedY - self.superview.frame.size.height - BOX_SEPARATOR_SIZE;
    } else {
        self.bottomHeight = -BOX_SEPARATOR_SIZE;
    }
    [self refreshBottom];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    // TODO: Not change notification labels' position if keyboard hide and then show immediately.
    
    self.bottomHeight = -BOX_SEPARATOR_SIZE;
    [self refreshBottom];
}

- (void)refreshBottom {
    if (self.bottomConstraint) {
        self.bottomConstraint.constant = self.bottomHeight;
        [UIView animateWithDuration:0.3 animations:^{
            [self.superview layoutIfNeeded];
        }];
    }
}

- (void)insertNotification:(NSString *)notification {
    UILabel *notificationLabel = [[UILabel alloc] init];
    notificationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    notificationLabel.font = [UIFont boldSystemFontOfSize:NOTIFICATION_FONT_SIZE];
    notificationLabel.text = notification;
    notificationLabel.textColor = [UIColor blackColor];
    notificationLabel.textAlignment = NSTextAlignmentCenter;
    notificationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    notificationLabel.numberOfLines = 0;
    notificationLabel.backgroundColor = [UIColor whiteColor];
    
    [self.superview addSubview:notificationLabel];
    
    NSLayoutConstraint *leftConstraint = [CPAppearanceManager constraintWithView:notificationLabel attribute:NSLayoutAttributeLeft alignToView:self.superview attribute:NSLayoutAttributeRight];
    [self.superview addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [CPAppearanceManager constraintWithView:notificationLabel alignToView:self.superview attribute:NSLayoutAttributeRight];
    [self.superview addConstraint:rightConstraint];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:notificationLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.bottomHeight];
    [self.superview addConstraint:bottomConstraint];
    
    CGSize maximumLabelSize = CGSizeMake(self.superview.bounds.size.width - BOX_SEPARATOR_SIZE * 2, FLT_MAX);
    CGSize expectedLabelSize = [notification sizeWithFont:notificationLabel.font constrainedToSize:maximumLabelSize lineBreakMode:notificationLabel.lineBreakMode];
    NSLayoutConstraint *heightConstraint = [CPAppearanceManager constraintWithView:notificationLabel height:expectedLabelSize.height + 10.0];
    [notificationLabel addConstraint:heightConstraint];

    [self.superview layoutIfNeeded];
        
    [self.superview removeConstraint:leftConstraint];
    leftConstraint = [CPAppearanceManager constraintWithItem:notificationLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeLeft];
    [self.superview addConstraint:leftConstraint];
    
    [self.superview removeConstraint:rightConstraint];
    rightConstraint = [CPAppearanceManager constraintWithItem:notificationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight];
    [self.superview addConstraint:rightConstraint];
    
    NSLayoutConstraint *oldRightConstraint, *widthConstraint;
    if (self.notification) {
        oldRightConstraint = [CPAppearanceManager constraintWithView:self.notification attribute:NSLayoutAttributeRight alignToView:self.superview attribute:NSLayoutAttributeLeft];

        widthConstraint = [CPAppearanceManager constraintWithView:self.notification width:self.notification.frame.size.width];
        
        [self.superview removeConstraint:self.leftConstraint];
        [self.superview removeConstraint:self.rightConstraint];
        [self.superview addConstraint:oldRightConstraint];
        [self.superview addConstraint:widthConstraint];
    }
    
    // Not protectiong the animation which doesn't affect main view
    [UIView animateWithDuration:0.5 animations:^{
        [self.superview layoutIfNeeded];
    }completion:^(BOOL finished){        
        if (self.notification) {
            self.forceRemovedCount++;
            [self.superview removeConstraint:oldRightConstraint];
            [self.superview removeConstraint:widthConstraint];
            [self.superview removeConstraint:self.bottomConstraint];
            [self.notification removeFromSuperview];
        }
        
        self.notification = notificationLabel;
        self.leftConstraint = leftConstraint;
        self.rightConstraint = rightConstraint;
        self.bottomConstraint = bottomConstraint;
        
        [NSTimer scheduledTimerWithTimeInterval:NOTIFICATION_STAY_TIME target:self selector:@selector(notificationFired:) userInfo:notificationLabel repeats:NO];
    }];
}

- (void)removeNotification {
    if (self.forceRemovedCount) {
        self.forceRemovedCount--;
    } else if (self.notification) {
        NSLayoutConstraint *rightConstraint = [CPAppearanceManager constraintWithView:self.notification attribute:NSLayoutAttributeRight alignToView:self.superview attribute:NSLayoutAttributeLeft];
        
        NSLayoutConstraint *widthConstraint = [CPAppearanceManager constraintWithView:self.notification width:self.notification.frame.size.width];
        
        [self.superview removeConstraint:self.leftConstraint];
        [self.superview removeConstraint:self.rightConstraint];
        [self.superview addConstraint:rightConstraint];
        [self.superview addConstraint:widthConstraint];
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.superview layoutIfNeeded];
        }completion:^(BOOL finished){
            [self.superview removeConstraint:rightConstraint];
            [self.superview removeConstraint:widthConstraint];
            [self.superview removeConstraint:self.bottomConstraint];
            [self.notification removeFromSuperview];
            
            self.notification = nil;
            self.leftConstraint = nil;
            self.rightConstraint = nil;
            self.bottomConstraint = nil;
        }];
    }
}

- (void)notificationFired:(NSTimer *)timer {
    [self removeNotification];
}

@end
