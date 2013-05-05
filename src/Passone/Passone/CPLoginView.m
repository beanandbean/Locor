//
//  CPLoginView.m
//  Passone
//
//  Created by wangyw on 5/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPLoginView.h"

@interface CPLoginView ()

@property (nonatomic, strong) NSLayoutConstraint *height;
@property (nonatomic, strong) NSLayoutConstraint *width;

@end

@implementation CPLoginView

- (id)initWithSize:(int)size {
    self = [super init];
    if (self) {
        float red = (rand() % 256) / 256.0;
        float green = (rand() % 256) / 256.0;
        float blue = (rand() % 256) / 256.0;
        self.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
        self.width = [NSLayoutConstraint constraintWithItem:self
                                                  attribute:NSLayoutAttributeWidth
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:0.0
                                                   constant:size];
        self.height = [NSLayoutConstraint constraintWithItem:self
                                                   attribute:NSLayoutAttributeHeight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:nil
                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                  multiplier:0.0
                                                    constant:size];
        [self addConstraint:self.width];
        [self addConstraint:self.height];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBy:)]];
        
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
    return self;
}

- (void)tappedBy:(UITapGestureRecognizer *)tapGuesture {
    [self.superview bringSubviewToFront:self];
    self.width.constant = 420.0;
    self.height.constant = 420.0;
    [UIView animateWithDuration:1.0 animations:^{
        [self layoutIfNeeded];
    }];
}

@end
