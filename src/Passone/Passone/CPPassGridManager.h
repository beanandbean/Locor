//
//  CPPassGridManager.h
//  Passone
//
//  Created by wangyw on 6/16/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCell.h"

@interface CPPassGridManager : NSObject <CPPassCellDelegate, NSFetchedResultsControllerDelegate>

+ (NSArray *)makeDraggingCellFromCell:(CPPassCell *)passCell onView:(UIView *)view withCover:(UIImageView *)cover;

- (id)initWithSuperView:(UIView *)superView;

@end
