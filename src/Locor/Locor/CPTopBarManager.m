//
//  CPTopBarAndSearchManager.m
//  Locor
//
//  Created by wangyw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPTopBarManager.h"

#import "CPLocorConfig.h"

#import "CPCoverImageView.h"

#import "CPMemoCollectionViewManager.h"

#import "CPAppearanceManager.h"

#import "CPBarButtonManager.h"

#import "CPPassDataManager.h"

#import "CPProcessManager.h"
#import "CPSearchingProcess.h"

@interface CPTopBarManager ()

@property (strong, nonatomic) UIButton *barButton;

@property (weak, nonatomic) UITextField *searchBarTextField;

@property (strong, nonatomic) UIView *resultContainer;
@property (strong, nonatomic) NSArray *resultContainerConstraints;

@property (strong, nonatomic) CPCoverImageView *coverImage;

@property (strong, nonatomic) UIView *frontResultContainer;
@property (strong, nonatomic) UIView *backResultContainer;
@property (strong, nonatomic) NSArray *frontResultContainerConstraints;
@property (strong, nonatomic) NSArray *backResultContainerConstraints;

@property (strong, nonatomic) CPMemoCollectionViewManager *resultMemoCollectionViewManager;

@property (strong, nonatomic) UIView *settingsContainer;
@property (strong, nonatomic) NSArray *settingsContainerConstraints;

@property (strong, nonatomic) CPSettingsManager *settingsManager;

- (void)handleTapOnSearchBar:(UITapGestureRecognizer *)tapGesture;

@end

@implementation CPTopBarManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.searchBar];
    [self.superview addSubview:self.barButton];
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BAR_HEIGHT]];
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.barButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.barButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BAR_HEIGHT]];
    
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.searchBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardMarginEdgeLeft]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.barButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeRight multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.barButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardMarginEdgeRight]];
    
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.barButton attribute:NSLayoutAttributeWidth alignToView:self.barButton attribute:NSLayoutAttributeHeight]];
}

- (void)openSetting {
    [self.superview addSubview:self.settingsContainer];
    [self.superview addConstraints:self.settingsContainerConstraints];
    [self.superview bringSubviewToFront:self.searchBar];
    [self.superview bringSubviewToFront:self.barButton];
    [self.settingsManager loadViews];
}

