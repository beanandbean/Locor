//
//  CPMemoCollectionViewManager.h
//  Locor
//
//  Created by wangsw on 8/31/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemo.h"

#import "CPMainViewController.h"
#import "CPAdManager.h"

@class CPMemoCell;

@protocol CPMemoCollectionViewManagerDelegate <NSObject>

- (CPMemo *)newMemo;

@end

@interface CPMemoCollectionViewManager : NSObject <CPAdResizingObserver, CPDeviceRotateObserver, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) id<CPMemoCollectionViewManagerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *memos;
@property (strong, nonatomic) UIColor *inPasswordMemoColor;

@property (strong, nonatomic) UICollectionView *frontCollectionView;
@property (strong, nonatomic) UICollectionView *backCollectionView;

@property (strong, nonatomic) CPMemoCell *editingCell;

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) NSArray *textFieldConstraints;

@property (strong, nonatomic) UIView *textFieldContainer;
@property (strong, nonatomic) NSArray *textFieldContainerConstraints;

- (id)initWithSuperview:(UIView *)superview frontLayer:(UIView *)frontLayer backLayer:(UIView *)backLayer andDelegate:(id<CPMemoCollectionViewManagerDelegate>)delegate;

- (void)showMemoCollectionViewAnimated;

- (void)endEditing;

- (void)setEnabled:(BOOL)enabled;

- (void)memoCellAtIndexPath:(NSIndexPath *)indexPath updateText:(NSString *)text;

@end
