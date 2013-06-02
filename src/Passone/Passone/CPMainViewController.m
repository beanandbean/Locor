//
//  CPMainViewController.m
//  Passone
//
//  Created by wangyw on 6/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewController.h"

#import "CPPasswordCell.h"

@interface CPMainViewController ()

@property (strong, nonatomic) NSMutableArray *passwordCells;

@end

@implementation CPMainViewController

static const int ROWS = 3, COLUMNS = 3;
static const CGFloat SPACE = 10.0;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createPasswordGrid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)passwordCells {
    if (!_passwordCells) {
        _passwordCells = [[NSMutableArray alloc] initWithCapacity:ROWS * COLUMNS];
    }
    return _passwordCells;
}

- (void)createPasswordGrid {
    UIView *outerView = [[UIView alloc] init];
    outerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:outerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self.view addSubview:outerView];

    UIView *innerView = [[UIView alloc] init];
    innerView.translatesAutoresizingMaskIntoConstraints = NO;
    [outerView addConstraint:[NSLayoutConstraint constraintWithItem:innerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:outerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [outerView addConstraint:[NSLayoutConstraint constraintWithItem:innerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:outerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [outerView addConstraint:[NSLayoutConstraint constraintWithItem:innerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:outerView attribute:NSLayoutAttributeWidth multiplier:0.9 constant:0.0]];
    [outerView addConstraint:[NSLayoutConstraint constraintWithItem:innerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:outerView attribute:NSLayoutAttributeHeight multiplier:0.9 constant:0.0]];
    // innerView.width == innerView.height
    [innerView addConstraint:[NSLayoutConstraint constraintWithItem:innerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:innerView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [outerView addSubview:innerView];
    
    [self createPasswordCells:innerView];
}

- (void)createPasswordCells:(UIView *)superView {
    for (int row = 0; row < ROWS; row++) {
        for (int column = 0; column < COLUMNS; column++) {
            CPPasswordCell *cell = [[CPPasswordCell alloc] init];
            
            if (row == 0) {
                // cell.top = superView.top + SPACE
                [superView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:SPACE]];
            } else {
                CPPasswordCell *topCell = [self.passwordCells objectAtIndex:(row - 1) * ROWS + column];
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
                CPPasswordCell *leftCell = [self.passwordCells objectAtIndex:row * ROWS + column - 1];
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
            
            [self.passwordCells addObject:cell];
            [superView addSubview:cell];
        }
    }
}

@end
