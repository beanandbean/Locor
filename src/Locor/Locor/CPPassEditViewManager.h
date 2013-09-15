//
//  CPPassEditViewManager.h
//  Locor
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPIconPicker.h"

#import "CPMemoCollectionViewManager.h"

@interface CPPassEditViewManager : NSObject <CPIconPickerDelegate, CPMemoCollectionViewManagerDelegate, UITextFieldDelegate>

@property (nonatomic) NSInteger index;

- (id)initWithSuperview:(UIView *)superview andCells:(NSArray *)cells;

- (void)showPassEditViewForCellAtIndex:(NSUInteger)index;

@end
