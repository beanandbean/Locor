//
//  CPPassEditViewManager.h
//  Passone
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCollectionViewManager.h"

@interface CPPassEditViewManager : NSObject <CPMemoCollectionViewManagerDelegate, UITextFieldDelegate>

@property (nonatomic) NSInteger index;

- (id)initWithSuperView:(UIView *)superView coverImage:(UIImageView *)coverImage andCells:(NSArray *)cells;

- (void)showPassEditViewForCellAtIndex:(NSUInteger)index;

- (void)hidePassEditView;

@end
