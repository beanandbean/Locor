//
//  CPMemoCollectionViewManager.m
//  Passone
//
//  Created by wangsw on 8/4/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCollectionViewManager.h"

#import "CPMemoCell.h"
#import "CPMemoCellRemoving.h"

#import "CPAppearanceManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"
#import "CPMemo.h"

#import "CPProcessManager.h"
#import "CPEditingMemoCellProcess.h"
#import "CPRemovingMemoCellProcess.h"
#import "CPScrollingCollectionViewProcess.h"

static NSString *CELL_REUSE_IDENTIFIER_NORMAL = @"normal-cell";
static NSString *CELL_REUSE_IDENTIFIER_REMOVING = @"removing-cell";

@interface CPMemoCollectionViewManager ()

@property (nonatomic) CPMemoCollectionViewStyle style;

@property (weak, nonatomic) UIView *superview;

@property (strong, nonatomic) NSArray *collectionViewConstraints;

@property (nonatomic) NSValue *collectionViewOffsetBeforeEdit;

@property (strong, nonatomic) UIImage *removingCellImage;

@property (nonatomic) CGPoint draggingBasicOffset;
@property (weak, nonatomic) CPMemoCell *addingCell;
@property (strong, nonatomic) NSIndexPath *addingCellIndex;

@property (weak, nonatomic) CPMemoCellRemoving *removingCell;
@property (strong, nonatomic) NSIndexPath *removingCellIndex;
@property (strong, nonatomic) NSIndexPath *removingCellIndexForLayout;

@end

