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

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

#pragma mark - constraint helper

+ (NSArray *)constraintsWithView:(UIView *)view1 alignToView:(UIView *)view2;

+ (NSLayoutConstraint *)constraintWithView:(id)view1 attribute:(NSLayoutAttribute)attr alignToView:(id)view2;
+ (NSLayoutConstraint *)constraintWithView:(id)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr2;

+ (NSLayoutConstraint *)constraintWithView:(id)view width:(CGFloat)width;
+ (NSLayoutConstraint *)constraintWithView:(id)view height:(CGFloat)height;

@end
