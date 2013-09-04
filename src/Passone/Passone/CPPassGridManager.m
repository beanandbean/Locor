//
//  CPPassGridManager.m
//  Passone
//
//  Created by wangyw on 6/16/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassGridManager.h"

#import "CPPassoneConfig.h"

#import "CPPassEditViewManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPAppearanceManager.h"

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
@property (strong, nonatomic) NSArray *dragDestinationShadowCellDetail;

@end

@implementation CPPassGridManager

+ (void)makeShadowOnCell:(UIView *)cell withColor:(UIColor *)color opacity:(float)opacity andRadius:(float)radius {
    cell.layer.shadowColor = color.CGColor;
    cell.layer.shadowOffset = CGSizeZero;
    cell.layer.shadowOpacity = opacity;
    cell.layer.shadowRadius = radius;
    cell.layer.masksToBounds = NO;
}

+ (void)expandShadowOnCell:(UIView *)cell withSize:(float)size; {
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectInset(cell.bounds, -size, -size)];
    cell.layer.shadowPath = bezierPath.CGPath;
}

+ (void)removeShadowOnCell:(UIView *)cell {
    cell.layer.shadowColor = [UIColor clearColor].CGColor;
    cell.layer.shadowOffset = CGSizeZero;
    cell.layer.shadowOpacity = 0.0;
    cell.layer.shadowRadius = 0.0;
}

