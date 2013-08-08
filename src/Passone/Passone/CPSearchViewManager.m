//
//  CPSearchViewManager.m
//  Passone
//
//  Created by wangyw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSearchViewManager.h"

#import "CPMemoCollectionViewManager.h"

#import "CPAppearanceManager.h"

#import "CPPassDataManager.h"

#import "CPProcessManager.h"
#import "CPSearchingProcess.h"

@interface CPSearchViewManager ()

@property (weak, nonatomic) UIView *superView;

@property (weak, nonatomic) UITextField *searchBarTextField;
@property (strong, nonatomic) NSLayoutConstraint *searchBarRightConstraint;

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) NSArray *closeButtonConstraints;

@property (strong, nonatomic) UIView *resultContainer;
@property (strong, nonatomic) NSArray *resultContainerConstraints;

@property (strong, nonatomic) CPMemoCollectionViewManager *resultMemoCollectionViewManager;

- (IBAction)closeButtonTouched:(id)sender;

- (void)handleTapOnSearchBar:(UITapGestureRecognizer *)tapGesture;

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

- (UIView *)resultContainer {
    if (!_resultContainer) {
        _resultContainer = [[UIView alloc] init];
        _resultContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _resultContainer;
}

- (NSArray *)resultContainerConstraints {
    if (!_resultContainerConstraints) {
        _resultContainerConstraints = [[NSArray alloc] initWithObjects:
                                       [NSLayoutConstraint constraintWithItem:self.resultContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0],
                                       [NSLayoutConstraint constraintWithItem:self.resultContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0],
                                       [CPAppearanceManager constraintWithItem:self.resultContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeLeft],
                                       [CPAppearanceManager constraintWithItem:self.resultContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight],
                                       nil];
    }
    return _resultContainerConstraints;
}

- (CPMemoCollectionViewManager *)resultMemoCollectionViewManager {
    if (!_resultMemoCollectionViewManager) {
        _resultMemoCollectionViewManager = [[CPMemoCollectionViewManager alloc] initWithSuperview:self.resultContainer andStyle:CPMemoCollectionViewStyleSearch];
    }
    return _resultMemoCollectionViewManager;
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
    [self.resultMemoCollectionViewManager endEditing];
    [CPProcessManager stopProcess:[CPSearchingProcess process] withPreparation:^{
        [CPAppearanceManager animateWithDuration:0.3 animations:^{
            self.closeButton.alpha = 0.0;
            self.resultMemoCollectionViewManager.collectionView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.superView removeConstraints:self.closeButtonConstraints];
            [self.superView removeConstraints:self.resultContainerConstraints];
            [self.superView addConstraint:self.searchBarRightConstraint];
            [self.closeButton removeFromSuperview];
            [self.resultContainer removeFromSuperview];
            
            self.resultContainer = nil;
            self.resultContainerConstraints = nil;
            self.resultMemoCollectionViewManager = nil;
            
            self.searchBar.text = @"";
            if ([self.searchBar isFirstResponder]) {
                [self.searchBar resignFirstResponder];
            }
            [CPAppearanceManager animateWithDuration:0.5 animations:^{
                [self.superView layoutIfNeeded];
            }];
        }];
    }];
}

- (void)handleTapOnSearchBar:(UITapGestureRecognizer *)tapGesture {
    self.searchBarTextField.enabled = YES;
    if (![self.searchBar isFirstResponder]) {
        [self.resultMemoCollectionViewManager endEditing];
        [self.searchBar becomeFirstResponder];
    }
}

#pragma mark - UISearchBarDelegate implement

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([CPProcessManager isInProcess:[CPSearchingProcess process]]) {
        self.resultMemoCollectionViewManager.memos = [[[CPPassDataManager defaultManager] memosContainText:searchBar.text] mutableCopy];
        return YES;
    } else {
        return [CPProcessManager startProcess:[CPSearchingProcess process] withPreparation:^{
            [self.superView addSubview:self.closeButton];
            [self.superView addSubview:self.resultContainer];
            [self.superView removeConstraint:self.searchBarRightConstraint];
            [self.superView addConstraints:self.closeButtonConstraints];
            [self.superView addConstraints:self.resultContainerConstraints];
                        
            self.closeButton.alpha = 0.0;
            self.resultMemoCollectionViewManager.collectionView.alpha = 0.0;
            self.resultMemoCollectionViewManager.memos = [[[CPPassDataManager defaultManager] memosContainText:searchBar.text] mutableCopy];
            
            [CPAppearanceManager animateWithDuration:0.5 animations:^{
                [self.superView layoutIfNeeded];
            } completion:^(BOOL finished) {
                [CPAppearanceManager animateWithDuration:0.3 animations:^{
                    self.closeButton.alpha = 1.0;
                    self.resultMemoCollectionViewManager.collectionView.alpha = 1.0;
                }];
            }];
        }];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.searchBarTextField.enabled = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultMemoCollectionViewManager.memos = [[[CPPassDataManager defaultManager] memosContainText:searchText] mutableCopy];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.resultMemoCollectionViewManager endEditing];
}

@end
