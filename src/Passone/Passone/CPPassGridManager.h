//
//  CPPassGridManager.h
//  Passone
//
//  Created by wangyw on 6/16/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCell.h"

@interface CPPassGridManager : NSObject <CPPassCellDelegate, NSFetchedResultsControllerDelegate>

- (id)initWithSuperView:(UIView *)superView;

@end
