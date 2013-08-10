//
//  CPMemoCollectionViewManager.h
//  Passone
//
//  Created by wangsw on 8/4/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemo.h"
#import "CPMemoCell.h"

typedef enum {
    CPMemoCollectionViewStyleSearch,
    CPMemoCollectionViewStyleInPassCell
} CPMemoCollectionViewStyle;

@protocol CPMemoCollectionViewManagerDelegate <NSObject>

- (CPMemo *)newMemo;

@end

@interface CPMemoCollectionViewManager : NSObject <CPMemoCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) id<CPMemoCollectionViewManagerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *memos;
@property (strong, nonatomic) UICollectionView *collectionView;

- (id)initWithSuperview:(UIView *)superview style:(CPMemoCollectionViewStyle)style andDelegate:(id<CPMemoCollectionViewManagerDelegate>)delegate;

- (void)endEditing;

@end