+ (NSArray *)makeDraggingCellFromCell:(CPPassCell *)passCell onView:(UIView *)view withCover:(UIImageView *)cover {
    UIView *dragView = [[UIView alloc] init];
    
    [CPPassGridManager makeShadowOnCell:dragView withColor:passCell.backgroundColor opacity:1.0 andRadius:5.0];
    
    dragView.translatesAutoresizingMaskIntoConstraints = NO;
    dragView.backgroundColor = passCell.backgroundColor;
    
    [view addSubview:dragView];
    
    NSLayoutConstraint *dragViewLeftConstraint = [NSLayoutConstraint constraintWithItem:dragView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:passCell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    [view addConstraint:dragViewLeftConstraint];
    NSLayoutConstraint *dragViewTopConstraint = [NSLayoutConstraint constraintWithItem:dragView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:passCell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [view addConstraint:dragViewTopConstraint];
    
    NSArray *dragViewSizeConstraints = [[NSArray alloc] initWithObjects:
                                        [NSLayoutConstraint constraintWithItem:dragView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:passCell attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:dragView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:passCell attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],
                                        nil];
    [view addConstraints:dragViewSizeConstraints];
    
    UIView *fakeCoverContainer = [[UIView alloc] init];
    fakeCoverContainer.clipsToBounds = YES;
    fakeCoverContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [dragView addSubview:fakeCoverContainer];
    [dragView addConstraints:[CPAppearanceManager constraintsForView:fakeCoverContainer toEqualToView:dragView]];
    
    UIImageView *fakeCover = [[UIImageView alloc] initWithImage:cover.image];
    fakeCover.alpha = cover.alpha;
    fakeCover.transform = cover.transform;
    fakeCover.translatesAutoresizingMaskIntoConstraints = NO;
    
    [fakeCoverContainer addSubview:fakeCover];
    NSArray *dragViewCoverConstraints = [[NSArray alloc] initWithObjects:
                                         [NSLayoutConstraint constraintWithItem:fakeCover attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cover attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
                                         [NSLayoutConstraint constraintWithItem:fakeCover attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cover attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],
                                         nil];
    [view addConstraints:dragViewCoverConstraints];
    
    UIImageView *fakeIcon = [[UIImageView alloc] initWithImage:passCell.iconImage.image];
    fakeIcon.translatesAutoresizingMaskIntoConstraints = NO;
    
    [dragView addSubview:fakeIcon];
    [dragView addConstraint:[NSLayoutConstraint constraintWithItem:fakeIcon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:dragView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [dragView addConstraint:[NSLayoutConstraint constraintWithItem:fakeIcon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:dragView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [view layoutIfNeeded];
    
    [CPPassGridManager expandShadowOnCell:dragView withSize:5.0];
    
    return [NSArray arrayWithObjects:dragView, dragViewLeftConstraint, dragViewTopConstraint, dragViewSizeConstraints, dragViewCoverConstraints, fakeIcon, nil];
}

- (NSMutableArray *)passCells {
    if (!_passCells) {
        _passCells = [[NSMutableArray alloc] initWithCapacity:PASS_GRID_ROW_COUNT * PASS_GRID_COLUMN_COUNT];
    }
    return _passCells;
}

- (CPPassEditViewManager *)passEditViewManager {
    if (!_passEditViewManager) {
        _passEditViewManager = [[CPPassEditViewManager alloc] initWithSuperView:self.superview coverImage:self.coverImage andCells:self.passCells];
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
    
    NSArray *dragCellDetail = [CPPassGridManager makeDraggingCellFromCell:self.dragSourceCell onView:self.superview withCover:self.coverImage];
    self.dragView = [dragCellDetail objectAtIndex:0];
    self.dragViewLeftConstraint = [dragCellDetail objectAtIndex:1];
    self.dragViewTopConstraint = [dragCellDetail objectAtIndex:2];
    self.dragViewSizeConstraints = [dragCellDetail objectAtIndex:3];
    self.dragViewCoverConstraints = [dragCellDetail objectAtIndex:4];
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
            if (self.dragDestinationShadowCellDetail) {
                [self.superview removeConstraint:[self.dragDestinationShadowCellDetail objectAtIndex:1]];
                [self.superview removeConstraint:[self.dragDestinationShadowCellDetail objectAtIndex:2]];
                [self.superview removeConstraints:[self.dragDestinationShadowCellDetail objectAtIndex:3]];
                [self.superview removeConstraints:[self.dragDestinationShadowCellDetail objectAtIndex:4]];
                [(UIView *)[self.dragDestinationShadowCellDetail objectAtIndex:0] removeFromSuperview];
            }
            
            self.dragDestinationCell = newDragDestinationCell;
            self.dragDestinationShadowCellDetail = [CPPassGridManager makeDraggingCellFromCell:self.dragDestinationCell onView:self.superview withCover:self.coverImage];
            [self.superview bringSubviewToFront:self.dragView];
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
        NSMutableArray *destinationMovingCellDetail = [self.dragDestinationShadowCellDetail mutableCopy];
        [self.superview bringSubviewToFront:self.dragView];
        self.dragDestinationCell.hidden = YES;
        
        [self.superview removeConstraint:self.dragViewLeftConstraint];
        [self.superview removeConstraint:self.dragViewTopConstraint];
        
        self.dragViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.dragDestinationCell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        [self.superview addConstraint:self.dragViewLeftConstraint];
        self.dragViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dragDestinationCell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.superview addConstraint:self.dragViewTopConstraint];
        
        [self.superview removeConstraint:[destinationMovingCellDetail objectAtIndex:1]];
        [self.superview removeConstraint:[destinationMovingCellDetail objectAtIndex:2]];
        
        [destinationMovingCellDetail replaceObjectAtIndex:1 withObject:[NSLayoutConstraint constraintWithItem:[destinationMovingCellDetail objectAtIndex:0] attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [self.superview addConstraint:[destinationMovingCellDetail objectAtIndex:1]];
        [destinationMovingCellDetail replaceObjectAtIndex:2 withObject:[NSLayoutConstraint constraintWithItem:[destinationMovingCellDetail objectAtIndex:0] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dragSourceCell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [self.superview addConstraint:[destinationMovingCellDetail objectAtIndex:2]];
        
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            [[CPPassDataManager defaultManager] exchangePasswordBetweenIndex1:self.dragSourceCell.index andIndex2:self.dragDestinationCell.index];
            
            self.dragSourceCell.hidden = NO;
            self.dragDestinationCell.hidden = NO;
            
            [self.superview removeConstraint:self.dragViewLeftConstraint];
            [self.superview removeConstraint:self.dragViewTopConstraint];
            [self.superview removeConstraints:self.dragViewSizeConstraints];
            [self.superview removeConstraints:self.dragViewCoverConstraints];
            
            [self.superview removeConstraint:[destinationMovingCellDetail objectAtIndex:1]];
            [self.superview removeConstraint:[destinationMovingCellDetail objectAtIndex:2]];
            [self.superview removeConstraints:[destinationMovingCellDetail objectAtIndex:3]];
            [self.superview removeConstraints:[destinationMovingCellDetail objectAtIndex:4]];
             
            [self.dragView removeFromSuperview];
            [(UIView *)[destinationMovingCellDetail objectAtIndex:0] removeFromSuperview];
            
            self.dragView = nil;
            self.dragSourceCell = nil;
            self.dragViewLeftConstraint = nil;
            self.dragViewTopConstraint = nil;
            self.dragDestinationShadowCellDetail = nil;
        }];
    } else {
        self.dragViewLeftConstraint.constant = 0.0;
        self.dragViewTopConstraint.constant = 0.0;
        
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.dragSourceCell.hidden = NO;
            
            [self.superview removeConstraint:self.dragViewLeftConstraint];
            [self.superview removeConstraint:self.dragViewTopConstraint];
            [self.superview removeConstraints:self.dragViewSizeConstraints];
            [self.superview removeConstraints:self.dragViewCoverConstraints];
            [self.dragView removeFromSuperview];
            
            self.dragView = nil;
            self.dragSourceCell = nil;
            self.dragViewLeftConstraint = nil;
            self.dragViewTopConstraint = nil;
        }];
    }
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
