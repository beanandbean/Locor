//
//  CPPassCell.h
//  Locor
//
//  Created by wangyw on 6/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPViewManager.h"

@class CPPassCellManager;

@protocol CPPassCellDelegate <NSObject>

- (void)tapPassCell:(CPPassCellManager *)passCell;

- (void)startDragPassCell:(CPPassCellManager *)passCell;
- (void)dragPassCell:(CPPassCellManager *)passCell location:(CGPoint)location translation:(CGPoint)translation;
- (BOOL)canStopDragPassCell:(CPPassCellManager *)passCell;
- (void)stopDragPassCell:(CPPassCellManager *)passCell;

@end

@interface CPPassCellManager : CPViewManager <UIGestureRecognizerDelegate>

@property (nonatomic) NSUInteger index;

@property (strong, nonatomic) UIView *passCellView;

@property (strong, nonatomic) UIImageView *iconImage;

- (id)initWithSupermanager:(CPViewManager<CPPassCellDelegate> *)supermanager superview:(UIView *)superview frontLayer:(UIView *)frontLayer backLayer:(UIView *)backLayer andIndex:(NSUInteger)index;

- (void)setAlpha:(CGFloat)alpha;

- (void)setHidden:(BOOL)hidden;

- (void)setIcon:(NSString *)icon;

@end
