//
//  CPLoginView.m
//  Passone
//
//  Created by wangyw on 5/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPLoginView.h"

@interface CPLoginView ()

@property (nonatomic) CGFloat smallSize;
@property (nonatomic) CGFloat largeSize;

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;

@end

@implementation CPLoginView

- (id)initWithSmallSize:(CGFloat)smallSize largeSize:(CGFloat)largeSize {
    self = [super init];
    if (self) {
        self.smallSize = smallSize;
        self.largeSize = largeSize;
        
        float red = (rand() % 256) / 256.0;
        float green = (rand() % 256) / 256.0;
        float blue = (rand() % 256) / 256.0;
        self.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
        self.widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:0.0
                                                             constant:smallSize];
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0
                                                              constant:smallSize];
        [self addConstraint:self.widthConstraint];
        [self addConstraint:self.heightConstraint];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBy:)]];
        
        [self createNoUserView];
    }
    return self;
}

- (void)shrink {
    if (self.frame.size.width != self.smallSize) {
        self.widthConstraint.constant = self.smallSize;
        self.heightConstraint.constant = self.smallSize;
        [UIView animateWithDuration:1.0 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self createNoUserView];
        }];
    }
}

- (void)tappedBy:(UITapGestureRecognizer *)tapGuesture {
    if (self.frame.size.width != self.largeSize) {
        [self.superview bringSubviewToFront:self];
        self.widthConstraint.constant = self.largeSize;
        self.heightConstraint.constant = self.largeSize;
        [UIView animateWithDuration:1.0 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self createRegisterView];
        }];
    }
}

- (void)createNoUserView {
    for (UIView * view in self.subviews) {
        [view removeFromSuperview];
    }
    
    UILabel *add = [[UILabel alloc] init];
    add.text = @"+";
    add.font = [UIFont systemFontOfSize:80.0];
    add.textColor = [UIColor whiteColor];
    add.backgroundColor = [UIColor clearColor];
    add.shadowColor = [UIColor blackColor];
    add.shadowOffset = CGSizeMake(0.0, -1.0);
    [self addSubview:add];
    
    add.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:add
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:add
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
}

- (void)createRegisterView {
    for (UIView * view in self.subviews) {
        [view removeFromSuperview];
    }
    
    UIView *inputBackground = [[UIView alloc] init];
    inputBackground.layer.borderWidth = 1.0;
    inputBackground.layer.borderColor = [[UIColor blackColor] CGColor];
    inputBackground.layer.cornerRadius = 10.0;
    inputBackground.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:inputBackground];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:inputBackground
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:inputBackground
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:-45.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:inputBackground
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:-40.0]];
    [inputBackground addConstraint:[NSLayoutConstraint constraintWithItem:inputBackground
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0
                                                                 constant:90.0]];
    
    UITextField *user = [[UITextField alloc] init];
    user.placeholder = @"User Name";
    user.translatesAutoresizingMaskIntoConstraints = NO;
    [inputBackground addSubview:user];
    [inputBackground addConstraint:[NSLayoutConstraint constraintWithItem:user
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:inputBackground
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
    [inputBackground addConstraint:[NSLayoutConstraint constraintWithItem:user
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:inputBackground
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:20.0]];
    [inputBackground addConstraint:[NSLayoutConstraint constraintWithItem:user
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:inputBackground
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:-40.0]];
    [user addConstraint:[NSLayoutConstraint constraintWithItem:user
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:0.0
                                                      constant:20.0]];
    UITextField *password = [[UITextField alloc] init];
    password.placeholder = @"Password";
    password.translatesAutoresizingMaskIntoConstraints = NO;
    [inputBackground addSubview:password];
    [inputBackground addConstraint:[NSLayoutConstraint constraintWithItem:password
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:inputBackground
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
    [inputBackground addConstraint:[NSLayoutConstraint constraintWithItem:password
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:user
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:10.0]];
    [inputBackground addConstraint:[NSLayoutConstraint constraintWithItem:password
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:inputBackground
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:-40.0]];
    [password addConstraint:[NSLayoutConstraint constraintWithItem:password
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0.0
                                                          constant:20.0]];
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [registerButton setTitle:@"Register" forState:UIControlStateNormal];
    registerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:registerButton];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:registerButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:registerButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:50.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:registerButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:-40.0]];
    [registerButton addConstraint:[NSLayoutConstraint constraintWithItem:registerButton
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:35.0]];
}

@end
