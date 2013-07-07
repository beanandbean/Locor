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

@property (strong, nonatomic) UITableView *resultTableView;
@property (strong, nonatomic) NSArray *resultTableViewConstraints;

@property (strong, nonatomic) NSArray *resultMemos;

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
        [self.superView addConstraint:[CPMarginStandard constraintWithItem:self.searchBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight]];
    }
    return self;
}

#pragma mark - UISearchBar implement

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.resultMemos = [[CPPassDataManager defaultManager] memosContainText:searchBar.text];
    [self.superView addSubview:self.resultTableView];
    [self.superView addConstraints:self.resultTableViewConstraints];
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
