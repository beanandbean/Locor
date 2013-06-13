//
//  CPMainViewController.m
//  Passone
//
//  Created by wangyw on 6/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewController.h"

#import "CPPassEditViewManager.h"

@interface CPMainViewController ()

@property (strong, nonatomic) NSMutableArray *passCells;

@property (strong, nonatomic) CPPassEditViewManager *passEditViewManager;

@property (strong, nonatomic) UIView *passGridView;

@end

@implementation CPMainViewController

static const int ROWS = 3, COLUMNS = 3;
static const CGFloat SPACE = 10.0;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createPassGridView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - property methods

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

#pragma mark - CPPassCellDelegate implement

- (void)editPassCell:(CPPassCell *)cell {
    [self.passEditViewManager addPassEditViewInView:self.passGridView forCell:cell inCells:self.passCells];
}

#pragma mark -

- (void)createPassGridView {
    UIView *outerView = [[UIView alloc] init];
    outerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self.view addSubview:outerView];

    self.passGridView = [[UIView alloc] init];
    self.passGridView.translatesAutoresizingMaskIntoConstraints = NO;
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
    
    [self createPassCells:self.passGridView];
}

- (void)createPassCells:(UIView *)superView {
    for (int row = 0; row < ROWS; row++) {
        for (int column = 0; column < COLUMNS; column++) {
            CPPassCell *cell = [[CPPassCell alloc] initWithDelegate:self];
            
            if (row == 0) {
                // cell.top = superView.top + SPACE
                [superView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:SPACE]];
            } else {
                CPPassCell *topCell = [self.passCells objectAtIndex:(row - 1) * ROWS + column];
                NSAssert(topCell, @"top cell hasn't been added.");
                // cell.top = topCell.bottom + SPACE
                [superView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topCell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:SPACE]];
                // cell.height = topCell.height
                [superView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:topCell attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
            }
            
            if (row == ROWS - 1) {
                // cell.bottom = superView.height - SPACE * 2
                [superView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-SPACE]];
            }
            
            if (column == 0) {
                // cell.left = leftCell.left + SPACE
                [superView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:SPACE]];
            } else {
                CPPassCell *leftCell = [self.passCells objectAtIndex:row * ROWS + column - 1];
                NSAssert(leftCell, @"left cell hasn't been added.");
                // cell.left = leftCell.right + SPACE
                [superView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftCell attribute:NSLayoutAttributeRight multiplier:1.0 constant:SPACE]];
                // cell.width = leftCell.width
                [superView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:leftCell attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
            }

            if (column == COLUMNS - 1) {
                // cell.right = superView.width - SPACE * 2
                [superView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-SPACE]];
            }
            
            [self.passCells addObject:cell];
            [superView addSubview:cell];
        }
    }
}

@end
