//
//  CPMemoCellRemoving.m
//  Passone
//
//  Created by wangsw on 7/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCellRemoving.h"

#import "CPPassoneConfig.h"

@interface CPMemoCellRemoving ()

@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;

@end

@implementation CPMemoCellRemoving

- (void)setText:(NSString *)text {
    self.contentView.alpha = 1.0;
    [self.contentView removeConstraints:self.contentView.constraints];
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    self.label = [[UILabel alloc] init];
    self.label.text = text;
    self.label.backgroundColor = [UIColor clearColor];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.label];
    
    self.leftConstraint = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0];
    [self.contentView addConstraint:self.leftConstraint];
    [self.contentView addConstraints:[[NSArray alloc] initWithObjects:
                                      [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:5.0],
                                      [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-20.0],
                                      [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-10.0],
                                      nil]];

    
    self.leftLabel = [[UILabel alloc] init];
    self.leftLabel.text = @"Swipe to remove";
    self.leftLabel.textColor = [UIColor whiteColor];
    self.leftLabel.backgroundColor = [UIColor clearColor];
    self.leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.leftLabel];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.label attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10.0 - MEMO_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE]];
    
    self.rightLabel = [[UILabel alloc] init];
    self.rightLabel.text = @"Swipe to remove";
    self.rightLabel.textColor = [UIColor whiteColor];
    self.rightLabel.backgroundColor = [UIColor clearColor];
    self.rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.rightLabel];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.label attribute:NSLayoutAttributeRight multiplier:1.0 constant:10.0 + MEMO_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE]];
}

- (void)setLeftOffset:(float)offset {
    self.leftConstraint.constant = offset + 10.0;
    
    if (fabsf(offset) < self.contentView.frame.size.width / 2) {
        self.leftLabel.text = @"Swipe to remove";
        self.rightLabel.text = @"Swipe to remove";
    } else {
        self.leftLabel.text = @"Release to remove";
        self.rightLabel.text = @"Release to remove";
    }
}

@end