- (void)stopSearching {
    NSAssert([CPProcessManager isInProcess:SEARCHING_PROCESS], @"Receive an unexpected stop searching request!");
    [self.resultMemoCollectionViewManager endEditing];
    [CPProcessManager stopProcess:SEARCHING_PROCESS withPreparation:^{
        [CPAppearanceManager animateWithDuration:0.3 animations:^{
            self.backResultContainer.alpha = 0.0;
            self.coverImage.alpha = 0.0;
            self.frontResultContainer.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.superview removeConstraints:self.resultContainerConstraints];
            [self.resultContainer removeFromSuperview];
            
            [CPBarButtonManager popBarButtonState];
            
            self.backResultContainer = nil;
            self.coverImage = nil;
            self.frontResultContainer = nil;
            self.backResultContainerConstraints = nil;
            self.frontResultContainerConstraints = nil;
            self.resultMemoCollectionViewManager = nil;
            
            self.resultContainer = nil;
            self.resultContainerConstraints = nil;
            
            self.searchBar.text = @"";
            if ([self.searchBar isFirstResponder]) {
                [self.searchBar resignFirstResponder];
            }
            
            [CPAppearanceManager animateWithDuration:0.5 animations:^{
                [self.superview layoutIfNeeded];
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

#pragma mark - CPSettingsManagerDelegate implement

- (void)settingsManagerClosed {
    [self.superview removeConstraints:self.settingsContainerConstraints];
    [self.settingsContainer removeFromSuperview];
}

#pragma mark - UISearchBarDelegate implement

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([CPProcessManager isInProcess:SEARCHING_PROCESS]) {
        self.resultMemoCollectionViewManager.memos = [[[CPPassDataManager defaultManager] memosContainText:searchBar.text] mutableCopy];
        return YES;
    } else {
        // TODO: When search bar is focused, stop if being currently editing memo cells in pass edit view.
        return [CPProcessManager startProcess:SEARCHING_PROCESS withPreparation:^{
            [self.superview addSubview:self.resultContainer];
            [self.superview addConstraints:self.resultContainerConstraints];
            
            [self.resultContainer addSubview:self.backResultContainer];
            [self.resultContainer addSubview:self.coverImage];
            [self.resultContainer addSubview:self.frontResultContainer];
            [self.resultContainer addConstraints:self.backResultContainerConstraints];
            [self.resultContainer addConstraints:self.frontResultContainerConstraints];
            
            [self.superview addConstraints:self.coverImage.positioningConstraints];
            
            [CPBarButtonManager pushBarButtonStateWithTitle:@"X" target:self action:@selector(stopSearching) andControlEvents:UIControlEventTouchUpInside];
            
            self.coverImage.alpha = 0.0;
            
            self.resultMemoCollectionViewManager.memos = [[[CPPassDataManager defaultManager] memosContainText:searchBar.text] mutableCopy];
            
            [self.superview layoutIfNeeded];
            
            [self.resultMemoCollectionViewManager showMemoCollectionViewAnimated];
            
            [CPAppearanceManager animateWithDuration:0.3 animations:^{
                self.coverImage.alpha = WATER_MARK_ALPHA;
                self.backResultContainer.backgroundColor = [UIColor blackColor];
            } completion:nil];
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

#pragma mark - lazy init

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
        [_barButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [CPBarButtonManager initializeWithBarButton:_barButton];
        [CPBarButtonManager pushBarButtonStateWithTitle:@"S" target:self action:@selector(openSetting) andControlEvents:UIControlEventTouchUpInside];
    }
    return _barButton;
}

- (UIView *)resultContainer {
    if (!_resultContainer) {
        _resultContainer = [[UIView alloc] init];
        _resultContainer.clipsToBounds = YES;
        _resultContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _resultContainer;
}

- (NSArray *)resultContainerConstraints {
    if (!_resultContainerConstraints) {
        _resultContainerConstraints = [[NSArray alloc] initWithObjects:
                                            [NSLayoutConstraint constraintWithItem:self.resultContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE],
                                            [NSLayoutConstraint constraintWithItem:self.resultContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-BOX_SEPARATOR_SIZE],
                                            nil];
        _resultContainerConstraints = [_resultContainerConstraints arrayByAddingObjectsFromArray:[CPAppearanceManager constraintsWithView:self.resultContainer alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    }
    return _resultContainerConstraints;
}

- (UIView *)frontResultContainer {
    if (!_frontResultContainer) {
        _frontResultContainer = [[UIView alloc] init];
        _frontResultContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _frontResultContainer;
}

- (UIView *)backResultContainer {
    if (!_backResultContainer) {
        _backResultContainer = [[UIView alloc] init];
        _backResultContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _backResultContainer;
}

- (NSArray *)frontResultContainerConstraints {
    if (!_frontResultContainerConstraints) {
        _frontResultContainerConstraints = [CPAppearanceManager constraintsWithView:self.frontResultContainer edgesAlignToView:self.resultContainer];
    }
    return _frontResultContainerConstraints;
}

- (NSArray *)backResultContainerConstraints {
    if (!_backResultContainerConstraints) {
        _backResultContainerConstraints = [CPAppearanceManager constraintsWithView:self.backResultContainer edgesAlignToView:self.resultContainer];
    }
    return _backResultContainerConstraints;
}

- (CPCoverImageView *)coverImage {
    if (!_coverImage) {
        _coverImage = [[CPCoverImageView alloc] init];
    }
    return _coverImage;
}

- (CPMemoCollectionViewManager *)resultMemoCollectionViewManager {
    if (!_resultMemoCollectionViewManager) {
        _resultMemoCollectionViewManager = [[CPMemoCollectionViewManager alloc] initWithSuperview:self.superview frontLayer:self.frontResultContainer backLayer:self.backResultContainer style:CPMemoCollectionViewStyleSearch andDelegate:nil];
    }
    return _resultMemoCollectionViewManager;
}

- (UIView *)settingsContainer {
    if (!_settingsContainer) {
        _settingsContainer = [[UIView alloc] init];
        _settingsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _settingsContainer;
}

- (NSArray *)settingsContainerConstraints {
    if (!_settingsContainerConstraints) {
        _settingsContainerConstraints = [[NSArray alloc] initWithObjects:
                                         [NSLayoutConstraint constraintWithItem:self.settingsContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE],
                                         [NSLayoutConstraint constraintWithItem:self.settingsContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BOX_SEPARATOR_SIZE],
                                         [NSLayoutConstraint constraintWithItem:self.settingsContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:-BOX_SEPARATOR_SIZE],
                                         [NSLayoutConstraint constraintWithItem:self.settingsContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-BOX_SEPARATOR_SIZE],
                                         nil];
    }
    return _settingsContainerConstraints;
}

- (CPSettingsManager *)settingsManager {
    if (!_settingsManager) {
        NSAssert(self.superview, @"");
        _settingsManager = [[CPSettingsManager alloc] initWithSuperview:self.settingsContainer andDelegate:self];
    }
    return _settingsManager;
}

@end
