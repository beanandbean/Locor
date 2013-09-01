//
//  CPNotificationCenter.m
//  Passone
//
//  Created by wangsw on 6/28/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPNotificationCenter.h"

#import "CPPassoneConfig.h"

#import "CPAppearanceManager.h"

static CPNotificationCenter *center;

@interface CPNotificationCenter ()

@property (nonatomic) float bottomHeight;
@property (nonatomic) int forceRemovedCount;
@property (weak, nonatomic) UIView *superView;
@property (strong, nonatomic) UILabel *notification;
@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *rightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;

@end

@implementation CPNotificationCenter

+ (void)createNotificationCenterWithSuperView:(UIView *)superView {
    center = [[CPNotificationCenter alloc] initWithSuperView:superView];
}

+ (void)insertNotification:(NSString *)notification {
    if (center) {
        [center insertNotification:notification];
    }
}

- (id)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        self.bottomHeight = -BOX_SEPARATOR_SIZE;
        self.forceRemovedCount = 0;
        self.superView = superView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidResize:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardDidResize:(NSNotification *)notification {
    NSValue *rectObj = [notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    
    if (rectObj) {
        CGRect rect = rectObj.CGRectValue;
        float transformedY = [self.superView convertPoint:rect.origin fromView:nil].y;
        self.bottomHeight = transformedY - self.superView.frame.size.height - BOX_SEPARATOR_SIZE;
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
            [self.superView layoutIfNeeded];
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
    
    [self.superView addSubview:notificationLabel];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:notificationLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    [self.superView addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:notificationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    [self.superView addConstraint:rightConstraint];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:notificationLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.bottomHeight];
    [self.superView addConstraint:bottomConstraint];
    
    CGSize maximumLabelSize = CGSizeMake(self.superView.bounds.size.width - BOX_SEPARATOR_SIZE * 2, FLT_MAX);
    CGSize expectedLabelSize = [notification sizeWithFont:notificationLabel.font constrainedToSize:maximumLabelSize lineBreakMode:notificationLabel.lineBreakMode];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:notificationLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:expectedLabelSize.height + 10.0];
    [notificationLabel addConstraint:heightConstraint];

    [self.superView layoutIfNeeded];
        
    [self.superView removeConstraint:leftConstraint];
    leftConstraint = [CPAppearanceManager constraintWithItem:notificationLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeLeft];
    [self.superView addConstraint:leftConstraint];
    
    [self.superView removeConstraint:rightConstraint];
    rightConstraint = [CPAppearanceManager constraintWithItem:notificationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight];
    [self.superView addConstraint:rightConstraint];
    
    NSLayoutConstraint *oldRightConstraint, *widthConstraint;
    if (self.notification) {
        oldRightConstraint = [NSLayoutConstraint constraintWithItem:self.notification attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        
        widthConstraint = [NSLayoutConstraint constraintWithItem:self.notification attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:self.notification.frame.size.width];
        
        [self.superView removeConstraint:self.leftConstraint];
        [self.superView removeConstraint:self.rightConstraint];
        [self.superView addConstraint:oldRightConstraint];
        [self.superView addConstraint:widthConstraint];
    }
    
    // Not protectiong the animation which doesn't affect main view
    [UIView animateWithDuration:0.5 animations:^{
        [self.superView layoutIfNeeded];
    }completion:^(BOOL finished){        
        if (self.notification) {
            self.forceRemovedCount++;
            [self.superView removeConstraint:oldRightConstraint];
            [self.superView removeConstraint:widthConstraint];
            [self.superView removeConstraint:self.bottomConstraint];
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
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.notification attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.notification attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:self.notification.frame.size.width];
        
        [self.superView removeConstraint:self.leftConstraint];
        [self.superView removeConstraint:self.rightConstraint];
        [self.superView addConstraint:rightConstraint];
        [self.superView addConstraint:widthConstraint];
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.superView layoutIfNeeded];
        }completion:^(BOOL finished){
            [self.superView removeConstraint:rightConstraint];
            [self.superView removeConstraint:widthConstraint];
            [self.superView removeConstraint:self.bottomConstraint];
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
