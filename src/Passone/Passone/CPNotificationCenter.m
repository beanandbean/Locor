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
@property (strong, nonatomic) NSMutableArray *notifications;
@property (strong, nonatomic) NSMutableArray *views;
@property (strong, nonatomic) NSMutableArray *leftConstraints;
@property (strong, nonatomic) NSMutableArray *rightConstraints;
@property (strong, nonatomic) NSMutableArray *bottomConstraints;

- (id)initWithSuperView:(UIView *)superView;

- (void)insertNotification:(NSString *)notification;

- (void)removeNotification:(UIView *)notification forced:(BOOL)isForced;

- (void)notificationFired:(NSTimer *)timer;

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
        self.notifications = [[NSMutableArray alloc] init];
        self.views = [[NSMutableArray alloc] init];
        self.leftConstraints = [[NSMutableArray alloc] init];
        self.rightConstraints = [[NSMutableArray alloc] init];
        self.bottomConstraints = [[NSMutableArray alloc] init];
        
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
    if (self.bottomConstraints.count) {
        ((NSLayoutConstraint *)[self.bottomConstraints lastObject]).constant = self.bottomHeight;
        [UIView animateWithDuration:0.3 animations:^{
            [self.superView layoutIfNeeded];
        }];
    }
}

- (void)insertNotification:(NSString *)notification {
    // TODO: Adjust appearance of notification labels.

    [self.notifications addObject:notification];
    
    UILabel *notificationLabel = [[UILabel alloc] init];
    notificationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    notificationLabel.text = notification;
    notificationLabel.textColor = [UIColor blackColor];
    notificationLabel.textAlignment = NSTextAlignmentCenter;
    notificationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    notificationLabel.numberOfLines = 0;
    notificationLabel.backgroundColor = [UIColor whiteColor];
    notificationLabel.alpha = 0.0;
    
    [self.superView addSubview:notificationLabel];
    [self.views addObject:notificationLabel];
    
    NSLayoutConstraint *leftConstraint = [CPAppearanceManager constraintWithItem:notificationLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeLeft];
    [self.superView addConstraint:leftConstraint];
    [self.leftConstraints addObject:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [CPAppearanceManager constraintWithItem:notificationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight];
    [self.superView addConstraint:rightConstraint];
    [self.rightConstraints addObject:rightConstraint];
    
    [self.superView layoutIfNeeded];
    
    CGSize maximumLabelSize = CGSizeMake(notificationLabel.bounds.size.width, FLT_MAX);
    CGSize expectedLabelSize = [notification sizeWithFont:notificationLabel.font constrainedToSize:maximumLabelSize lineBreakMode:notificationLabel.lineBreakMode];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:notificationLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:expectedLabelSize.height + 10.0];
    [notificationLabel addConstraint:heightConstraint];
    [self.superView layoutIfNeeded];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:notificationLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.bottomHeight];
    [self.superView addConstraint:bottomConstraint];
    [self.bottomConstraints addObject:bottomConstraint];
    
    if (self.views.count > 1) {
        [self.superView removeConstraint:[self.bottomConstraints objectAtIndex:self.views.count - 2]];
        NSLayoutConstraint *secondBottomConstraint = [NSLayoutConstraint constraintWithItem:[self.views objectAtIndex:self.views.count - 2] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:notificationLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:-BOX_SEPARATOR_SIZE];
        [self.superView addConstraint:secondBottomConstraint];
        [self.bottomConstraints replaceObjectAtIndex:self.views.count - 2 withObject:secondBottomConstraint];
    }
    
    // TODO: BUG! When notifications come too fast, upper notifications will be removed without animation.
    if (NOTIFICATION_MAX_COUNT < self.notifications.count) {
        for (int i = NOTIFICATION_MAX_COUNT; i < self.notifications.count; i++) {
            [self removeNotification:(UIView *)[self.views objectAtIndex:i - NOTIFICATION_MAX_COUNT] forced:YES];
        }
    }
    
    // Not protectiong the animation which doesn't affect main view
    [UIView animateWithDuration:0.5 animations:^{
        [self.superView layoutIfNeeded];
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 animations:^{
            notificationLabel.alpha = 1.0;
        }completion:^(BOOL finished){
            [NSTimer scheduledTimerWithTimeInterval:NOTIFICATION_STAY_TIME target:self selector:@selector(notificationFired:) userInfo:notificationLabel repeats:NO];
        }];
    }];
}

- (void)removeNotification:(UIView *)notification forced:(BOOL)isForced {
    if (isForced) {
        self.forceRemovedCount++;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        notification.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.superView removeConstraint:[self.leftConstraints objectAtIndex:0]];
            [self.leftConstraints removeObjectAtIndex:0];
            
            [self.superView removeConstraint:[self.rightConstraints objectAtIndex:0]];
            [self.rightConstraints removeObjectAtIndex:0];
            
            [self.superView removeConstraint:[self.bottomConstraints objectAtIndex:0]];
            [self.bottomConstraints removeObjectAtIndex:0];
            
            [[self.views objectAtIndex:0] removeFromSuperview];
            [self.views removeObjectAtIndex:0];
            
            [self.superView layoutIfNeeded];
            [self.notifications removeObjectAtIndex:0];
        } else {
            [self removeNotification:notification forced:NO];
        }
    }];
}

- (void)notificationFired:(NSTimer *)timer {
    if (self.forceRemovedCount) {
        self.forceRemovedCount--;
    } else {
        [self removeNotification:(UIView *)timer.userInfo forced:NO];
    }
}

@end
