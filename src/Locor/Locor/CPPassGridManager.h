//
//  CPPassGridManager.h
//  Locor
//
//  Created by wangyw on 6/16/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCellManager.h"

#import "CPViewManager.h"

@interface CPPassGridManager : CPViewManager <CPPassCellDelegate, NSFetchedResultsControllerDelegate>

+ (NSArray *)makeDraggingCellFromCell:(CPPassCellManager *)passCell onView:(UIView *)view withShadow:(BOOL)shadow;

@end
