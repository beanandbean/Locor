//
//  CPMemoCellRemovingBackground.m
//  Passone
//
//  Created by wangsw on 9/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCellRemovingBackground.h"

@interface CPMemoCellRemovingBackground ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;

@end

@implementation CPMemoCellRemovingBackground

- (void)setColor:(UIColor *)color {
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = color;
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.backgroundView];
    
    self.leftConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    [self.contentView addConstraint:self.leftConstraint];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
}

- (void)setLeftOffset:(float)offset {
    self.leftConstraint.constant = offset;
}

@end
