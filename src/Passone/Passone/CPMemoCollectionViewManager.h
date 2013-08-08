//
//  CPMemoCollectionViewManager.h
//  Passone
//
//  Created by wangsw on 8/4/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

typedef enum {
    CPMemoCollectionViewStyleSearch,
    CPMemoCollectionViewStyleInPassCell
} CPMemoCollectionViewStyle;

@interface CPMemoCollectionViewManager : NSObject <CPMemoCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *memos;
@property (strong, nonatomic) UICollectionView *collectionView;

- (id)initWithSuperview:(UIView *)superview andStyle:(CPMemoCollectionViewStyle)style;

- (void)endEditing;

@end
