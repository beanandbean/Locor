//
//  CPMemoCell.h
//  Passone
//
//  Created by wangyw on 7/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPMemoCell;

@protocol CPMemoCellDelegate <NSObject>

- (void)memoCellAtIndexPath:(NSIndexPath *)indexPath updateText:(NSString *)text;

@end

@interface CPMemoCell : UICollectionViewCell <UITextFieldDelegate>

@property (weak, nonatomic) id<CPMemoCellDelegate> delegate;
@property (strong, nonatomic) UILabel *label;

+ (void)setTextFieldContainer:(UIView *)container;
+ (CPMemoCell *)editingCell;

- (void)refreshingConstriants;

- (BOOL)isEditing;
- (void)endEditingAtIndexPath:(NSIndexPath *)indexPath;

@end
