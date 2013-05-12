//
//  CPLoginView.m
//  Passone
//
//  Created by wangyw on 5/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPLoginView.h"

@interface CPLoginView ()

@property (strong, nonatomic) NSString *user;
@property (strong, nonatomic) NSString *password;

@property (nonatomic) CGFloat smallSize;
@property (nonatomic) CGFloat largeSize;

@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;

@end

@implementation CPLoginView

- (id)initWithSmallSize:(CGFloat)smallSize largeSize:(CGFloat)largeSize user:(NSString *)user password:(NSString *)password {
    self = [super init];
    if (self) {
        self.smallSize = smallSize;
        self.largeSize = largeSize;
        self.user = user;
        self.password = password;
        
        self.widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:smallSize];
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:smallSize];
        [self addConstraint:self.widthConstraint];
        [self addConstraint:self.heightConstraint];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBy:)]];
        
        
        [[NSBundle mainBundle] loadNibNamed:@"CPLoginView" owner:self options:nil];
        [self addView:self.emptyView];
        [self addView:self.userView];
        [self addView:self.registerView];
        [self addView:self.loginView];
        
        CGFloat red = arc4random() % 255 / 255.0;
        CGFloat green = arc4random() % 255 / 255.0;
        CGFloat blue = arc4random() % 255 / 255.0;
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        self.emptyView.backgroundColor = color;
        self.userView.backgroundColor = color;
        self.registerView.backgroundColor = color;
        self.loginView.backgroundColor = color;
        
        self.registerBackgroundView.layer.cornerRadius = 10.0;
        self.registerBackgroundView.layer.borderWidth = 1;
        self.registerBackgroundView.layer.borderColor = [[UIColor blackColor] CGColor];
        
        self.loginBackgroundView.layer.cornerRadius = 10.0;
        self.loginBackgroundView.layer.borderWidth = 1;
        self.loginBackgroundView.layer.borderColor = [[UIColor blackColor] CGColor];
        
        if (self.user) {
            self.userLabel.text = self.user;
            self.loginUserName.text = self.user;
            [self showView:self.userView];
        } else {
            [self showView:self.emptyView];
        }
    }
    return self;
}

- (void)shrink {
    if (self.frame.size.width != self.smallSize) {
        if (self.user) {
            [self showView:self.userView];
        } else {
            [self showView:self.emptyView];
        }
        self.widthConstraint.constant = self.smallSize;
        self.heightConstraint.constant = self.smallSize;
        [UIView animateWithDuration:1.0 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

- (IBAction)register:(id)sender {
    if (![self.registerUserName.text isEqualToString:@""] && ![self.registerPassword.text isEqualToString:@""] && ![self.registerConfirmedPassword.text isEqualToString:@""] && [self.registerPassword.text isEqualToString:self.registerConfirmedPassword.text]) {
        self.user = self.registerUserName.text;
        self.password = self.registerPassword.text;

        self.userLabel.text = self.user;
        self.loginUserName.text = self.user;
        
        [self.loginViewDelegate addUser:self.user password:self.password fromLoginView:self];
    }
}

- (IBAction)login:(id)sender {
    if ([self.loginUserName.text isEqualToString:self.user] && [self.loginPassword.text isEqualToString:self.password]) {
        [self.loginViewDelegate user:self.user loginFromLoginView:self];
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
            if (self.user) {
                [self showView:self.loginView];
            } else {
                [self showView:self.registerView];
            }
        }];
    }
}

- (void)showView:(UIView *)view {
    self.emptyView.hidden = YES;
    self.userView.hidden = YES;
    self.registerView.hidden = YES;
    self.loginView.hidden = YES;
    view.hidden = NO;
}

- (void)addView:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
}

@end
