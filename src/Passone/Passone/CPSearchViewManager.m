//
//  CPSearchViewManager.m
//  Passone
//
//  Created by wangyw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSearchViewManager.h"

#import "CPMarginStandard.h"
#import "CPMemo.h"
#import "CPPassDataManager.h"

@interface CPSearchViewManager ()

@property (weak, nonatomic) UIView *superView;

@property (strong, nonatomic) NSLayoutConstraint *searchBarRightConstraint;

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) NSArray *closeButtonConstraints;

@property (strong, nonatomic) UITableView *resultTableView;
@property (strong, nonatomic) NSArray *resultTableViewConstraints;

@property (strong, nonatomic) NSArray *resultMemos;

- (IBAction)closeButtonTouched:(id)sender;

@end

@implementation CPSearchViewManager

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIGraphicsBeginImageContext(CGSizeMake(15.0, 34.0));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0);
        CGContextFillRect(context, CGRectMake(0.0, 0.0, 15.0, 34.0));
        UIImage *backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        UIGraphicsEndImageContext();
        
        _searchBar.backgroundImage = backgroundImage;
        [_searchBar setSearchFieldBackgroundImage:backgroundImage forState:UIControlStateNormal];
    }
    return _searchBar;
}

- (NSLayoutConstraint *)searchBarRightConstraint {
    if (!_searchBarRightConstraint) {
        _searchBarRightConstraint = [CPMarginStandard constraintWithItem:self.searchBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight];
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
                                   [CPMarginStandard constraintWithItem:self.closeButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight],
                                   [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:predictedSize.width + 20.0],
                                   nil];
    }
    return _closeButtonConstraints;
}

- (UITableView *)resultTableView {
    if (!_resultTableView) {
        _resultTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _resultTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _resultTableView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        _resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _resultTableView.dataSource = self;
        _resultTableView.delegate = self;
    }
    return _resultTableView;
}

- (NSArray *)resultTableViewConstraints {
    if (!_resultTableViewConstraints) {
        _resultTableViewConstraints = [[NSArray alloc] initWithObjects:
                                       [NSLayoutConstraint constraintWithItem:self.resultTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0],
                                       [NSLayoutConstraint constraintWithItem:self.resultTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0],
                                       [CPMarginStandard constraintWithItem:self.resultTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeLeft],
                                       [CPMarginStandard constraintWithItem:self.resultTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight],
                                       nil];
    }
    return _resultTableViewConstraints;
}

- (id)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        self.superView = superView;
        [self.superView addSubview:self.searchBar];
        
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0]];
        [self.superView addConstraint:[CPMarginStandard constraintWithItem:self.searchBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeLeft]];
        [self.superView addConstraint:self.searchBarRightConstraint];
    }
    return self;
}

- (IBAction)closeButtonTouched:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.closeButton.alpha = 0.0;
        self.resultTableView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.superView removeConstraints:self.closeButtonConstraints];
        [self.superView removeConstraints:self.resultTableViewConstraints];
        [self.superView addConstraint:self.searchBarRightConstraint];
        [self.closeButton removeFromSuperview];
        [self.resultTableView removeFromSuperview];
        self.searchBar.text = @"";
        if ([self.searchBar isFirstResponder]) {
            [self.searchBar resignFirstResponder];
        }
        self.resultMemos = nil;
        [UIView animateWithDuration:0.5 animations:^{
            [self.superView layoutIfNeeded];
        }];
    }];
}

#pragma mark - UISearchBarDelegate implement

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.resultMemos = [[CPPassDataManager defaultManager] memosContainText:searchBar.text];
    self.closeButton.alpha = 0.0;
    self.resultTableView.alpha = 0.0;
    [self.superView addSubview:self.closeButton];
    [self.superView addSubview:self.resultTableView];
    [self.superView removeConstraint:self.searchBarRightConstraint];
    [self.superView addConstraints:self.closeButtonConstraints];
    [self.superView addConstraints:self.resultTableViewConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.superView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.closeButton.alpha = 1.0;
            self.resultTableView.alpha = 1.0;
        }];
    }];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *searchText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    self.resultMemos = [[CPPassDataManager defaultManager] memosContainText:searchText];
    [self.resultTableView reloadData];
    return YES;
}

#pragma mark - UITableViewDataSource implement

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultMemos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SearchMemoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    CPMemo *memo = [self.resultMemos objectAtIndex:indexPath.row];
    cell.textLabel.text = memo.text;
    return cell;
}

#pragma mark - UITableViewDelegate implement

@end
