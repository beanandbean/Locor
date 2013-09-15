//
//  CPPassGridManager.m
//  Locor
//
//  Created by wangyw on 6/16/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassGridManager.h"

#import "CPLocorConfig.h"

#import "CPDraggingPassCell.h"
#import "CPCoverImageView.h"

#import "CPPassEditViewManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPAppearanceManager.h"

@interface CPPassGridManager ()

@property (strong, nonatomic) NSMutableArray *passCells;

@property (strong, nonatomic) CPPassEditViewManager *passEditViewManager;

@property (strong, nonatomic) UIView *passGridView;

@property (strong, nonatomic) CPCoverImageView *coverImage;

@property (strong, nonatomic) UIView *iconLayer;

@property (strong, nonatomic) CPDraggingPassCell *dragView;
@property (weak, nonatomic) CPPassCellManager *dragSourceCell;
@property (weak, nonatomic) CPPassCellManager *dragDestinationCell;
@property (strong, nonatomic) CPDraggingPassCell *dragDestinationShadowCell;

@end

@implementation CPPassGridManager

- (void)loadAnimated:(BOOL)animated {
    [CPPassDataManager defaultManager].passwordsController.delegate = self;
    
    self.passGridView = [[UIView alloc] init];
    self.passGridView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:self.passGridView];
    
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passGridView centerAlignToView:self.superview]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.superview attribute:NSLayoutAttributeWidth multiplier:1.0 constant:PASS_GRID_HORIZONTAL_INDENT * 2]];
    NSLayoutConstraint *lowPriorityEqualConstraint = [NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeWidth multiplier:1.0 constant:PASS_GRID_HORIZONTAL_INDENT * 2];
    lowPriorityEqualConstraint.priority = 999;
    [self.superview addConstraint:lowPriorityEqualConstraint];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.superview attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    lowPriorityEqualConstraint = [CPAppearanceManager constraintWithView:self.passGridView alignToView:self.superview attribute:NSLayoutAttributeHeight];
    lowPriorityEqualConstraint.priority = 999;
    [self.superview addConstraint:lowPriorityEqualConstraint];
    [self.passGridView addConstraint:[CPAppearanceManager constraintWithView:self.passGridView attribute:NSLayoutAttributeWidth alignToView:self.passGridView attribute:NSLayoutAttributeHeight]];
    
    [CPAppearanceManager registerStandardForPosition:CPStandardCoverImageCenterX asItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [CPAppearanceManager registerStandardForPosition:CPStandardCoverImageCenterY asItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    
    self.coverImage = [[CPCoverImageView alloc] init];
    [self.superview addSubview:self.coverImage];
    [self.superview addConstraints:self.coverImage.positioningConstraints];
    
    [self.superview addSubview:self.iconLayer];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.iconLayer edgesAlignToView:self.passGridView]];
    [self createPassCells];
    
    [CPAppearanceManager registerStandardForPosition:CPStandardMarginEdgeLeft asItem:((CPPassCellManager *)[self.passCells objectAtIndex:0]).passCellView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:PASS_GRID_HORIZONTAL_INDENT];
    [CPAppearanceManager registerStandardForPosition:CPStandardMarginEdgeRight asItem:((CPPassCellManager *)[self.passCells objectAtIndex:2]).passCellView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-PASS_GRID_HORIZONTAL_INDENT];
}

