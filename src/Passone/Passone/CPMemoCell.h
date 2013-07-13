//
//  CPMemoCell.h
//  Passone
//
//  Created by wangyw on 7/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPMemoCell : UICollectionViewCell <UITextFieldDelegate>

@property (strong, nonatomic) UILabel *label;

+ (void)setTextFieldContainer:(UIView *)container;
+ (CPMemoCell *)editingCell;

- (void)refreshingConstriants;

- (BOOL)isEditing;
- (void)endEditing;

@end
