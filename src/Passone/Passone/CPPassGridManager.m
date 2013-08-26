//
//  CPPassGridManager.m
//  Passone
//
//  Created by wangyw on 6/16/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassGridManager.h"

#import "CPPassoneConfig.h"

#import "CPPassCell.h"
#import "CPPassDataManager.h"
#import "CPPassEditViewManager.h"
#import "CPPassword.h"

#import "CPAppearanceManager.h"
#import "CPNotificationCenter.h"

@interface CPPassGridManager ()

@property (weak, nonatomic) UIView *superview;

@property (strong, nonatomic) NSMutableArray *passCells;

@property (strong, nonatomic) CPPassEditViewManager *passEditViewManager;

@property (strong, nonatomic) UIView *passGridView;

@property (strong, nonatomic) UIImageView *coverImage;

@property (strong, nonatomic) UIView *dragView;
@property (weak, nonatomic) CPPassCell *dragSourceCell;
@property (weak, nonatomic) CPPassCell *dragDestinationCell;
@property (strong, nonatomic) UIColor *dragSourceBackgroundColor;
@property (strong, nonatomic) NSLayoutConstraint *dragViewLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *dragViewTopConstraint;

@end

@implementation CPPassGridManager

- (NSMutableArray *)passCells {
    if (!_passCells) {
        _passCells = [[NSMutableArray alloc] initWithCapacity:PASS_GRID_ROW_COUNT * PASS_GRID_COLUMN_COUNT];
    }
    return _passCells;
}

- (CPPassEditViewManager *)passEditViewManager {
    if (!_passEditViewManager) {
        _passEditViewManager = [[CPPassEditViewManager alloc] initWithSuperView:self.superview cells:self.passCells];
    }
    return _passEditViewManager;
}

- (id)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        [CPPassDataManager defaultManager].passwordsController.delegate = self;
        
        self.superview = superView;
        
        self.passGridView = [[UIView alloc] init];
        self.passGridView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [superView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBy:)]];
        [self.passGridView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBy:)]];
        
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:superView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:PASS_GRID_HORIZONTAL_INDENT * 2]];
        NSLayoutConstraint *lowPriorityEqualConstraint = [NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:PASS_GRID_HORIZONTAL_INDENT * 2];
        lowPriorityEqualConstraint.priority = 999;
        [superView addConstraint:lowPriorityEqualConstraint];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:superView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        lowPriorityEqualConstraint = [NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        lowPriorityEqualConstraint.priority = 999;
        [superView addConstraint:lowPriorityEqualConstraint];
        // innerView.width == innerView.height
        [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:self.passGridView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [superView addSubview:self.passGridView];
        
        NSString *coverName;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            coverName = @"bg-iphone";
        } else {
            coverName = @"bg-ipad";
        }
        
        self.coverImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:coverName]];
        self.coverImage.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.coverImage.translatesAutoresizingMaskIntoConstraints = NO;
        self.coverImage.alpha = WATER_MARK_ALPHA;
        [self.superview addSubview:self.coverImage];
        
        [self.superview.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.coverImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.superview.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.coverImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [self createPassCells];
        
        [CPAppearanceManager registerStandardForEdge:CPMarginEdgeLeft asItem:[self.passCells objectAtIndex:0] attribute:NSLayoutAttributeLeft multiplier:1.0 constant:PASS_GRID_HORIZONTAL_INDENT];
        [CPAppearanceManager registerStandardForEdge:CPMarginEdgeRight asItem:[self.passCells objectAtIndex:2] attribute:NSLayoutAttributeRight multiplier:1.0 constant:-PASS_GRID_HORIZONTAL_INDENT];
    }
    return self;
}

- (void)tappedBy:(UITapGestureRecognizer *)tapGuestureRecognizer {
    if (self.passEditViewManager.index != -1) {
        [self.passEditViewManager setPassword];
        [self.passEditViewManager hidePassEditView];
    }
}

