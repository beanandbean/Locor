//
//  CPSearchViewManager.m
//  Passone
//
//  Created by wangyw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSearchViewManager.h"

#import "CPAppearanceManager.h"

#import "CPPassDataManager.h"
#import "CPMemo.h"
#import "CPPassword.h"

#import "CPMemoCell.h"

#import "CPProcessManager.h"
#import "CPSearchingProcess.h"

@interface CPSearchViewManager ()

@property (weak, nonatomic) UIView *superView;

@property (weak, nonatomic) UITextField *searchBarTextField;
@property (strong, nonatomic) NSLayoutConstraint *searchBarRightConstraint;

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) NSArray *closeButtonConstraints;

@property (strong, nonatomic) UICollectionView *resultCollectionView;
@property (strong, nonatomic) NSArray *resultCollectionViewConstraints;
@property (strong, nonatomic) UIImageView *resultCollectionViewScrollIndicator;

@property (strong, nonatomic) NSArray *resultMemos;

@property (strong, nonatomic) UIView *textFieldContainer;
@property (strong, nonatomic) NSArray *textFieldContainerConstraints;

- (IBAction)closeButtonTouched:(id)sender;

- (void)handleTapOnSearchBar:(UITapGestureRecognizer *)tapGesture;

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture;

@end

@implementation CPSearchViewManager

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
        _searchBar.autocapitalizationType = NO;
        
        UIGraphicsBeginImageContext(CGSizeMake(15.0, 34.0));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0);
        CGContextFillRect(context, CGRectMake(0.0, 0.0, 15.0, 34.0));
        UIImage *backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        UIGraphicsEndImageContext();
        
        _searchBar.backgroundImage = backgroundImage;
        [_searchBar setSearchFieldBackgroundImage:backgroundImage forState:UIControlStateNormal];
        [self.searchBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnSearchBar:)]];
        
        for (UIView *view in _searchBar.subviews) {
            if ([view.class isSubclassOfClass:[UITextField class]]) {
                self.searchBarTextField = (UITextField *)view;
                self.searchBarTextField.enabled = NO;
            }
        }
    }
    return _searchBar;
}

- (NSLayoutConstraint *)searchBarRightConstraint {
    if (!_searchBarRightConstraint) {
        _searchBarRightConstraint = [CPAppearanceManager constraintWithItem:self.searchBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight];
    }
    return _searchBarRightConstraint;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        _closeButton.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        [_closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (NSArray *)closeButtonConstraints {
    if (!_closeButtonConstraints) {
        CGSize predictedSize = [@"Close" sizeWithFont:self.closeButton.titleLabel.font];
        _closeButtonConstraints = [[NSArray alloc] initWithObjects:
                                   [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0],
                                   [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0],
                                   [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeRight multiplier:1.0 constant:10.0],
                                   [CPAppearanceManager constraintWithItem:self.closeButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight],
                                   [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:predictedSize.width + 20.0],
                                   nil];
    }
    return _closeButtonConstraints;
}

- (UICollectionView *)resultCollectionView {
    if (!_resultCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        layout.minimumLineSpacing = 10.0;
        layout.itemSize = CGSizeMake(self.searchBar.bounds.size.width - 20.0, 66.0);
        _resultCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _resultCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _resultCollectionView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        _resultCollectionView.showsHorizontalScrollIndicator = NO;
        _resultCollectionView.dataSource = self;
        _resultCollectionView.delegate = self;
        
        [_resultCollectionView flashScrollIndicators];
        
        [_resultCollectionView registerClass:[CPMemoCell class] forCellWithReuseIdentifier:@"CPMemoCell"];
        
        [_resultCollectionView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    }
    return _resultCollectionView;
}

- (NSArray *)resultCollectionViewConstraints {
    if (!_resultCollectionViewConstraints) {
        _resultCollectionViewConstraints = [[NSArray alloc] initWithObjects:
                                            [NSLayoutConstraint constraintWithItem:self.resultCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0],
                                            [NSLayoutConstraint constraintWithItem:self.resultCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0],
                                            [CPAppearanceManager constraintWithItem:self.resultCollectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeLeft],
                                            [CPAppearanceManager constraintWithItem:self.resultCollectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight],
                                            nil];
    }
    return _resultCollectionViewConstraints;
}

- (UIImageView *)resultCollectionViewScrollIndicator {
    if (!_resultCollectionViewScrollIndicator) {
        for (UIView *subview in self.resultCollectionView.subviews) {
            if (subview.class == [UIImageView class]) {
                _resultCollectionViewScrollIndicator = (UIImageView *)subview;
            }
        }
    }
    return _resultCollectionViewScrollIndicator;
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
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.resultCollectionView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.resultCollectionView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.resultCollectionView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                                          [NSLayoutConstraint constraintWithItem:self.textFieldContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.resultCollectionView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                                          nil];
    }
    return _textFieldContainerConstraints;
}

- (id)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        self.superView = superView;
        [self.superView addSubview:self.searchBar];
        
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0]];
        [self.superView addConstraint:[CPAppearanceManager constraintWithItem:self.searchBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeLeft]];
        [self.superView addConstraint:self.searchBarRightConstraint];
    }
    return self;
}

