//
//  CPPassCell.h
//  Locor
//
//  Created by wangyw on 6/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPPassCell;
@class CPPassword;

@protocol CPPassCellDelegate <NSObject>

- (UIView *)iconLayer;

- (void)tapPassCell:(CPPassCell *)passCell;

- (void)startDragPassCell:(CPPassCell *)passCell;
- (void)dragPassCell:(CPPassCell *)passCell location:(CGPoint)location translation:(CGPoint)translation;
- (BOOL)canStopDragPassCell:(CPPassCell *)passCell;
- (void)stopDragPassCell:(CPPassCell *)passCell;

@end

@interface CPPassCell : UIView <UIGestureRecognizerDelegate>

@property (nonatomic) NSUInteger index;
@property (strong, nonatomic) UIImageView *iconImage;

- (void)setIcon:(NSString *)icon;

- (id)initWithIndex:(NSUInteger)index delegate:(id<CPPassCellDelegate>)delegate;

- (void)initializeIcon;

@end
