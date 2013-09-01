//
//  CPMemoCell.h
//  Passone
//
//  Created by wangyw on 7/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPSingleViewMemoCollectionViewManager;

@interface CPMemoCell : UICollectionViewCell <UITextFieldDelegate>

@property (weak, nonatomic) CPSingleViewMemoCollectionViewManager *delegate;
@property (strong, nonatomic) UILabel *label;

- (void)refreshingConstriants;

- (BOOL)isEditing;
- (void)startEditing;
- (void)endEditingAtIndexPath:(NSIndexPath *)indexPath;

@end
