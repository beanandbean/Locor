//
//  CPNotificationCenter.m
//  Passone
//
//  Created by wangsw on 6/28/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPNotificationCenter.h"

static CPNotificationCenter *center;

@interface CPNotificationCenter ()

@property (nonatomic) float width;
@property (weak, nonatomic) UIView *superView;
@property (strong, nonatomic) NSMutableArray *notifications;
@property (strong, nonatomic) NSMutableArray *views;
@property (strong, nonatomic) NSMutableArray *centerConstraints;
@property (strong, nonatomic) NSMutableArray *widthConstraints;
@property (strong, nonatomic) NSMutableArray *bottomConstraints;

- (id)initWithSuperView:(UIView *)view;

- (void)insertNotification:(NSString *)notification;

- (void)notificationFired:(NSTimer *)timer;

@end

@implementation CPNotificationCenter

+ (void)createNotificationCenterWithSuperView:(UIView *)view {
    center = [[CPNotificationCenter alloc] initWithSuperView:view];
}

+ (void)insertNotification:(NSString *)notification {
    if (center) {
        [center insertNotification:notification];
    }
}

- (id)initWithSuperView:(UIView *)view {
    self = [super init];
    if (self) {
        self.superView = view;
        self.notifications = [[NSMutableArray alloc] init];
        self.views = [[NSMutableArray alloc] init];
        self.centerConstraints = [[NSMutableArray alloc] init];
        self.widthConstraints = [[NSMutableArray alloc] init];
        self.bottomConstraints = [[NSMutableArray alloc] init];
        
        if (view.bounds.size.width > view.bounds.size.height) {
            self.width = view.bounds.size.height - 20.0;
        } else {
            self.width = view.bounds.size.width - 20.0;
        }
    }
    return self;
}

- (void)insertNotification:(NSString *)notification {
    [self.notifications addObject:notification];
    
    // TODO: Add padding to notification labels, maybe also border radius.
    UILabel *notificationLabel = [[UILabel alloc] init];
    notificationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    notificationLabel.text = notification;
    notificationLabel.textColor = [UIColor whiteColor];
    notificationLabel.backgroundColor = [UIColor blackColor];
    notificationLabel.alpha = 0.0;
    [self.superView addSubview:notificationLabel];
    [self.views addObject:notificationLabel];

    NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:notificationLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [self.superView addConstraint:centerConstraint];
    [self.centerConstraints addObject:centerConstraint];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:notificationLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:self.width];
    [self.superView addConstraint:widthConstraint];
    [self.widthConstraints addObject:widthConstraint];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:notificationLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0];
    [self.superView addConstraint:bottomConstraint];
    [self.bottomConstraints addObject:bottomConstraint];
    
    if (self.views.count > 1) {
        [self.superView removeConstraint:[self.bottomConstraints objectAtIndex:self.views.count - 2]];
        NSLayoutConstraint *secondBottomConstraint = [NSLayoutConstraint constraintWithItem:[self.views objectAtIndex:self.views.count - 2] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:notificationLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0];
        [self.superView addConstraint:secondBottomConstraint];
        [self.bottomConstraints replaceObjectAtIndex:self.views.count - 2 withObject:secondBottomConstraint];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.superView layoutIfNeeded];
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 animations:^{
            notificationLabel.alpha = 1.0;
        }completion:^(BOOL finished){
            NSLog(@"Add: %@", notification);
            
            // TODO: Determine how long a notification should stay on the screen.
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(notificationFired:) userInfo:nil repeats:NO];
        }];
    }];
}

- (void)notificationFired:(NSTimer *)timer {
    [UIView animateWithDuration:0.5 animations:^{
        ((UIView *)[self.views objectAtIndex:0]).alpha = 0.0;
    }completion:^(BOOL finished){
        [self.superView removeConstraint:[self.centerConstraints objectAtIndex:0]];
        [self.centerConstraints removeObjectAtIndex:0];
        
        [self.superView removeConstraint:[self.widthConstraints objectAtIndex:0]];
        [self.widthConstraints removeObjectAtIndex:0];
        
        [self.superView removeConstraint:[self.bottomConstraints objectAtIndex:0]];
        [self.bottomConstraints removeObjectAtIndex:0];

        [[self.views objectAtIndex:0] removeFromSuperview];
        [self.views removeObjectAtIndex:0];

        [self.superView layoutIfNeeded];
        NSLog(@"Fire: %@", [self.notifications objectAtIndex:0]);
        [self.notifications removeObjectAtIndex:0];
    }];
}

@end
