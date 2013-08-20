//
//  CPNotificationCenter.m
//  Passone
//
//  Created by wangsw on 6/28/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPNotificationCenter.h"

#import "CPAppearanceManager.h"

static CPNotificationCenter *center;

@interface CPNotificationCenter ()

@property (weak, nonatomic) UIView *superView;
@property (strong, nonatomic) NSMutableArray *notifications;
@property (strong, nonatomic) NSMutableArray *views;
@property (strong, nonatomic) NSMutableArray *leftConstraints;
@property (strong, nonatomic) NSMutableArray *rightConstraints;
@property (strong, nonatomic) NSMutableArray *bottomConstraints;

- (id)initWithSuperView:(UIView *)superView;

- (void)insertNotification:(NSString *)notification;

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
        self.superView = superView;
        
        self.notifications = [[NSMutableArray alloc] init];
        self.views = [[NSMutableArray alloc] init];
        self.leftConstraints = [[NSMutableArray alloc] init];
        self.rightConstraints = [[NSMutableArray alloc] init];
        self.bottomConstraints = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)insertNotification:(NSString *)notification {
    // TODO: Limit the number of notifications.
    // TODO: Adjust appearance of notification labels.
    // TODO: Not let keyboard hide the notifications.

    [self.notifications addObject:notification];
    
    UILabel *notificationLabel = [[UILabel alloc] init];
    notificationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    notificationLabel.text = notification;
    notificationLabel.textColor = [UIColor whiteColor];
    notificationLabel.textAlignment = NSTextAlignmentCenter;
    notificationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    notificationLabel.numberOfLines = 0;
    notificationLabel.backgroundColor = [UIColor blackColor];
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
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:notificationLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0];
    [self.superView addConstraint:bottomConstraint];
    [self.bottomConstraints addObject:bottomConstraint];
    
    if (self.views.count > 1) {
        [self.superView removeConstraint:[self.bottomConstraints objectAtIndex:self.views.count - 2]];
        NSLayoutConstraint *secondBottomConstraint = [NSLayoutConstraint constraintWithItem:[self.views objectAtIndex:self.views.count - 2] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:notificationLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0];
        [self.superView addConstraint:secondBottomConstraint];
        [self.bottomConstraints replaceObjectAtIndex:self.views.count - 2 withObject:secondBottomConstraint];
    }
    
    // Not protectiong the animation which doesn't affect main view
    [UIView animateWithDuration:0.5 animations:^{
        [self.superView layoutIfNeeded];
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 animations:^{
            notificationLabel.alpha = 1.0;
        }completion:^(BOOL finished){
            // TODO: Determine how long a notification should stay on the screen.
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(notificationFired:) userInfo:nil repeats:NO];
        }];
    }];
}

- (void)notificationFired:(NSTimer *)timer {
    [UIView animateWithDuration:0.5 animations:^{
        ((UIView *)[self.views objectAtIndex:0]).alpha = 0.0;
    }completion:^(BOOL finished){
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
    }];
}

@end
