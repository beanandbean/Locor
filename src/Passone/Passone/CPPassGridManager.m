//
//  CPPassGridManager.m
//  Passone
//
//  Created by wangyw on 6/16/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassGridManager.h"

#import "CPPassDataManager.h"
#import "CPPassEditViewManager.h"
#import "CPPassword.h"

@interface CPPassGridManager ()

@property (strong, nonatomic) NSMutableArray *passCells;

@property (strong, nonatomic) CPPassEditViewManager *passEditViewManager;

@property (strong, nonatomic) UIView *passGridView;

@property (nonatomic) NSInteger editCellIndex;

@end

@implementation CPPassGridManager

- (NSMutableArray *)passCells {
    if (!_passCells) {
        _passCells = [[NSMutableArray alloc] initWithCapacity:ROWS * COLUMNS];
    }
    return _passCells;
}

- (CPPassEditViewManager *)passEditViewManager {
    if (!_passEditViewManager) {
        _passEditViewManager = [[CPPassEditViewManager alloc] init];
    }
    return _passEditViewManager;
}

- (id)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        UIView *outerView = [[UIView alloc] init];
        outerView.translatesAutoresizingMaskIntoConstraints = NO;

        [outerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBy:)]];
        
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [superView addSubview:outerView];
        
        self.passGridView = [[UIView alloc] init];
        self.passGridView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.passGridView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBy:)]];
        
        [outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:outerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:outerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:outerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        NSLayoutConstraint *lowPriorityEqualConstraint = [NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:outerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
        lowPriorityEqualConstraint.priority = 999;
        [outerView addConstraint:lowPriorityEqualConstraint];
        [outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:outerView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        lowPriorityEqualConstraint = [NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:outerView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        lowPriorityEqualConstraint.priority = 999;
        [outerView addConstraint:lowPriorityEqualConstraint];
        // innerView.width == innerView.height
        [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [outerView addSubview:self.passGridView];
        
        [self createPassCells];
        
        self.editCellIndex = -1;
    }
    return self;
}

- (void)refrushPassCellColor {
    NSArray *passwords = [CPPassDataManager defaultManager].passwords;
    for (int index = 0; index < self.passCells.count; index++) {
        UIView *cell = [self.passCells objectAtIndex:index];
        CPPassword *password = [passwords objectAtIndex:index];
        UIColor *color = password.text ? [UIColor colorWithRed:password.red.floatValue green:password.green.floatValue blue:password.blue.floatValue alpha:1.0] : [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        cell.backgroundColor = color;
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.editCellIndex == -1) {
        NSUInteger index = 0;
        for (UIView *cell in self.passCells) {
            if (cell == tapGestureRecognizer.view) {
                break;
            }
            index++;
        }
        self.editCellIndex = index;
        [self.passEditViewManager addPassEditViewInView:self.passGridView index:self.editCellIndex inCells:self.passCells];
    }
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    NSUInteger index = 0;
    for (UIView *cell in self.passCells) {
        if (cell == swipeGestureRecognizer.view) {
            break;
        }
        index++;
    }
    [[CPPassDataManager defaultManager] setPasswordText:nil atIndex:index];
    [self refrushPassCellColor];
}

- (void)tappedBy:(UITapGestureRecognizer *)tapGuestureRecognizer {
    if (self.editCellIndex != -1) {
        [self.passEditViewManager setPasswordForIndex:self.editCellIndex];
        [self.passEditViewManager removePassEditViewFromView:self.passGridView index:self.editCellIndex inCells:self.passCells];
        [self refrushPassCellColor];
        self.editCellIndex = -1;
    }
}

static const int ROWS = 3, COLUMNS = 3;
static const CGFloat SPACE = 10.0;

- (void)createPassCells {
    for (int row = 0; row < ROWS; row++) {
        for (int column = 0; column < COLUMNS; column++) {
            UIView *cell = [[UIView alloc] init];
            cell.translatesAutoresizingMaskIntoConstraints = NO;
            [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
            [cell addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)]];
            
            if (row == 0) {
                // cell.top = superView.top + SPACE
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeTop multiplier:1.0 constant:SPACE]];
            } else {
                UIView *topCell = [self.passCells objectAtIndex:(row - 1) * ROWS + column];
                NSAssert(topCell, @"top cell hasn't been added.");
                // cell.top = topCell.bottom + SPACE
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topCell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:SPACE]];
                // cell.height = topCell.height
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:topCell attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
            }
            
            if (row == ROWS - 1) {
                // cell.bottom = superView.height - SPACE * 2
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-SPACE]];
            }
            
            if (column == 0) {
                // cell.left = leftCell.left + SPACE
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:SPACE]];
            } else {
                UIView *leftCell = [self.passCells objectAtIndex:row * ROWS + column - 1];
                NSAssert(leftCell, @"left cell hasn't been added.");
                // cell.left = leftCell.right + SPACE
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftCell attribute:NSLayoutAttributeRight multiplier:1.0 constant:SPACE]];
                // cell.width = leftCell.width
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:leftCell attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
            }
            
            if (column == COLUMNS - 1) {
                // cell.right = superView.width - SPACE * 2
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-SPACE]];
            }
            
            [self.passCells addObject:cell];
            [self.passGridView addSubview:cell];
        }
    }
    [self refrushPassCellColor];
}

@end
