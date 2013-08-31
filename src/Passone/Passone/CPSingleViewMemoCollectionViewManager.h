//
//  CPMemoCollectionViewManager.h
//  Passone
//
//  Created by wangsw on 8/4/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemo.h"

typedef enum {
    CPMemoCollectionViewStyleSearch,
    CPMemoCollectionViewStyleInPassCell
} CPMemoCollectionViewStyle;

@class CPMemoCell;

@protocol CPSingleViewMemoCollectionViewManagerDelegate <NSObject>

- (CPMemo *)newMemo;

@end

@interface CPSingleViewMemoCollectionViewManager : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) id<CPSingleViewMemoCollectionViewManagerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *memos;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) CPMemoCell *editingCell;

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) NSArray *textFieldConstraints;

@property (strong, nonatomic) UIView *textFieldContainer;
@property (strong, nonatomic) NSArray *textFieldContainerConstraints;

- (id)initWithSuperview:(UIView *)superview style:(CPMemoCollectionViewStyle)style andDelegate:(id<CPSingleViewMemoCollectionViewManagerDelegate>)delegate;

- (void)endEditing;

- (void)memoCellAtIndexPath:(NSIndexPath *)indexPath updateText:(NSString *)text;

@end