@implementation CPMemoCollectionViewManager

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10.0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        if (self.style == CPMemoCollectionViewStyleSearch) {
            _collectionView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.9];
            layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        } else if (self.style == CPMemoCollectionViewStyleInPassCell) {
            _collectionView.backgroundColor = [UIColor clearColor];
            layout.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
        } else {
            NSAssert(NO, @"Unexpected memo collection view style!");
        }
        
        [_collectionView registerClass:[CPMemoCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_NORMAL];
        [_collectionView registerClass:[CPMemoCellRemoving class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_REMOVING];
        
        [_collectionView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    }
    return _collectionView;
}

- (NSArray *)collectionViewConstraints {
    if (!_collectionViewConstraints) {
        _collectionViewConstraints = [[NSArray alloc] initWithObjects:
                                      [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                                      [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                                      [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                                      [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                                      nil];
    }
    return _collectionViewConstraints;
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
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                                          nil];
    }
    return _textFieldContainerConstraints;
}

- (void)setMemos:(NSMutableArray *)memos {
    _memos = memos;
    [self endEditing];
    [self.collectionView reloadData];
}

- (id)initWithSuperview:(UIView *)superview style:(CPMemoCollectionViewStyle)style andDelegate:(id<CPMemoCollectionViewManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.style = style;
        self.memos = [NSArray array];
        self.delegate = delegate;
        self.superview = superview;
        
        [self.superview addSubview:self.collectionView];
        [self.superview addSubview:self.textFieldContainer];
        [self.superview addConstraints:self.collectionViewConstraints];
        [self.superview addConstraints:self.textFieldContainerConstraints];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidResize:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidResize:) name:UIKeyboardDidChangeFrameNotification object:nil];
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
        [self.editingCell endEditingAtIndexPath:[self.collectionView indexPathForCell:self.editingCell]];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        if ((![CPProcessManager isInProcess:[CPRemovingMemoCellProcess process]] && (![CPProcessManager isInProcess:[CPScrollingCollectionViewProcess process]]))) {
            CGPoint location = [panGesture locationInView:panGesture.view];
            NSIndexPath *panningCellIndex = [self.collectionView indexPathForItemAtPoint:location];
            
            if (self.editingCell) {
                [self.editingCell endEditingAtIndexPath:[self.collectionView indexPathForCell:self.editingCell]];
            }
            
            // TODO: Determine if the memo cell should fall back to original position when you start removing after it is raised up when editing.
            
            if (fabsf(translation.x) > fabsf(translation.y) && panningCellIndex) {
                [CPProcessManager startProcess:[CPRemovingMemoCellProcess process] withPreparation:^{
                    CPMemoCell *panningCell = (CPMemoCell *)[self.collectionView cellForItemAtIndexPath:panningCellIndex];
                    
                    UIGraphicsBeginImageContext(panningCell.bounds.size);
                    [panningCell.layer renderInContext:UIGraphicsGetCurrentContext()];
                    self.removingCellImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    self.removingCellIndex = panningCellIndex;
                    [self.collectionView reloadData];
                }];
            } else {
                self.collectionViewOffsetBeforeEdit = nil;
                [CPProcessManager startProcess:[CPScrollingCollectionViewProcess process] withPreparation:^{
                    if (self.style == CPMemoCollectionViewStyleInPassCell) {
                        self.draggingBasicOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + 76.0);
                    } else {
                        self.draggingBasicOffset = self.collectionView.contentOffset;
                    }
                    [self.collectionView reloadData];
                }];
            }
        }
        if ([CPProcessManager isInProcess:[CPRemovingMemoCellProcess process]]) {
            [self.removingCell setImageLeftOffset:translation.x];
        }
        if ([CPProcessManager isInProcess:[CPScrollingCollectionViewProcess process]]) {
            CGPoint offset = CGPointMake(self.draggingBasicOffset.x, self.draggingBasicOffset.y - translation.y);
            [self.collectionView setContentOffset:offset animated:NO];
            
            if (self.addingCell) {
                if (offset.y < 30.0) {
                    self.addingCell.label.text = @"Release to add a new memo";
                } else {
                    self.addingCell.label.text = @"Drag to add a new memo";
                }
            }
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        [CPProcessManager stopProcess:[CPRemovingMemoCellProcess process] withPreparation:^{
            if (fabsf(translation.x) < self.removingCell.contentView.frame.size.width / 2) {
                [self.removingCell setImageLeftOffset:0.0];
                [CPAppearanceManager animateWithDuration:0.5 animations:^{
                    [self.superview layoutIfNeeded];
                } completion:^(BOOL finished) {
                    [self.collectionView reloadData];
                }];
                [CPAppearanceManager animateWithDuration:0.3 delay:0.2 options:0 animations:^{
                    self.removingCell.leftLabel.alpha = 0.0;
                    self.removingCell.rightLabel.alpha = 0.0;
                } completion:nil];
            } else {
                [CPAppearanceManager animateWithDuration:0.3 animations:^{
                    self.removingCell.alpha = 0.0;
                }completion:^(BOOL finished) {
                    CPMemo *memo = [self.memos objectAtIndex:[self.collectionView indexPathForCell:self.removingCell].row];
                    [self.memos removeObject:memo];
                    [[CPPassDataManager defaultManager] removeMemo:memo];
                    [self.collectionView reloadData];
                    // TODO: Improve animation for removing a memo cell.
                }];
            }
        }];
        
        [CPProcessManager stopProcess:[CPScrollingCollectionViewProcess process] withPreparation:^{
            CGPoint offset = CGPointMake(self.draggingBasicOffset.x, self.draggingBasicOffset.y - translation.y);
            float contentHeight = MAX(self.collectionView.contentSize.height, self.collectionView.frame.size.height);

            if (self.style == CPMemoCollectionViewStyleInPassCell) {
                if (self.addingCell && offset.y < 30.0) {
                    self.addingCellIndex = [self.collectionView indexPathForCell:self.addingCell];
                    self.addingCell = nil;
                    [self.memos insertObject:[self.delegate newMemo] atIndex:0];
                } else {
                    offset = CGPointMake(offset.x, offset.y - 76.0);
                    contentHeight = MAX(self.collectionView.contentSize.height - 76.0, self.collectionView.frame.size.height);
                }
            }
            
            [self.collectionView reloadData];
            
            [self.collectionView setContentOffset:offset animated:NO];
            if (offset.y < 0.0) {
                offset.y = 0.0;
                [self.collectionView setContentOffset:offset animated:YES];
            } else if (offset.y > contentHeight - self.collectionView.frame.size.height) {
                offset.y = contentHeight - self.collectionView.frame.size.height;
                [self.collectionView setContentOffset:offset animated:YES];
            }
        }];
    }
}

