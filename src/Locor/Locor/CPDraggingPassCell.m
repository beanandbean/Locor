//
//  CPDraggingPassCell.m
//  Locor
//
//  Created by wangsw on 9/15/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPDraggingPassCell.h"

#import "CPCoverImageView.h"

#import "CPAppearanceManager.h"

@implementation CPDraggingPassCell

+ (void)makeShadowOnCell:(UIView *)cell withColor:(UIColor *)color opacity:(float)opacity radius:(float)radius andExpandSize:(float)size {
    cell.layer.shadowColor = color.CGColor;
    cell.layer.shadowOffset = CGSizeZero;
    cell.layer.shadowOpacity = opacity;
    cell.layer.shadowRadius = radius;
    cell.layer.masksToBounds = NO;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectInset(cell.bounds, -size, -size)];
    cell.layer.shadowPath = bezierPath.CGPath;
}

+ (void)removeShadowOnCell:(UIView *)cell {
    cell.layer.shadowColor = [UIColor clearColor].CGColor;
    cell.layer.shadowOffset = CGSizeZero;
    cell.layer.shadowOpacity = 0.0;
    cell.layer.shadowRadius = 0.0;
}

- (id)initWithCell:(CPPassCellManager *)passCell onView:(UIView *)view withShadow:(BOOL)shadow
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = passCell.passCellView.backgroundColor;
        
        [view addSubview:self];
        
        self.leftConstraint = [CPAppearanceManager constraintWithView:self alignToView:passCell.passCellView attribute:NSLayoutAttributeLeft];
        [view addConstraint:self.leftConstraint];
        self.topConstraint = [CPAppearanceManager constraintWithView:self alignToView:passCell.passCellView attribute:NSLayoutAttributeTop];
        [view addConstraint:self.topConstraint];
        
        self.sizeConstraints = [NSArray arrayWithObjects:
                                [CPAppearanceManager constraintWithView:self alignToView:passCell.passCellView attribute:NSLayoutAttributeWidth],
                                [CPAppearanceManager constraintWithView:self alignToView:passCell.passCellView attribute:NSLayoutAttributeHeight],
                                nil];
        [view addConstraints:self.sizeConstraints];
        
        UIView *coverContainer = [[UIView alloc] init];
        coverContainer.clipsToBounds = YES;
        coverContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:coverContainer];
        [self addConstraints:[CPAppearanceManager constraintsWithView:coverContainer edgesAlignToView:self]];
        
        CPCoverImageView *cover = [[CPCoverImageView alloc] init];
        [coverContainer addSubview:cover];
        
        [view addConstraints:cover.positioningConstraints];
        
        self.icon = [[UIImageView alloc] initWithImage:passCell.iconImage.image];
        self.icon.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.icon];
        [self addConstraints:[CPAppearanceManager constraintsWithView:self.icon centerAlignToView:self]];
        
        [view layoutIfNeeded];
        
        if (shadow) {
            [CPDraggingPassCell makeShadowOnCell:self withColor:passCell.passCellView.backgroundColor opacity:1.0 radius:5.0 andExpandSize:5.0];
        }
    }
    return self;
}

@end
