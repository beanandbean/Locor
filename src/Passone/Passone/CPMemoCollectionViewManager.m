//
//  CPMemoCollectionViewManager.m
//  Passone
//
//  Created by wangsw on 8/31/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCollectionViewManager.h"

#import "CPPassoneConfig.h"

#import "CPMemoCell.h"
#import "CPMemoCellRemoving.h"

#import "CPAppearanceManager.h"

#import "CPPassDataManager.h"

static NSString *CELL_REUSE_IDENTIFIER_NORMAL = @"normal-cell";
static NSString *CELL_REUSE_IDENTIFIER_REMOVING = @"removing-cell";

@interface CPMemoCollectionViewManager ()

@property (nonatomic) CPMemoCollectionViewStyle style;

@property (weak, nonatomic) UIView *superview;

@property (weak, nonatomic) UIView *frontLayer;
@property (weak, nonatomic) UIView *backLayer;

@property (strong, nonatomic) NSArray *frontCollectionViewConstraints;
@property (strong, nonatomic) NSArray *backCollectionViewConstraints;

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
    [collectionView registerClass:[CPMemoCellRemoving class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_REMOVING];
    
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
    [self.frontCollectionView reloadData];
    [self.backCollectionView reloadData];
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
                [self.frontCollectionView setContentOffset:offsetPoint animated:YES];
                [self.backCollectionView setContentOffset:offsetPoint animated:YES];
            }
        } else {
            [self.frontCollectionView setContentOffset:self.collectionViewOffsetBeforeEdit.CGPointValue animated:YES];
            [self.backCollectionView setContentOffset:self.collectionViewOffsetBeforeEdit.CGPointValue animated:YES];
        }
    }
}

- (void)keyboardDidUndock:(NSNotification *)notification {
    if (self.collectionViewOffsetBeforeEdit) {
        [self.frontCollectionView setContentOffset:self.collectionViewOffsetBeforeEdit.CGPointValue animated:YES];
        [self.backCollectionView setContentOffset:self.collectionViewOffsetBeforeEdit.CGPointValue animated:YES];
        self.collectionViewOffsetBeforeEdit = nil;
    }
}

- (void)keyboardDidHide:(NSNotification *)notification {
    if (self.collectionViewOffsetBeforeEdit && !self.editingCell) {
        [self.frontCollectionView setContentOffset:self.collectionViewOffsetBeforeEdit.CGPointValue animated:YES];
        [self.backCollectionView setContentOffset:self.collectionViewOffsetBeforeEdit.CGPointValue animated:YES];
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

#pragma mark - UICollectionViewDelegate implement

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([(CPMemoCell *)cell isEditing]) {
        [(CPMemoCell *)cell endEditingAtIndexPath:indexPath];
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
