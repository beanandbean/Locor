//
//  CPMemoCollectionViewManager.m
//  Locor
//
//  Created by wangsw on 8/31/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCollectionViewManager.h"

#import "CPLocorConfig.h"

#import "CPMemoCell.h"
#import "CPMemoCellRemoving.h"
#import "CPMemoCellRemovingBackground.h"

#import "CPAppearanceManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPProcessManager.h"
#import "CPScrollingCollectionViewProcess.h"
#import "CPRemovingMemoCellProcess.h"

#define NS_INDEX_PATH_ZERO [NSIndexPath indexPathForRow:0 inSection:0]

static NSString *CELL_REUSE_IDENTIFIER_NORMAL = @"normal-cell";
static NSString *CELL_REUSE_IDENTIFIER_NORMAL_BACKGROUND = @"normal-cell-background";
static NSString *CELL_REUSE_IDENTIFIER_REMOVING = @"removing-cell";
static NSString *CELL_REUSE_IDENTIFIER_REMOVING_BACKGROUND = @"removing-cell-background";

@interface CPMemoCollectionViewManager ()

@property (nonatomic) CPMemoCollectionViewStyle style;

@property (weak, nonatomic) UIView *superview;

@property (weak, nonatomic) UIView *frontLayer;
@property (weak, nonatomic) UIView *backLayer;

@property (strong, nonatomic) NSArray *frontCollectionViewConstraints;
@property (strong, nonatomic) NSArray *backCollectionViewConstraints;

@property (nonatomic) CGPoint draggingBasicOffset;
@property (strong, nonatomic) NSIndexPath *addingCellIndex;

@property (weak, nonatomic) CPMemoCellRemoving *frontRemovingCell;
@property (strong, nonatomic) NSIndexPath *frontRemovingCellIndex;
@property (weak, nonatomic) CPMemoCellRemovingBackground *backRemovingCell;
@property (strong, nonatomic) NSIndexPath *backRemovingCellIndex;

@property (nonatomic) NSValue *collectionViewOffsetBeforeEdit;

@end

@implementation CPMemoCollectionViewManager

- (UICollectionView *)makeCollectionView {
    UICollectionView *collectionView;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = BOX_SEPARATOR_SIZE;
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    if (self.style == CPMemoCollectionViewStyleSearch) {
        collectionView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.9];
        layout.sectionInset = UIEdgeInsetsMake(BOX_SEPARATOR_SIZE, BOX_SEPARATOR_SIZE, BOX_SEPARATOR_SIZE, BOX_SEPARATOR_SIZE);
    } else if (self.style == CPMemoCollectionViewStyleInPassCell) {
        collectionView.backgroundColor = [UIColor clearColor];
        // Not leaving top and bottom insets because there have already been insets ouside superview
        layout.sectionInset = UIEdgeInsetsMake(0.0, BOX_SEPARATOR_SIZE, 0.0, BOX_SEPARATOR_SIZE);
    } else {
        NSAssert(NO, @"Unexpected memo collection view style!");
    }
    
    [collectionView registerClass:[CPMemoCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_NORMAL];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_NORMAL_BACKGROUND];
    [collectionView registerClass:[CPMemoCellRemoving class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_REMOVING];
    [collectionView registerClass:[CPMemoCellRemovingBackground class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_REMOVING_BACKGROUND];
    
    [collectionView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    return collectionView;
}

- (UICollectionView *)frontCollectionView {
    if (!_frontCollectionView) {
        _frontCollectionView = [self makeCollectionView];
    }
    return _frontCollectionView;
}

- (UICollectionView *)backCollectionView {
    if (!_backCollectionView) {
        _backCollectionView = [self makeCollectionView];
    }
    return _backCollectionView;
}

- (NSArray *)frontCollectionViewConstraints {
    if (!_frontCollectionViewConstraints) {
        _frontCollectionViewConstraints = [CPAppearanceManager constraintsForView:self.frontCollectionView toEqualToView:self.frontLayer];
    }
    return _frontCollectionViewConstraints;
}

- (NSArray *)backCollectionViewConstraints {
    if (!_backCollectionViewConstraints) {
        _backCollectionViewConstraints = [CPAppearanceManager constraintsForView:self.backCollectionView toEqualToView:self.backLayer];
    }
    return _backCollectionViewConstraints;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        [_textFieldContainer addSubview:_textField];
    }
    return _textField;
}

- (UIView *)textFieldContainer {
    if (!_textFieldContainer) {
        _textFieldContainer = [[UIView alloc] init];
        _textFieldContainer.translatesAutoresizingMaskIntoConstraints = NO;
        _textFieldContainer.userInteractionEnabled = NO;
        _textFieldContainer.clipsToBounds = YES;
    }
    return _textFieldContainer;
}

- (NSArray *)textFieldContainerConstraints {
    if (!_textFieldContainerConstraints) {
        _textFieldContainerConstraints = [[NSArray alloc] initWithObjects:
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.frontCollectionView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.frontCollectionView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.frontCollectionView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.frontCollectionView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                                          nil];
    }
    return _textFieldContainerConstraints;
}

- (void)setMemos:(NSMutableArray *)memos {
    _memos = memos;
    [self endEditing];
    [self reloadCollectionData];
}

- (id)initWithSuperview:(UIView *)superview frontLayer:(UIView *)frontLayer backLayer:(UIView *)backLayer style:(CPMemoCollectionViewStyle)style andDelegate:(id<CPMemoCollectionViewManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.style = style;
        self.memos = [NSArray array];
        self.delegate = delegate;
        self.superview = superview;
        self.frontLayer = frontLayer;
        self.backLayer = backLayer;
        
        [self.frontLayer addSubview:self.frontCollectionView];
        [self.frontLayer addSubview:self.textFieldContainer];
        [self.backLayer addSubview:self.backCollectionView];
        [self.frontLayer addConstraints:self.frontCollectionViewConstraints];
        [self.frontLayer addConstraints:self.textFieldContainerConstraints];
        [self.backLayer addConstraints:self.backCollectionViewConstraints];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidUndock:) name:UIKeyboardDidChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)endEditing {
    if (self.editingCell) {
        [self.editingCell endEditingAtIndexPath:[self.frontCollectionView indexPathForCell:self.editingCell]];
    }
}