- (IBAction)closeButtonTouched:(id)sender {
    [CPProcessManager stopProcess:[CPSearchingProcess process] withPreparation:^{
        [self.superView removeConstraints:self.textFieldContainerConstraints];
        [self.textFieldContainer removeFromSuperview];
        
        self.textFieldContainer = nil;
        self.textFieldContainerConstraints = nil;
        
        [CPAppearanceManager animateWithDuration:0.3 animations:^{
            self.closeButton.alpha = 0.0;
            self.resultCollectionView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.superView removeConstraints:self.closeButtonConstraints];
            [self.superView removeConstraints:self.resultCollectionViewConstraints];
            [self.superView addConstraint:self.searchBarRightConstraint];
            [self.closeButton removeFromSuperview];
            [self.resultCollectionView removeFromSuperview];
            
            self.resultCollectionView = nil;
            self.resultCollectionViewConstraints = nil;
            
            self.searchBar.text = @"";
            if ([self.searchBar isFirstResponder]) {
                [self.searchBar resignFirstResponder];
            }
            self.resultMemos = nil;
            [CPAppearanceManager animateWithDuration:0.5 animations:^{
                [self.superView layoutIfNeeded];
            }];
        }];
    }];
}

- (void)handleTapOnSearchBar:(UITapGestureRecognizer *)tapGesture {
    self.searchBarTextField.enabled = YES;
    if (![self.searchBar isFirstResponder]) {
        if ([CPMemoCell editingCell]) {
            [[CPMemoCell editingCell] endEditingAtIndexPath:[self.resultCollectionView indexPathForCell:[CPMemoCell editingCell]]];
        }
        [self.searchBar becomeFirstResponder];
    }
}

