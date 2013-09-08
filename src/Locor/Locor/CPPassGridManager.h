//
//  CPPassGridManager.h
//  Locor
//
//  Created by wangyw on 6/16/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCell.h"

#import "CPViewManager.h"

@interface CPPassGridManager : CPViewManager <CPPassCellDelegate, NSFetchedResultsControllerDelegate>

+ (NSArray *)makeDraggingCellFromCell:(CPPassCell *)passCell onView:(UIView *)view;

@end
