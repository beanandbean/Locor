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

@property (strong, nonatomic) UIView *iconLayer;

@property (strong, nonatomic) UIView *dragView;
@property (weak, nonatomic) CPPassCell *dragSourceCell;
@property (weak, nonatomic) CPPassCell *dragDestinationCell;
@property (strong, nonatomic) NSLayoutConstraint *dragViewLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *dragViewTopConstraint;
@property (strong, nonatomic) NSArray *dragViewSizeConstraints;
@property (strong, nonatomic) NSArray *dragViewCoverConstraints;

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

- (UIView *)iconLayer {
    if (!_iconLayer) {
        _iconLayer = [[UIView alloc] init];
        _iconLayer.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.superview addSubview:_iconLayer];
        
        [self.superview addConstraints:[CPAppearanceManager constraintsForView:_iconLayer toEqualToView:self.passGridView]];
    }
    return _iconLayer;
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
        
        // TODO: Make cover images bigger.
        self.coverImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:coverName]];
        self.coverImage.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.coverImage.translatesAutoresizingMaskIntoConstraints = NO;
        self.coverImage.alpha = WATER_MARK_ALPHA;
        [self.superview addSubview:self.coverImage];
        
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.coverImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.coverImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
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
    self.dragSourceCell.hidden = YES;
    
    self.dragView = [[UIView alloc] init];
    
    self.dragView.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.dragView.layer.shadowOffset = CGSizeZero;
    self.dragView.layer.shadowOpacity = 1.0;
    self.dragView.layer.shadowRadius = 5.0;
    self.dragView.layer.masksToBounds = NO;
    
    self.dragView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dragView.backgroundColor = self.dragSourceCell.backgroundColor;

    [self.superview addSubview:self.dragView];
    
    self.dragViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    [self.superview addConstraint:self.dragViewLeftConstraint];
    self.dragViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.superview addConstraint:self.dragViewTopConstraint];
    
    self.dragViewSizeConstraints = [[NSArray alloc] initWithObjects:
                                    [NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],
                                    [NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],
                                    nil];
    [self.superview addConstraints:self.dragViewSizeConstraints];
    
    UIView *fakeCoverContainer = [[UIView alloc] init];
    fakeCoverContainer.clipsToBounds = YES;
    fakeCoverContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dragView addSubview:fakeCoverContainer];
    [self.dragView addConstraints:[CPAppearanceManager constraintsForView:fakeCoverContainer toEqualToView:self.dragView]];
    
    UIImageView *fakeCover = [[UIImageView alloc] initWithImage:self.coverImage.image];
    fakeCover.alpha = self.coverImage.alpha;
    fakeCover.transform = self.coverImage.transform;
    fakeCover.translatesAutoresizingMaskIntoConstraints = NO;
    
    [fakeCoverContainer addSubview:fakeCover];
    self.dragViewCoverConstraints = [[NSArray alloc] initWithObjects:
                                     [NSLayoutConstraint constraintWithItem:fakeCover attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.coverImage attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
                                     [NSLayoutConstraint constraintWithItem:fakeCover attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.coverImage attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],
                                     nil];
    [self.superview addConstraints:self.dragViewCoverConstraints];
    
    UIImageView *fakeIcon = [[UIImageView alloc] initWithImage:self.dragSourceCell.iconImage.image];
    fakeIcon.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.dragView addSubview:fakeIcon];
    [self.dragView addConstraint:[NSLayoutConstraint constraintWithItem:fakeIcon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.dragView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.dragView addConstraint:[NSLayoutConstraint constraintWithItem:fakeIcon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.dragView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [self.superview layoutIfNeeded];
    
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
        [self.superview layoutIfNeeded];
        
        CGPoint centerInPassGridView = [self.passGridView convertPoint:self.dragView.center fromView:self.superview];
        
        CPPassCell *newDragDestinationCell = nil;
        if (CGRectContainsPoint(self.passGridView.bounds, self.dragView.center)) {
            newDragDestinationCell = [self.passCells objectAtIndex:0];
            float distance = hypotf(newDragDestinationCell.center.x - centerInPassGridView.x, newDragDestinationCell.center.y - centerInPassGridView.y);
            for (CPPassCell *cell in self.passCells) {
                float newDistance = hypotf(cell.center.x - centerInPassGridView.x, cell.center.y - centerInPassGridView.y);
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
            self.dragDestinationCell = newDragDestinationCell;
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

    self.dragSourceCell.hidden = NO;
    
    // Add animation to exchange pass cells.
    
    if (self.dragDestinationCell) {
        [[CPPassDataManager defaultManager] exchangePasswordBetweenIndex1:self.dragSourceCell.index andIndex2:self.dragDestinationCell.index];
    }
    
    [self.superview removeConstraint:self.dragViewLeftConstraint];
    [self.superview removeConstraint:self.dragViewTopConstraint];
    [self.superview removeConstraints:self.dragViewSizeConstraints];
    [self.superview removeConstraints:self.dragViewCoverConstraints];
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
            cell.icon = password.displayIcon;
            break;
        case NSFetchedResultsChangeMove:
            password = [controller.fetchedObjects objectAtIndex:indexPath.row];
            cell = [self.passCells objectAtIndex:indexPath.row];
            cell.backgroundColor = password.displayColor;
            cell.icon = password.displayIcon;
            password = [controller.fetchedObjects objectAtIndex:newIndexPath.row];
            cell = [self.passCells objectAtIndex:newIndexPath.row];
            cell.backgroundColor = password.displayColor;
            cell.icon = password.displayIcon;
            break;
        default:
            NSAssert(NO, @"Unknowed change reported by NSFetchResultsController!");
            break;
    }
}

@end
