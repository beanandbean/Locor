//
//  CPPassCell.h
//  Passone
//
//  Created by wangyw on 6/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPPassCell;
@class CPPassword;

@protocol CPPassCellDelegate <NSObject>

- (void)tapPassCell:(CPPassCell *)passCell;
- (void)swipePassCell:(CPPassCell *)passCell;

- (void)startDragPassCell:(CPPassCell *)passCell;
- (void)dragPassCell:(CPPassCell *)passCell location:(CGPoint)location translation:(CGPoint)translation;
- (void)stopDragPassCell:(CPPassCell *)passCell;

@end

@interface CPPassCell : UIView

@property (nonatomic) NSUInteger index;

- (id)initWithIndex:(NSUInteger)index color:(UIColor *)color delegate:(id<CPPassCellDelegate>)delegate;

@end
