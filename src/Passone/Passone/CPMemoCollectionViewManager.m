//
//  CPMemoCollectionViewManager.m
//  Passone
//
//  Created by wangsw on 8/4/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCollectionViewManager.h"

#import "CPMemoCellRemoving.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"
#import "CPMemo.h"

#import "CPProcessManager.h"
#import "CPRemovingMemoCellProcess.h"
#import "CPScrollingCollectionViewProcess.h"

static NSString *CELL_REUSE_IDENTIFIER_NORMAL = @"normal-cell";
static NSString *CELL_REUSE_IDENTIFIER_REMOVING = @"removing-cell";

@interface CPMemoCollectionViewManager ()

@property (strong, nonatomic) UIView *superview;

@property (strong, nonatomic) NSArray *collectionViewConstraints;
@property (strong, nonatomic) UIImageView *collectionViewScrollIndicator;

@property (strong, nonatomic) UIView *textFieldContainer;
@property (strong, nonatomic) NSArray *textFieldContainerConstraints;

@property (strong, nonatomic) UIImage *removingCellImage;

@property (nonatomic) CGPoint draggingBasicOffset;

@property (nonatomic) CPMemoCellRemoving *removingCell;
@property (nonatomic) NSIndexPath *removingCellIndex;

@end

@implementation CPMemoCollectionViewManager

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        layout.minimumLineSpacing = 10.0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView flashScrollIndicators];
        
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

- (UIImageView *)collectionViewScrollIndicator {
    if (!_collectionViewScrollIndicator) {
        for (UIView *subview in self.collectionView.subviews) {
            if (subview.class == [UIImageView class]) {
                _collectionViewScrollIndicator = (UIImageView *)subview;
            }
        }
    }
    return _collectionViewScrollIndicator;
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

- (void)setMemos:(NSArray *)memos {
    _memos = memos;
    [self.collectionView reloadData];
}

- (id)initWithSuperview:(UIView *)superview {
    self = [super init];
    if (self) {
        self.memos = [NSArray array];
        self.superview = superview;
        
        [self.superview addSubview:self.collectionView];
        [self.superview addSubview:self.textFieldContainer];
        [self.superview addConstraints:self.collectionViewConstraints];
        [self.superview addConstraints:self.textFieldContainerConstraints];
        
        [CPMemoCell setTextFieldContainer:self.textFieldContainer];
    }
    return self;
}

- (void)endEditing {
    if ([CPMemoCell editingCell]) {
        [[CPMemoCell editingCell] endEditingAtIndexPath:[self.collectionView indexPathForCell:[CPMemoCell editingCell]]];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        if ((![CPProcessManager isInProcess:[CPRemovingMemoCellProcess process]] && (![CPProcessManager isInProcess:[CPScrollingCollectionViewProcess process]]))) {
            CGPoint location = [panGesture locationInView:panGesture.view];
            NSIndexPath *panningCellIndex = [self.collectionView indexPathForItemAtPoint:location];
            if (fabsf(translation.x) > fabsf(translation.y) && panningCellIndex) {
                [CPProcessManager startProcess:[CPRemovingMemoCellProcess process] withPreparation:^{
                    CPMemoCell *panningCell = (CPMemoCell *)[self.collectionView cellForItemAtIndexPath:panningCellIndex];
                    if ([panningCell isEditing]) {
                        [panningCell endEditingAtIndexPath:panningCellIndex];
                    }
                    
                    UIGraphicsBeginImageContext(panningCell.bounds.size);
                    [panningCell.layer renderInContext:UIGraphicsGetCurrentContext()];
                    self.removingCellImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    self.removingCellIndex = panningCellIndex;
                    [self.collectionView reloadData];
                }];
            } else {
                [CPProcessManager startProcess:[CPScrollingCollectionViewProcess process] withPreparation:^{
                    self.draggingBasicOffset = self.collectionView.contentOffset;
                    
                    if (self.collectionViewScrollIndicator) {
                        self.collectionViewScrollIndicator.alpha = 0.8;
                        self.collectionViewScrollIndicator.frame = CGRectMake(self.collectionViewScrollIndicator.frame.origin.x, self.collectionView.contentOffset.y * self.collectionView.contentSize.height / (self.collectionView.contentSize.height - self.collectionView.frame.size.height), self.collectionViewScrollIndicator.frame.size.width, powf(self.collectionView.frame.size.height, 2.0) / self.collectionView.contentSize.height);
                    }
                }];
            }
        }
        if ([CPProcessManager isInProcess:[CPRemovingMemoCellProcess process]]) {
            // TODO: When removing a memo cell, show 'Swipe/Release to remove'.
            [self.removingCell setImageLeftOffset:translation.x];
        }
        if ([CPProcessManager isInProcess:[CPScrollingCollectionViewProcess process]]) {
            CGPoint offset = CGPointMake(self.draggingBasicOffset.x, self.draggingBasicOffset.y - translation.y);
            [self.collectionView setContentOffset:offset animated:NO];
            if (self.collectionViewScrollIndicator) {
                self.collectionViewScrollIndicator.alpha = 0.8;
                self.collectionViewScrollIndicator.frame = CGRectMake(self.collectionViewScrollIndicator.frame.origin.x, offset.y * self.collectionView.contentSize.height / (self.collectionView.contentSize.height - self.collectionView.frame.size.height), self.collectionViewScrollIndicator.frame.size.width, powf(self.collectionView.frame.size.height, 2.0) / self.collectionView.contentSize.height);
            }
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        [CPProcessManager stopProcess:[CPRemovingMemoCellProcess process] withPreparation:^{
            // TODO: Write code to stop removing a memo cell.
            [self.collectionView reloadData];
        }];
        [CPProcessManager stopProcess:[CPScrollingCollectionViewProcess process] withPreparation:^{
            CGPoint translation = [panGesture translationInView:panGesture.view];
            [panGesture setTranslation:CGPointZero inView:panGesture.view];
            CGPoint offset = CGPointMake(self.draggingBasicOffset.x, self.draggingBasicOffset.y - translation.y);
            [self.collectionView setContentOffset:offset animated:NO];
            if (offset.y < 0.0) {
                offset.y = 0.0;
                [self.collectionView setContentOffset:offset animated:YES];
            } else if (offset.y > self.collectionView.contentSize.height - self.collectionView.frame.size.height) {
                offset.y = self.collectionView.contentSize.height - self.collectionView.frame.size.height;
                [self.collectionView setContentOffset:offset animated:YES];
            }
            if (self.collectionViewScrollIndicator) {
                // Decorative animation. Not protecting in CPAppearanceManager
                [UIView animateWithDuration:0.3 animations:^{
                    self.collectionViewScrollIndicator.alpha = 0.0;
                }];
            }
        }];
    }
}

#pragma mark - CPMemoCellDelegate implement

- (void)memoCellAtIndexPath:(NSIndexPath *)indexPath updateText:(NSString *)text {
    NSAssert(indexPath, @"");
    NSAssert(text, @"");
    
    CPMemo *memo = [self.memos objectAtIndex:indexPath.row];
    memo.text = text;
    
    [[CPPassDataManager defaultManager] saveContext];
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.memos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPMemo *memo = [self.memos objectAtIndex:indexPath.row];
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
        cell.backgroundColor = memo.password.color;
        cell.label.text = memo.text;
        
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
    return CGSizeMake(self.collectionView.bounds.size.width - 20.0, 66.0);
}

#pragma mark - UIScrollViewDelegate implement

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([CPMemoCell editingCell]) {
        [[CPMemoCell editingCell] refreshingConstriants];
    }
    [self.superview layoutIfNeeded];
}

@end
