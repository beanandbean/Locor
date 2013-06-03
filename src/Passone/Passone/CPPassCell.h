//
//  CPPasswordCell.h
//  Passone
//
//  Created by wangyw on 6/2/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPPassCell;

@protocol CPPassCellDelegate <NSObject>

- (void)editPassCell:(CPPassCell *)cell;

@end

@interface CPPassCell : UIView

- (id)initWithDelegate:(id<CPPassCellDelegate>)delegate;

@end
