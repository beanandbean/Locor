//
//  CPPassCell.h
//  Passone
//
//  Created by wangyw on 6/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPPassCell;

@protocol CPPassCellDelegate <NSObject>

- (void)tapPassCell:(CPPassCell *)passCell;
- (void)swipePassCell:(CPPassCell *)passCell;

- (void)startDragPassCell:(CPPassCell *)passCell;
- (void)dragPassCell:(CPPassCell *)passCell location:(CGPoint)location translation:(CGPoint)translation;
- (void)stopDragPassCell:(CPPassCell *)passCell;

@end

@interface CPPassCell : UIView

- (id)initWithDelegate:(id<CPPassCellDelegate>)delegate;

@end