- (void)createPassCells {
    for (int row = 0; row < PASS_GRID_ROW_COUNT; row++) {
        for (int column = 0; column < PASS_GRID_COLUMN_COUNT; column++) {
            NSUInteger index = row * PASS_GRID_COLUMN_COUNT + column;
            CPPassCellManager *cellManager = [[CPPassCellManager alloc] initWithSupermanager:self superview:self.superview frontLayer:self.iconLayer backLayer:self.passGridView andIndex:index];
            [cellManager loadAnimated:NO];
            [self.passCells addObject:cellManager];
            
            if (row == 0) {
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cellManager.passCellView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
            } else {
                CPPassCellManager *topCell = [self.passCells objectAtIndex:(row - 1) * PASS_GRID_ROW_COUNT + column];
                NSAssert(topCell, @"Top cell hasn't been added before adding bottom cell!");
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cellManager.passCellView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topCell.passCellView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
                [self.passGridView addConstraint:[CPAppearanceManager constraintWithView:cellManager.passCellView alignToView:topCell.passCellView attribute:NSLayoutAttributeHeight]];
            }
            
            if (row == PASS_GRID_ROW_COUNT - 1) {
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cellManager.passCellView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
            }
            
            if (column == 0) {
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cellManager.passCellView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
            } else {
                CPPassCellManager *leftCell = [self.passCells objectAtIndex:row * PASS_GRID_ROW_COUNT + column - 1];
                NSAssert(leftCell, @"Left cell hasn't been added before adding right cell!");
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cellManager.passCellView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftCell.passCellView attribute:NSLayoutAttributeRight multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
                [self.passGridView addConstraint:[CPAppearanceManager constraintWithView:cellManager.passCellView alignToView:leftCell.passCellView attribute:NSLayoutAttributeWidth]];
            }
            
            if (column == PASS_GRID_COLUMN_COUNT - 1) {
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cellManager.passCellView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
            }
        }
    }
}

- (void)removeDragViews {
    self.dragSourceCell.hidden = NO;
    
    [self.dragView removeFromSuperview];
    
    self.dragView = nil;
    self.dragSourceCell = nil;
    self.dragDestinationShadowCell = nil;
}

#pragma mark - CPPassCellDelegate

- (void)tapPassCell:(CPPassCellManager *)passCell {
    if (self.passEditViewManager.index == -1) {
        [self.passEditViewManager showPassEditViewForCellAtIndex:passCell.index];        
    }
}

- (void)startDragPassCell:(CPPassCellManager *)passCell {    
    NSAssert(!self.dragSourceCell, @"Already dragging a pass cell when start dragging one!");
    NSAssert(!self.dragView, @"Already dragging a pass cell when start dragging one!");
    
    self.dragSourceCell = passCell;
    self.dragSourceCell.hidden = YES;

    self.dragView = [[CPDraggingPassCell alloc] initWithCell:self.dragSourceCell onView:self.superview withShadow:YES];
}

- (void)dragPassCell:(CPPassCellManager *)passCell location:(CGPoint)location translation:(CGPoint)translation {
    NSAssert(self.dragView, @"Haven't started dragging pass cell when coming to the middle of dragging!");

    if (passCell == self.dragSourceCell) {
        self.dragView.leftConstraint.constant += translation.x;
        self.dragView.topConstraint.constant += translation.y;
        [self.superview layoutIfNeeded];
        
        CGPoint centerInPassGridView = [self.passGridView convertPoint:self.dragView.center fromView:self.superview];
        
        CPPassCellManager *newDragDestinationCell = nil;
        if (CGRectContainsPoint(self.passGridView.bounds, self.dragView.center)) {
            newDragDestinationCell = [self.passCells objectAtIndex:0];
            float distance = hypotf(newDragDestinationCell.passCellView.center.x - centerInPassGridView.x, newDragDestinationCell.passCellView.center.y - centerInPassGridView.y);
            for (CPPassCellManager *cell in self.passCells) {
                float newDistance = hypotf(cell.passCellView.center.x - centerInPassGridView.x, cell.passCellView.center.y - centerInPassGridView.y);
                if (newDistance < distance) {
                    newDragDestinationCell = cell;
                    distance = newDistance;
                }
            }
            if (newDragDestinationCell == self.dragSourceCell) {
                newDragDestinationCell = nil;
            }
        }
        
        if (newDragDestinationCell != self.dragDestinationCell) {
            if (self.dragDestinationShadowCell) {
                [self.dragDestinationShadowCell removeFromSuperview];
            }
            
            self.dragDestinationCell = newDragDestinationCell;
            
            if (self.dragDestinationCell) {
                self.dragDestinationShadowCell = [[CPDraggingPassCell alloc] initWithCell:self.dragDestinationCell onView:self.superview withShadow:YES];
                [self.superview bringSubviewToFront:self.dragView];
            }
        }
    }
}

