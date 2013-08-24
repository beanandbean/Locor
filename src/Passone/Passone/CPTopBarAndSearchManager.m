//
//  CPSearchViewManager.m
//  Passone
//
//  Created by wangyw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPTopBarAndSearchManager.h"

#import "CPMemoCollectionViewManager.h"

#import "CPAppearanceManager.h"

#import "CPPassDataManager.h"

#import "CPProcessManager.h"
#import "CPSearchingProcess.h"

@interface CPTopBarAndSearchManager ()

@property (weak, nonatomic) UIView *superView;

@property (weak, nonatomic) UITextField *searchBarTextField;

@property (strong, nonatomic) UIButton *barButton;

@property (strong, nonatomic) UIView *resultContainer;
@property (strong, nonatomic) NSArray *resultContainerConstraints;

@property (strong, nonatomic) CPMemoCollectionViewManager *resultMemoCollectionViewManager;

- (IBAction)barButtonTouched:(id)sender;

- (void)handleTapOnSearchBar:(UITapGestureRecognizer *)tapGesture;

@end

@implementation CPTopBarAndSearchManager

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
        _searchBar.autocapitalizationType = NO;

        UIGraphicsBeginImageContext(CGSizeMake(1.0, 34.0));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0);
        CGContextFillRect(context, CGRectMake(0.0, 0.0, 1.0, 34.0));
        UIImage *backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        UIGraphicsEndImageContext();
        
        _searchBar.backgroundImage = backgroundImage;
        [_searchBar setSearchFieldBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        [self.searchBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnSearchBar:)]];

        for (UIView *view in _searchBar.subviews) {
            if ([view.class isSubclassOfClass:[UITextField class]]) {
                self.searchBarTextField = (UITextField *)view;
                self.searchBarTextField.enabled = NO;
                break;
            }
        }
    }
    return _searchBar;
}

- (UIButton *)barButton {
    if (!_barButton) {
        _barButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _barButton.translatesAutoresizingMaskIntoConstraints = NO;
        _barButton.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        [_barButton setTitle:@"S" forState:UIControlStateNormal];
        [_barButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_barButton addTarget:self action:@selector(barButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _barButton;
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
                                       [NSLayoutConstraint constraintWithItem:self.resultContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE],
                                       [NSLayoutConstraint constraintWithItem:self.resultContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-BOX_SEPARATOR_SIZE],
                                       [CPAppearanceManager constraintWithItem:self.resultContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeLeft],
                                       [CPAppearanceManager constraintWithItem:self.resultContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight],
                                       nil];
    }
    return _resultContainerConstraints;
}

- (CPMemoCollectionViewManager *)resultMemoCollectionViewManager {
    if (!_resultMemoCollectionViewManager) {
        _resultMemoCollectionViewManager = [[CPMemoCollectionViewManager alloc] initWithSuperview:self.resultContainer style:CPMemoCollectionViewStyleSearch andDelegate:nil];
    }
    return _resultMemoCollectionViewManager;
}

- (id)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        self.superView = superView;
        [self.superView addSubview:self.searchBar];
        [self.superView addSubview:self.barButton];
        
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BAR_HEIGHT]];
        
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.barButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.barButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BAR_HEIGHT]];
        
        [self.superView addConstraint:[CPAppearanceManager constraintWithItem:self.searchBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeLeft]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.barButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeRight multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [self.superView addConstraint:[CPAppearanceManager constraintWithItem:self.barButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight]];
        
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.barButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.barButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

    }
    return self;
}

- (IBAction)barButtonTouched:(id)sender {
    if ([CPProcessManager isInProcess:[CPSearchingProcess process]]) {
        [self.resultMemoCollectionViewManager endEditing];
        [CPProcessManager stopProcess:[CPSearchingProcess process] withPreparation:^{
            [CPAppearanceManager animateWithDuration:0.3 animations:^{
                self.resultMemoCollectionViewManager.collectionView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.superView removeConstraints:self.resultContainerConstraints];
                [self.resultContainer removeFromSuperview];
                
                [self.barButton setTitle:@"S" forState:UIControlStateNormal];
                
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
        // TODO: Stop it if being currently editing memo cells in pass edit view.
        return [CPProcessManager startProcess:[CPSearchingProcess process] withPreparation:^{
            [self.superView addSubview:self.resultContainer];
            [self.superView addConstraints:self.resultContainerConstraints];
            
            [self.barButton setTitle:@"X" forState:UIControlStateNormal];
                        
            self.resultMemoCollectionViewManager.collectionView.alpha = 0.0;
            self.resultMemoCollectionViewManager.memos = [[[CPPassDataManager defaultManager] memosContainText:searchBar.text] mutableCopy];
            
            [CPAppearanceManager animateWithDuration:0.5 animations:^{
                [self.superView layoutIfNeeded];
            } completion:^(BOOL finished) {
                [CPAppearanceManager animateWithDuration:0.3 animations:^{
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