static CGPoint basicOffset;

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        basicOffset = self.resultCollectionView.contentOffset;

        if (self.resultCollectionViewScrollIndicator) {
            self.resultCollectionViewScrollIndicator.alpha = 0.8;
            self.resultCollectionViewScrollIndicator.frame = CGRectMake(self.resultCollectionViewScrollIndicator.frame.origin.x, self.resultCollectionView.contentOffset.y * self.resultCollectionView.contentSize.height / (self.resultCollectionView.contentSize.height - self.resultCollectionView.frame.size.height), self.resultCollectionViewScrollIndicator.frame.size.width, powf(self.resultCollectionView.frame.size.height, 2.0) / self.resultCollectionView.contentSize.height);
        }
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        CGPoint offset = CGPointMake(basicOffset.x, basicOffset.y - translation.y);
        [self.resultCollectionView setContentOffset:offset animated:NO];
        if (self.resultCollectionViewScrollIndicator) {
            self.resultCollectionViewScrollIndicator.alpha = 0.8;
            self.resultCollectionViewScrollIndicator.frame = CGRectMake(self.resultCollectionViewScrollIndicator.frame.origin.x, offset.y * self.resultCollectionView.contentSize.height / (self.resultCollectionView.contentSize.height - self.resultCollectionView.frame.size.height), self.resultCollectionViewScrollIndicator.frame.size.width, powf(self.resultCollectionView.frame.size.height, 2.0) / self.resultCollectionView.contentSize.height);
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
        CGPoint offset = CGPointMake(basicOffset.x, basicOffset.y - translation.y);
        [self.resultCollectionView setContentOffset:offset animated:NO];
        if (offset.y < 0.0) {
            offset.y = 0.0;
            [self.resultCollectionView setContentOffset:offset animated:YES];
        } else if (offset.y > self.resultCollectionView.contentSize.height - self.resultCollectionView.frame.size.height) {
            offset.y = self.resultCollectionView.contentSize.height - self.resultCollectionView.frame.size.height;
            [self.resultCollectionView setContentOffset:offset animated:YES];
        }
        if (self.resultCollectionViewScrollIndicator) {
            // Decorative animation. Not protecting in CPAppearanceManager
            [UIView animateWithDuration:0.3 animations:^{
                self.resultCollectionViewScrollIndicator.alpha = 0.0;
            }];
        }
    }
}

#pragma mark - CPMemoCellDelegate implement

- (void)memoCellAtIndexPath:(NSIndexPath *)indexPath updateText:(NSString *)text {
    NSAssert(indexPath, @"");
    NSAssert(text, @"");
    
    CPMemo *memo = [self.resultMemos objectAtIndex:indexPath.row];
    memo.text = text;
    
    [[CPPassDataManager defaultManager] saveContext];
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resultMemos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPMemo *memo = [self.resultMemos objectAtIndex:indexPath.row];

    static NSString *cellIdentifier = @"CPMemoCell";
    CPMemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    cell.backgroundColor = memo.password.color;
    cell.label.text = memo.text;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate implement

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([(CPMemoCell *)cell isEditing]) {
        [(CPMemoCell *)cell endEditingAtIndexPath:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate implement

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([CPMemoCell editingCell]) {
        [[CPMemoCell editingCell] refreshingConstriants];
    }
    [self.superView layoutIfNeeded];
}

#pragma mark - UISearchBarDelegate implement

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([CPProcessManager isInProcess:[CPSearchingProcess process]]) {
        self.resultMemos = [[CPPassDataManager defaultManager] memosContainText:searchBar.text];
        [self.resultCollectionView reloadData];
        return YES;
    } else {
        return [CPProcessManager startProcess:[CPSearchingProcess process] withPreparation:^{
            self.resultMemos = [[CPPassDataManager defaultManager] memosContainText:searchBar.text];
            
            self.closeButton.alpha = 0.0;
            self.resultCollectionView.alpha = 0.0;
            
            [self.superView addSubview:self.closeButton];
            [self.superView addSubview:self.resultCollectionView];
            [self.superView removeConstraint:self.searchBarRightConstraint];
            [self.superView addConstraints:self.closeButtonConstraints];
            [self.superView addConstraints:self.resultCollectionViewConstraints];
            
            [CPAppearanceManager animateWithDuration:0.5 animations:^{
                [self.superView layoutIfNeeded];
            } completion:^(BOOL finished) {
                [CPAppearanceManager animateWithDuration:0.3 animations:^{
                    self.closeButton.alpha = 1.0;
                    self.resultCollectionView.alpha = 1.0;
                } completion:^(BOOL finished) {
                    [self.superView addSubview:self.textFieldContainer];
                    [self.superView addConstraints:self.textFieldContainerConstraints];
                    [CPMemoCell setTextFieldContainer:self.textFieldContainer];
                }];
            }];
        }];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.searchBarTextField.enabled = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultMemos = [[CPPassDataManager defaultManager] memosContainText:searchText];
    [self.resultCollectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if ([CPMemoCell editingCell].isEditing) {
        [[CPMemoCell editingCell] endEditingAtIndexPath:[self.resultCollectionView indexPathForCell:[CPMemoCell editingCell]]];
    }
}

@end
