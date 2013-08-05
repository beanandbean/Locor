//
//  CPMemoCellRemoving.m
//  Passone
//
//  Created by wangsw on 7/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCellRemoving.h"

@interface CPMemoCellRemoving ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) NSLayoutConstraint *imageViewLeftConstraint;

@end

@implementation CPMemoCellRemoving

- (void)setImage:(UIImage *)image {
    _image = image;
    
    self.contentView.alpha = 1.0;
    [self.contentView removeConstraints:self.contentView.constraints];
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = image;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.imageView];
    
    self.imageViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    [self.contentView addConstraint:self.imageViewLeftConstraint];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:image.size.width]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:image.size.height]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    self.leftLabel = [[UILabel alloc] init];
    self.leftLabel.text = @"Swipe to remove";
    self.leftLabel.textColor = [UIColor whiteColor];
    self.leftLabel.backgroundColor = [UIColor clearColor];
    self.leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.leftLabel];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-5.0]];
    
    self.rightLabel = [[UILabel alloc] init];
    self.rightLabel.text = @"Swipe to remove";
    self.rightLabel.textColor = [UIColor whiteColor];
    self.rightLabel.backgroundColor = [UIColor clearColor];
    self.rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.rightLabel];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:5.0]];
}

- (void)setImageLeftOffset:(float)offset {
    self.imageViewLeftConstraint.constant = offset;
    
    if (fabsf(offset) < self.contentView.frame.size.width / 2) {
        self.leftLabel.text = @"Swipe to remove";
        self.rightLabel.text = @"Swipe to remove";
    } else {
        self.leftLabel.text = @"Release to remove";
        self.rightLabel.text = @"Release to remove";
    }
}

@end
