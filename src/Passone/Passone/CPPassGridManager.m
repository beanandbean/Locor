//
//  CPPassGridManager.m
//  Passone
//
//  Created by wangyw on 6/16/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassGridManager.h"

#import "CPPassCell.h"
#import "CPPassDataManager.h"
#import "CPPassEditViewManager.h"
#import "CPPassword.h"

#import "CPNotificationCenter.h"

@interface CPPassGridManager ()

@property (strong, nonatomic) NSMutableArray *passCells;

@property (strong, nonatomic) CPPassEditViewManager *passEditViewManager;

@property (strong, nonatomic) UIView *passGridView;

@property (strong, nonatomic) UIView *dragView;
@property (weak, nonatomic) CPPassCell *dragSourceCell;
@property (weak, nonatomic) CPPassCell *dragDestinationCell;
@property (strong, nonatomic) NSLayoutConstraint *dragViewLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *dragViewTopConstraint;

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
        _passEditViewManager = [[CPPassEditViewManager alloc] initWithSuperView:self.passGridView cells:self.passCells];
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
    }
    return self;
}

- (void)refreshPassCellColor {
    NSArray *passwords = [CPPassDataManager defaultManager].passwords;
    for (int index = 0; index < self.passCells.count; index++) {
        UIView *cell = [self.passCells objectAtIndex:index];
        CPPassword *password = [passwords objectAtIndex:index];
        UIColor *color = password.isUsed.boolValue ? [[UIColor alloc] initWithRed:password.colorRed.floatValue green:password.colorGreen.floatValue blue:password.colorBlue.floatValue alpha:1.0] : [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        cell.backgroundColor = color;
        cell.alpha = 1.0;
    }
}

- (void)tappedBy:(UITapGestureRecognizer *)tapGuestureRecognizer {
    if (self.passEditViewManager.index != -1) {
        [self.passEditViewManager setPassword];
        [self.passEditViewManager hidePassEditView];
        [self refreshPassCellColor];
    }
}

static const int ROWS = 3, COLUMNS = 3;
static const CGFloat SPACE = 10.0;

- (void)createPassCells {
    for (int row = 0; row < ROWS; row++) {
        for (int column = 0; column < COLUMNS; column++) {
            CPPassCell *cell = [[CPPassCell alloc] initWithDelegate:self];
            
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
    [self refreshPassCellColor];
}

- (NSUInteger)indexOfPassCell:(CPPassCell *)passCell {
    NSUInteger index = 0;
    for (CPPassCell *cell in self.passCells) {
        if (cell == passCell) {
            break;
        }
        index++;
    }
    return index;
}

#pragma mark - CPPassCellDelegate

- (void)tapPassCell:(CPPassCell *)passCell {
    if (self.passEditViewManager.index == -1) {
        [self.passEditViewManager showPassEditViewForCellAtIndex:[self indexOfPassCell:passCell]];
        
        //This is just a test!!
        [CPNotificationCenter insertNotification:@"A test of notification!!"];
    }
}

- (void)swipePassCell:(CPPassCell *)passCell {
    [[CPPassDataManager defaultManager] toggleRemoveStateOfPasswordAtIndex:[self indexOfPassCell:passCell]];
    [self refreshPassCellColor];
}

- (void)startDragPassCell:(CPPassCell *)passCell {
    NSAssert(!self.dragSourceCell, @"");
    NSAssert(!self.dragView, @"");
    NSAssert(!self.dragViewLeftConstraint, @"");
    NSAssert(!self.dragViewTopConstraint, @"");
    
    self.dragSourceCell = passCell;
    self.dragSourceCell.alpha = 0.5;
    
    self.dragView = [[UIView alloc] init];
    self.dragView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dragView.backgroundColor = self.dragSourceCell.backgroundColor;    
    [self.passGridView addSubview:self.dragView];
    
    self.dragViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    [self.passGridView addConstraint:self.dragViewLeftConstraint];
    self.dragViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.passGridView addConstraint:self.dragViewTopConstraint];
    
    [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
}

- (void)dragPassCell:(CPPassCell *)passCell location:(CGPoint)location translation:(CGPoint)translation {
    NSAssert(passCell == self.dragSourceCell, @"");
    NSAssert(self.dragView, @"");
    NSAssert(self.dragViewLeftConstraint, @"");
    NSAssert(self.dragViewTopConstraint, @"");
    
    self.dragViewLeftConstraint.constant += translation.x;
    self.dragViewTopConstraint.constant += translation.y;
    [self.passGridView layoutIfNeeded];

    if (self.dragDestinationCell) {
        UIColor *sourceColor = self.dragSourceCell.backgroundColor;
        self.dragSourceCell.backgroundColor = self.dragDestinationCell.backgroundColor;
        self.dragDestinationCell.backgroundColor = sourceColor;
        self.dragDestinationCell.alpha = 1.0;
        self.dragDestinationCell = nil;
    }

    for (CPPassCell *cell in self.passCells) {
        if (cell != self.dragSourceCell && CGRectContainsPoint(cell.frame, self.dragView.center)) {
            self.dragDestinationCell = cell;
            break;
        }
    }
    
    if (self.dragDestinationCell) {
        UIColor *sourceColor = self.dragSourceCell.backgroundColor;
        self.dragSourceCell.backgroundColor = self.dragDestinationCell.backgroundColor;
        self.dragDestinationCell.backgroundColor = sourceColor;
        self.dragDestinationCell.alpha = 0.5;
    }
}

- (void)stopDragPassCell:(CPPassCell *)passCell {
    NSAssert(passCell == self.dragSourceCell, @"");
    NSAssert(self.dragView, @"");
    NSAssert(self.dragViewLeftConstraint, @"");
    NSAssert(self.dragViewTopConstraint, @"");

    if (self.dragDestinationCell) {
        NSUInteger dragSourceIndex = [self indexOfPassCell:self.dragSourceCell];
        NSUInteger dragDestinationIndex = [self indexOfPassCell:self.dragDestinationCell];
        [[CPPassDataManager defaultManager] exchangePasswordAtIndex1:dragSourceIndex index2:dragDestinationIndex];
        [self refreshPassCellColor];
    }
    
    self.dragSourceCell.alpha = 1.0;
    self.dragDestinationCell.alpha = 1.0;
    [self.dragView removeFromSuperview];
    
    self.dragView = nil;
    self.dragSourceCell = nil;
    self.dragViewLeftConstraint = nil;
    self.dragViewTopConstraint = nil;
}

@end
