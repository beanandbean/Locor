//
//  CPDraggingPassCell.h
//  Locor
//
//  Created by wangsw on 9/15/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCellManager.h"

@interface CPDraggingPassCell : UIView

@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *topConstraint;
@property (strong, nonatomic) NSArray *sizeConstraints;
@property (strong, nonatomic) UIImageView *icon;

- (id)initWithCell:(CPPassCellManager *)passCell onView:(UIView *)view withShadow:(BOOL)shadow;

@end