- (void)setCollectionOffset:(CGPoint)offset animated:(BOOL)animated {
    [self.frontCollectionView setContentOffset:offset animated:animated];
    [self.backCollectionView setContentOffset:offset animated:animated];
}

- (void)reloadCollectionData {
    [self.frontCollectionView reloadData];
    [self.backCollectionView reloadData];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        if ((![CPProcessManager isInProcess:REMOVING_MEMO_CELL_PROCESS]) && (![CPProcessManager isInProcess:SCROLLING_COLLECTION_VIEW_PROCESS])) {
            CGPoint location = [panGesture locationInView:panGesture.view];
            NSIndexPath *panningCellIndex = [self.frontCollectionView indexPathForItemAtPoint:location];
            
            if (self.editingCell) {
                [self.editingCell endEditingAtIndexPath:[self.frontCollectionView indexPathForCell:self.editingCell]];
            }
            
            // TODO: Determine if the memo cell should fall back to original position when you start removing after it is raised up when editing.
            
            if (fabsf(translation.x) > fabsf(translation.y) && panningCellIndex) {
                [CPProcessManager startProcess:REMOVING_MEMO_CELL_PROCESS withPreparation:^{
                    self.frontRemovingCellIndex = self.backRemovingCellIndex = panningCellIndex;
                    [self reloadCollectionData];
                }];
            } else {
                self.collectionViewOffsetBeforeEdit = nil;
                [CPProcessManager startProcess:SCROLLING_COLLECTION_VIEW_PROCESS withPreparation:^{
                    if (self.style == CPMemoCollectionViewStyleInPassCell) {
                        self.draggingBasicOffset = CGPointMake(self.frontCollectionView.contentOffset.x, self.frontCollectionView.contentOffset.y + MEMO_CELL_HEIGHT + BOX_SEPARATOR_SIZE);
                    } else {
                        self.draggingBasicOffset = self.frontCollectionView.contentOffset;
                    }
                    [self reloadCollectionData];
                }];
            }
        }
        if ([CPProcessManager isInProcess:REMOVING_MEMO_CELL_PROCESS]) {
            self.frontRemovingCell.leftOffset = self.backRemovingCell.leftOffset = translation.x;
        }
        if ([CPProcessManager isInProcess:SCROLLING_COLLECTION_VIEW_PROCESS]) {
            CGPoint offset = CGPointMake(self.draggingBasicOffset.x, self.draggingBasicOffset.y - translation.y);
            [self setCollectionOffset:offset animated:NO];
            
            if (self.style == CPMemoCollectionViewStyleInPassCell) {
                CPMemoCell *addingCell = (CPMemoCell *)[self.frontCollectionView cellForItemAtIndexPath:NS_INDEX_PATH_ZERO];
                if (addingCell && offset.y < 30.0) {
                    addingCell.label.text = @"Release to add a new memo";
                } else {
                    addingCell.label.text = @"Drag to add a new memo";
                }
            }
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        
        [CPProcessManager stopProcess:REMOVING_MEMO_CELL_PROCESS withPreparation:^{
            if (fabsf(translation.x) < self.frontRemovingCell.contentView.frame.size.width / 2) {
                self.frontRemovingCell.leftOffset = self.backRemovingCell.leftOffset = 0.0;
                [CPAppearanceManager animateWithDuration:0.5 animations:^{
                    [self.superview layoutIfNeeded];
                } completion:^(BOOL finished) {
                    [self reloadCollectionData];
                }];
                [CPAppearanceManager animateWithDuration:0.3 delay:0.2 options:0 animations:^{
                    self.frontRemovingCell.leftLabel.alpha = 0.0;
                    self.frontRemovingCell.rightLabel.alpha = 0.0;
                } completion:nil];
            } else {
                [CPAppearanceManager animateWithDuration:0.3 animations:^{
                    self.frontRemovingCell.alpha = self.backRemovingCell.alpha = 0.0;
                }completion:^(BOOL finished) {
                    CPMemo *memo = [self.memos objectAtIndex:[self.frontCollectionView indexPathForCell:self.frontRemovingCell].row];
                    [self.memos removeObject:memo];
                    [[CPPassDataManager defaultManager] removeMemo:memo];
                    [self reloadCollectionData];
                    // TODO: Improve animation for removing a memo cell.
                }];
            }
        }];
        
        [CPProcessManager stopProcess:SCROLLING_COLLECTION_VIEW_PROCESS withPreparation:^{
            CGPoint offset = CGPointMake(self.draggingBasicOffset.x, self.draggingBasicOffset.y - translation.y);
            float contentHeight = MAX(self.frontCollectionView.contentSize.height, self.frontCollectionView.frame.size.height);
            
            if (self.style == CPMemoCollectionViewStyleInPassCell) {
                if (offset.y < 30.0) {
                    self.addingCellIndex = NS_INDEX_PATH_ZERO;
                    [self.memos insertObject:[self.delegate newMemo] atIndex:0];
                } else {
                    offset = CGPointMake(offset.x, offset.y - MEMO_CELL_HEIGHT - BOX_SEPARATOR_SIZE);
                    contentHeight = MAX(self.frontCollectionView.contentSize.height - MEMO_CELL_HEIGHT - BOX_SEPARATOR_SIZE, self.frontCollectionView.frame.size.height);
                }
            }
            
            [self reloadCollectionData];
            
            // This code is strange. I don't know why it works but it indeed works and it will fail without the second line.
            // The strange thing happens only when the style is InPassCell (that means I have to add a line to the top of collection view writting "Drag to add" and I have to adjust the offset so when it starts dragging the first line won't suddenly jump out, and the several lines before this is to fix the offset change when the top line is removed. The next two lines are used to fix the offest after I fix the offset change.)
            // When you drag the last cell up too high and it need to fall back. This two lines fix it high up there and the following if-statement creates an animation to let it fall back. However, if I don't write the second line, the front collection view will simply fall back down without animation instead of stay high up. When the second line is added, the effect turns out to be what I want.
            // I hope somebody can find out what is happening and why I need to set frontCollectionView's offset twice.
            [self setCollectionOffset:offset animated:NO];
            [self.frontCollectionView setContentOffset:offset animated:NO];
            
            if (offset.y < 0.0) {
                offset.y = 0.0;
                [self setCollectionOffset:offset animated:YES];
            } else if (offset.y > contentHeight - self.frontCollectionView.frame.size.height) {
                offset.y = contentHeight - self.frontCollectionView.frame.size.height;
                [self setCollectionOffset:offset animated:YES];
            }
        }];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (!self.collectionViewOffsetBeforeEdit) {
        self.collectionViewOffsetBeforeEdit = [NSValue valueWithCGPoint:self.frontCollectionView.contentOffset];
    }
    
    // TODO: Figure out why editing cell will not rise if starting edit cell just after search bar.
    
    NSValue *rectObj = [notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    if (self.editingCell) {
        if (rectObj) {
            CGRect rect = rectObj.CGRectValue;
            float transformedY = [self.frontCollectionView convertPoint:rect.origin fromView:nil].y;
            if (self.editingCell.frame.origin.y + self.editingCell.frame.size.height + BOX_SEPARATOR_SIZE > transformedY) {
                CGPoint offsetPoint = CGPointMake(self.frontCollectionView.contentOffset.x, self.frontCollectionView.contentOffset.y + self.editingCell.frame.origin.y + self.editingCell.frame.size.height + BOX_SEPARATOR_SIZE - transformedY);
                [self setCollectionOffset:offsetPoint animated:YES];
            }
        } else {
            [self setCollectionOffset:self.collectionViewOffsetBeforeEdit.CGPointValue animated:YES];
        }
    }
}

- (void)keyboardDidUndock:(NSNotification *)notification {
    if (self.collectionViewOffsetBeforeEdit) {
        [self setCollectionOffset:self.collectionViewOffsetBeforeEdit.CGPointValue animated:YES];
        self.collectionViewOffsetBeforeEdit = nil;
    }
}

- (void)keyboardDidHide:(NSNotification *)notification {
    if (self.collectionViewOffsetBeforeEdit && !self.editingCell) {
        [self setCollectionOffset:self.collectionViewOffsetBeforeEdit.CGPointValue animated:YES];
        self.collectionViewOffsetBeforeEdit = nil;
    }
}

#pragma mark - CPMemoCellDelegate implement

- (void)memoCellAtIndexPath:(NSIndexPath *)indexPath updateText:(NSString *)text {
    NSAssert(indexPath, @"No memo cell index path specified when updating memo cell text!");
    NSAssert(text, @"No text specified when updating memo cell text!");
    
    CPMemo *memo = [self.memos objectAtIndex:indexPath.row];
    memo.text = text;
    
    [[CPPassDataManager defaultManager] saveContext];
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([CPProcessManager isInProcess:SCROLLING_COLLECTION_VIEW_PROCESS] && self.style == CPMemoCollectionViewStyleInPassCell) {
        return self.memos.count + 1;
    } else {
        return self.memos.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *initializedCell;
    
    if (collectionView == self.frontCollectionView) {
        if (self.frontRemovingCellIndex && self.frontRemovingCellIndex.section == indexPath.section && self.frontRemovingCellIndex.row == indexPath.row) {
            // frontRemovingCellIndex is used once and then throw away
            self.frontRemovingCellIndex = nil;
            
            self.frontRemovingCell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_REMOVING forIndexPath:indexPath];
            
            self.frontRemovingCell.text = ((CPMemo *)[self.memos objectAtIndex:indexPath.row]).text;
            
            self.frontRemovingCell.label.font = [UIFont boldSystemFontOfSize:35.0];
            self.frontRemovingCell.label.backgroundColor = [UIColor clearColor];
            self.frontRemovingCell.label.textColor = [UIColor whiteColor];
            
            initializedCell = self.frontRemovingCell;
        } else {
            CPMemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_NORMAL forIndexPath:indexPath];
            
            cell.delegate = self;
            
            cell.label.font = [UIFont boldSystemFontOfSize:35.0];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textColor = [UIColor whiteColor];
            
            if ([CPProcessManager isInProcess:SCROLLING_COLLECTION_VIEW_PROCESS] && self.style == CPMemoCollectionViewStyleInPassCell) {
                if (indexPath.section == 0 && indexPath.row == 0) {
                    cell.label.text = @"Drag to add a new memo";
                } else {
                    CPMemo *memo = [self.memos objectAtIndex:indexPath.row - 1];
                    cell.label.text = memo.text;
                }
            } else {
                CPMemo *memo = [self.memos objectAtIndex:indexPath.row];
                cell.label.text = memo.text;
            }
            
            if (self.addingCellIndex && self.addingCellIndex.section == indexPath.section && self.addingCellIndex.row == indexPath.row) {
                // addingCellIndex is used once and then throw away
                self.addingCellIndex = nil;
                
                [cell startEditing];
            }
            
            initializedCell = cell;
        }
    } else {
        if (self.backRemovingCellIndex && self.backRemovingCellIndex.section == indexPath.section && self.backRemovingCellIndex.row == indexPath.row) {
            // backRemovingCellIndex is used once and then throw away
            self.backRemovingCellIndex = nil;
            
            self.backRemovingCell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_REMOVING_BACKGROUND forIndexPath:indexPath];
            
            self.backRemovingCell.color = ((CPMemo *)[self.memos objectAtIndex:indexPath.row]).password.color;
            
            initializedCell = self.backRemovingCell;
        } else {
            initializedCell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_NORMAL_BACKGROUND forIndexPath:indexPath];
            
            CPMemo *memo;
            
            if ([CPProcessManager isInProcess:SCROLLING_COLLECTION_VIEW_PROCESS] && self.style == CPMemoCollectionViewStyleInPassCell) {
                if (indexPath.row == 0) {
                    memo = [self.memos objectAtIndex:indexPath.row];
                } else {
                    memo = [self.memos objectAtIndex:indexPath.row - 1];
                }
            } else {
                memo = [self.memos objectAtIndex:indexPath.row];
            }
            
            initializedCell.backgroundColor = memo.password.color;
        }
    }
    
    return initializedCell;
}

#pragma mark - UICollectionViewDelegate implement

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([(CPMemoCell *)cell isEditing]) {
        [(CPMemoCell *)cell endEditingAtIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout implement

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.frontCollectionView.frame.size.width - BOX_SEPARATOR_SIZE * 2, MEMO_CELL_HEIGHT);
}

#pragma mark - UIScrollViewDelegate implement

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.editingCell) {
        [self.editingCell refreshingConstriants];
    }
    [self.superview layoutIfNeeded];
}

@end
