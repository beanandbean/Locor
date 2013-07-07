//
//  CPSearchViewManager.m
//  Passone
//
//  Created by wangyw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSearchViewManager.h"

#import "CPMarginStandard.h"

@interface CPSearchViewManager ()

@property (weak, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) UIView *superView;

@property (strong, nonatomic) UITableView *resultTableView;
@property (strong, nonatomic) NSArray *resultTableViewConstraints;

@end

@implementation CPSearchViewManager

- (UITableView *)resultTableView {
    if (!_resultTableView) {
        _resultTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _resultTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _resultTableView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        _resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _resultTableView;
}

- (NSArray *)resultTableViewConstraints {
    if (!_resultTableViewConstraints) {
        _resultTableViewConstraints = [[NSArray alloc] initWithObjects:
                                       [NSLayoutConstraint constraintWithItem:self.resultTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.0],
                                       [NSLayoutConstraint constraintWithItem:self.resultTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0],
                                       [CPMarginStandard constraintWithItem:self.resultTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeLeft],
                                       [CPMarginStandard constraintWithItem:self.resultTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toEdge:CPMarginEdgeRight],
                                       nil];
    }
    return _resultTableViewConstraints;
}

- (id)initWithSearchBar:(UISearchBar *)searchBar superView:(UIView *)superView {
    self = [super init];
    if (self) {
        self.searchBar = searchBar;
        self.superView = superView;
        self.searchBar.delegate = self;
    }
    return self;
}

#pragma mark - UISearchBar implement

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.superView addSubview:self.resultTableView];
    [self.superView addConstraints:self.resultTableViewConstraints];
}

@end