- (BOOL)canStopDragPassCell:(CPPassCellManager *)passCell {
    return passCell == self.dragSourceCell;
}

- (void)stopDragPassCell:(CPPassCellManager *)passCell {
    NSAssert(passCell == self.dragSourceCell, @"Try to stop dragging a cell while dragging another!");
    NSAssert(self.dragView, @"Haven't started dragging pass cell when to stop it!");
    
    if (self.dragDestinationCell) {
        [self.superview bringSubviewToFront:self.dragView];
        self.dragDestinationCell.hidden = YES;
        
        [self.superview removeConstraint:self.dragView.leftConstraint];
        [self.superview removeConstraint:self.dragView.topConstraint];
        
        [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.dragView alignToView:self.dragDestinationCell.passCellView attribute:NSLayoutAttributeLeft]];
        [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.dragView alignToView:self.dragDestinationCell.passCellView attribute:NSLayoutAttributeTop]];
        
        [self.superview removeConstraint:self.dragDestinationShadowCell.leftConstraint];
        [self.superview removeConstraint:self.dragDestinationShadowCell.topConstraint];
        
        [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.dragDestinationShadowCell alignToView:self.dragSourceCell.passCellView attribute:NSLayoutAttributeLeft]];
        [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.dragDestinationShadowCell alignToView:self.dragSourceCell.passCellView attribute:NSLayoutAttributeTop]];
        
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            [[CPPassDataManager defaultManager] exchangePasswordBetweenIndex1:self.dragSourceCell.index andIndex2:self.dragDestinationCell.index];
            
            self.dragDestinationCell.hidden = NO;
            [self.dragDestinationShadowCell removeFromSuperview];
            
            [self removeDragViews];
        }];
    } else {
        self.dragView.leftConstraint.constant = 0.0;
        self.dragView.topConstraint.constant = 0.0;
        
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self removeDragViews];
        }];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate implement

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    CPPassword *password = nil;
    CPPassCellManager *cell;
    switch (type) {
        
        // TODO: Extract method 'refreshAppearance' into CPPassCellManager.
        
        case NSFetchedResultsChangeUpdate:
            password = [controller.fetchedObjects objectAtIndex:indexPath.row];
            cell = [self.passCells objectAtIndex:indexPath.row];
            cell.passCellView.backgroundColor = password.displayColor;
            cell.icon = password.displayIcon;
            break;
        case NSFetchedResultsChangeMove:
            password = [controller.fetchedObjects objectAtIndex:indexPath.row];
            cell = [self.passCells objectAtIndex:indexPath.row];
            cell.passCellView.backgroundColor = password.displayColor;
            cell.icon = password.displayIcon;
            password = [controller.fetchedObjects objectAtIndex:newIndexPath.row];
            cell = [self.passCells objectAtIndex:newIndexPath.row];
            cell.passCellView.backgroundColor = password.displayColor;
            cell.icon = password.displayIcon;
            break;
        default:
            NSAssert(NO, @"Unknowed change reported by NSFetchResultsController!");
            break;
    }
}

#pragma mark - lazy init

- (NSMutableArray *)passCells {
    if (!_passCells) {
        _passCells = [[NSMutableArray alloc] initWithCapacity:PASS_GRID_ROW_COUNT * PASS_GRID_COLUMN_COUNT];
    }
    return _passCells;
}

- (CPPassEditViewManager *)passEditViewManager {
    if (!_passEditViewManager) {
        _passEditViewManager = [[CPPassEditViewManager alloc] initWithSuperview:self.superview andCells:self.passCells];
    }
    return _passEditViewManager;
}

- (UIView *)iconLayer {
    if (!_iconLayer) {
        _iconLayer = [[UIView alloc] init];
        _iconLayer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _iconLayer;
}

@end
