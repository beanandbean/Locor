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
@property (strong, nonatomic) NSLayoutConstraint *imageViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation CPMemoCellRemoving

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:_imageView];
        
        self.imageViewLeftConstraint = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:self.imageViewLeftConstraint];
        self.imageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
        [self.contentView addConstraint:self.imageViewWidthConstraint];
        self.imageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
        [self.contentView addConstraint:self.imageViewHeightConstraint];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    }
    
    return _imageView;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    self.imageView.image = image;
    self.imageViewWidthConstraint.constant = image.size.width;
    self.imageViewHeightConstraint.constant = image.size.height;
}

- (void)setImageLeftOffset:(float)offset {
    self.imageViewLeftConstraint.constant = offset;
}

@end
