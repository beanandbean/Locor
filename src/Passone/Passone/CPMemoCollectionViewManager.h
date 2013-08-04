//
//  CPMemoCollectionViewManager.h
//  Passone
//
//  Created by wangsw on 8/4/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

@interface CPMemoCollectionViewManager : NSObject <CPMemoCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *memos;
@property (strong, nonatomic) UICollectionView *collectionView;

- (id)initWithSuperview:(UIView *)superview;

- (void)endEditing;

@end
