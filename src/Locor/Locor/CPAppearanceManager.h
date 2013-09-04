//
//  CPAppearanceManager.h
//  Locor
//
//  Created by wangsw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

typedef enum {
    CPMarginEdgeLeft,
    CPMarginEdgeRight,
    CPMarginEdgeCount
} CPMarginEdge;

@interface CPAppearanceManager : NSObject

+ (void)registerStandardForEdge:(CPMarginEdge)edge asItem:(id)view attribute:(NSLayoutAttribute)attr multiplier:(CGFloat)multiplier constant:(CGFloat)c;
+ (NSLayoutConstraint *)constraintWithItem:(id)view attribute:(NSLayoutAttribute)attr relatedBy:(NSLayoutRelation)relation constant:(CGFloat)c toEdge:(CPMarginEdge)edge;

+ (NSArray *)constraintsForView:(UIView *)view1 toEqualToView:(UIView *)view2;

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

@end