- (void)keyboardDidResize:(NSNotification *)notification {
    if (!self.collectionViewOffsetBeforeEdit) {
        self.collectionViewOffsetBeforeEdit = [NSValue valueWithCGPoint:self.collectionView.contentOffset];
    }
    
    // TODO: Determine if the keyboard is splited or not when resize notification come to memo collection view manager.
    
    NSValue *rectObj = [notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    if (self.editingCell) {
        if (rectObj) {
            CGRect rect = rectObj.CGRectValue;
            float transformedY = [self.collectionView convertPoint:rect.origin fromView:[UIApplication sharedApplication].keyWindow.subviews.lastObject].y - 20.0;
            if (self.editingCell.frame.origin.y + self.editingCell.frame.size.height + 10 > transformedY) {
                [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + self.editingCell.frame.origin.y + self.editingCell.frame.size.height + 10 - transformedY) animated:YES];
            }
        } else {
            [self.collectionView setContentOffset:self.collectionViewOffsetBeforeEdit.CGPointValue animated:YES];
        }
    }
}

- (void)keyboardDidHide:(NSNotification *)notification {
    if (self.collectionViewOffsetBeforeEdit && !self.editingCell) {
        [self.collectionView setContentOffset:self.collectionViewOffsetBeforeEdit.CGPointValue animated:YES];
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
    if ([CPProcessManager isInProcess:[CPScrollingCollectionViewProcess process]] && self.style == CPMemoCollectionViewStyleInPassCell) {
        return self.memos.count + 1;
    } else {
        return self.memos.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *initializedCell;
    
    if (self.removingCellIndex && self.removingCellIndex.section == indexPath.section && self.removingCellIndex.row == indexPath.row) {
        // removingCellIndex is used once and then throw away
        self.removingCellIndex = nil;
        
        self.removingCell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_REMOVING forIndexPath:indexPath];
        
        self.removingCell.image = self.removingCellImage;
        
        initializedCell = self.removingCell;
    } else {
        
        CPMemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_NORMAL forIndexPath:indexPath];
        
        cell.delegate = self;
        
        cell.label.font = [UIFont boldSystemFontOfSize:35.0];
        cell.label.backgroundColor = [UIColor clearColor];
        
        CPMemo *memo;
        if ([CPProcessManager isInProcess:[CPScrollingCollectionViewProcess process]] && self.style == CPMemoCollectionViewStyleInPassCell) {
            if (indexPath.row == 0) {
                cell.label.text = @"Drag to add a new memo";
                cell.backgroundColor = [UIColor whiteColor];
                cell.label.textColor = [UIColor blackColor];
                
                self.addingCell = cell;
                
                return cell;
            } else {
                memo = [self.memos objectAtIndex:indexPath.row - 1];
            }
        } else {
            memo = [self.memos objectAtIndex:indexPath.row];
        }
        
        if (self.style == CPMemoCollectionViewStyleSearch) {
            cell.backgroundColor = memo.password.color;
            cell.label.textColor = [UIColor whiteColor];
        } else if (self.style == CPMemoCollectionViewStyleInPassCell) {
            cell.backgroundColor = [UIColor whiteColor];
            cell.label.textColor = [UIColor blackColor];
        } else {
            NSAssert(NO, @"Unexpected memo collection view style!");
        }

        cell.label.text = memo.text;
        
        if (self.addingCellIndex && self.addingCellIndex.section == indexPath.section && self.addingCellIndex.row == indexPath.row) {
            // removingCellIndex is used once and then throw away
            self.addingCellIndex = nil;
            
            [cell startEditing];
        }

        initializedCell = cell;
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
    if (self.removingCellIndexForLayout && self.removingCellIndexForLayout.section == indexPath.section && self.removingCellIndexForLayout.row == indexPath.row) {
        // removingCellIndex is used once and then throw away
        self.removingCellIndexForLayout = nil;
        
        return CGSizeMake(self.collectionView.frame.size.width - 20.0, 0.0);
    } else {
        return CGSizeMake(self.collectionView.frame.size.width - 20.0, 66.0);
    }
}

#pragma mark - UIScrollViewDelegate implement

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.editingCell) {
        [self.editingCell refreshingConstriants];
    }
    [self.superview layoutIfNeeded];
}

@end