- (void)createPassCells {
    for (int row = 0; row < PASS_GRID_ROW_COUNT; row++) {
        for (int column = 0; column < PASS_GRID_COLUMN_COUNT; column++) {
            NSUInteger index = row * PASS_GRID_COLUMN_COUNT + column;
            CPPassCell *cell = [[CPPassCell alloc] initWithIndex:index delegate:self];
            
            if (row == 0) {
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
            } else {
                UIView *topCell = [self.passCells objectAtIndex:(row - 1) * PASS_GRID_ROW_COUNT + column];
                NSAssert(topCell, @"Top cell hasn't been added before adding bottom cell!");
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topCell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:topCell attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
            }
            
            if (row == PASS_GRID_ROW_COUNT - 1) {
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
            }
            
            if (column == 0) {
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
            } else {
                UIView *leftCell = [self.passCells objectAtIndex:row * PASS_GRID_ROW_COUNT + column - 1];
                NSAssert(leftCell, @"Left cell hasn't been added before adding right cell!");
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftCell attribute:NSLayoutAttributeRight multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:leftCell attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
            }
            
            if (column == PASS_GRID_COLUMN_COUNT - 1) {
                [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.passGridView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
            }
            
            [self.passCells addObject:cell];
            [self.passGridView addSubview:cell];
        }
    }
}

#pragma mark - CPPassCellDelegate

- (void)tapPassCell:(CPPassCell *)passCell {
    if (self.passEditViewManager.index == -1) {
        [self.passEditViewManager showPassEditViewForCellAtIndex:passCell.index];        
    }
}

- (void)startDragPassCell:(CPPassCell *)passCell {    
    NSAssert(!self.dragSourceCell, @"Already dragging a pass cell when start dragging one!");
    NSAssert(!self.dragView, @"Already dragging a pass cell when start dragging one!");
    NSAssert(!self.dragViewLeftConstraint, @"Already dragging a pass cell when start dragging one!");
    NSAssert(!self.dragViewTopConstraint, @"Already dragging a pass cell when start dragging one!");
    
    self.dragSourceCell = passCell;
    self.dragSourceBackgroundColor = self.dragSourceCell.backgroundColor;
    self.dragSourceCell.alpha = 0.0;
    //self.dragSourceCell.hidden = YES;
    
    self.dragView = [[UIView alloc] init];
    
    self.dragView.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.dragView.layer.shadowOffset = CGSizeZero;
    self.dragView.layer.shadowOpacity = 1.0;
    self.dragView.layer.shadowRadius = 5.0;
    self.dragView.layer.masksToBounds = NO;
    
    self.dragView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dragView.backgroundColor = self.dragSourceCell.backgroundColor;
    [self.passGridView addSubview:self.dragView];
    
    self.dragViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    [self.passGridView addConstraint:self.dragViewLeftConstraint];
    self.dragViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.passGridView addConstraint:self.dragViewTopConstraint];
    
    [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.passGridView addConstraint:[NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    
    [self.passGridView layoutIfNeeded];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectInset(self.dragView.bounds, -5.0, -5.0)];
    self.dragView.layer.shadowPath = bezierPath.CGPath;
}

- (void)dragPassCell:(CPPassCell *)passCell location:(CGPoint)location translation:(CGPoint)translation {
    NSAssert(self.dragView, @"Haven't started dragging pass cell when coming to the middle of dragging!");
    NSAssert(self.dragViewLeftConstraint, @"Haven't started dragging pass cell when coming to the middle of dragging!");
    NSAssert(self.dragViewTopConstraint, @"Haven't started dragging pass cell when coming to the middle of dragging!");

    if (passCell == self.dragSourceCell) {
        self.dragViewLeftConstraint.constant += translation.x;
        self.dragViewTopConstraint.constant += translation.y;
        [self.passGridView layoutIfNeeded];
        
        CPPassCell *newDragDestinationCell = nil;
        if (CGRectContainsPoint(self.passGridView.bounds, self.dragView.center)) {
            newDragDestinationCell = [self.passCells objectAtIndex:0];
            float distance = hypotf(newDragDestinationCell.center.x - self.dragView.center.x, newDragDestinationCell.center.y - self.dragView.center.y);
            for (CPPassCell *cell in self.passCells) {
                float newDistance = hypotf(cell.center.x - self.dragView.center.x, cell.center.y - self.dragView.center.y);
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
            if (self.dragDestinationCell) {
                self.dragDestinationCell.alpha = 1.0;
            }
            
            self.dragDestinationCell = newDragDestinationCell;
            if (self.dragDestinationCell) {
                self.dragSourceCell.backgroundColor = self.dragDestinationCell.backgroundColor;
            } else {
                self.dragSourceCell.backgroundColor = self.dragSourceBackgroundColor;
                self.dragSourceCell.alpha = 0.0;
            }
        }
        
        if (self.dragDestinationCell) {
            float range = 0.7;
            float baseDistance = self.dragView.bounds.size.width;
            float xDistance = fabsf(self.dragDestinationCell.center.x - self.dragView.center.x);
            float yDistance = fabsf(self.dragDestinationCell.center.y - self.dragView.center.y);
            float maxDistance = xDistance > yDistance ? xDistance : yDistance;
            maxDistance = maxDistance - baseDistance * (1 - range);
            maxDistance = maxDistance > 0 ? maxDistance : 0;
            float alpha = 2 * maxDistance / baseDistance / range;
            alpha = alpha < 1 ? alpha : 1;
            self.dragDestinationCell.alpha = alpha;
            self.dragSourceCell.alpha = 1 - alpha;
        }

    }
}

- (BOOL)canStopDragPassCell:(CPPassCell *)passCell {
    return passCell == self.dragSourceCell;
}

- (void)stopDragPassCell:(CPPassCell *)passCell {
    NSAssert(passCell == self.dragSourceCell, @"Try to stop dragging a cell while dragging another!");
    NSAssert(self.dragView, @"Haven't started dragging pass cell when to stop it!");
    NSAssert(self.dragViewLeftConstraint, @"Haven't started dragging pass cell when to stop it!");
    NSAssert(self.dragViewTopConstraint, @"Haven't started dragging pass cell when to stop it!");

    if (self.dragDestinationCell) {
        self.dragDestinationCell.alpha = 1.0;
        self.dragSourceCell.alpha = 1.0;
        [[CPPassDataManager defaultManager] exchangePasswordBetweenIndex1:self.dragSourceCell.index andIndex2:self.dragDestinationCell.index];
    } else {
        self.dragSourceCell.backgroundColor = self.dragSourceBackgroundColor;
        self.dragSourceCell.alpha = 1.0;
    }
    
    [self.dragView removeFromSuperview];
    
    self.dragView = nil;
    self.dragSourceCell = nil;
    self.dragViewLeftConstraint = nil;
    self.dragViewTopConstraint = nil;
}

#pragma mark - NSFetchedResultsControllerDelegate implement

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    CPPassword *password = nil;
    CPPassCell *cell;
    switch (type) {
        case NSFetchedResultsChangeUpdate:
            password = [controller.fetchedObjects objectAtIndex:indexPath.row];
            cell = [self.passCells objectAtIndex:indexPath.row];
            cell.backgroundColor = password.displayColor;
            break;
        case NSFetchedResultsChangeMove:
            password = [controller.fetchedObjects objectAtIndex:indexPath.row];
            cell = [self.passCells objectAtIndex:indexPath.row];
            cell.backgroundColor = password.displayColor;
            password = [controller.fetchedObjects objectAtIndex:newIndexPath.row];
            cell = [self.passCells objectAtIndex:newIndexPath.row];
            cell.backgroundColor = password.displayColor;
            break;
        default:
            NSAssert(NO, @"Unknowed change reported by NSFetchResultsController!");
            break;
    }
}

@end
