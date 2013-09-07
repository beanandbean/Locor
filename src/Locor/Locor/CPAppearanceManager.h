//
//  CPAppearanceManager.h
//  Locor
//
//  Created by wangsw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#define ATTR_END -1

typedef enum {
    CPMarginEdgeLeft,
    CPMarginEdgeRight,
    CPMarginEdgeCount
} CPMarginEdge;

@interface CPAppearanceManager : NSObject

+ (void)registerStandardForEdge:(CPMarginEdge)edge asItem:(UIView *)view attribute:(NSLayoutAttribute)attr multiplier:(CGFloat)multiplier constant:(CGFloat)c;
+ (NSLayoutConstraint *)constraintWithItem:(UIView *)view attribute:(NSLayoutAttribute)attr relatedBy:(NSLayoutRelation)relation constant:(CGFloat)c toEdge:(CPMarginEdge)edge;

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

#pragma mark - constraint helper

+ (NSArray *)constraintsWithView:(UIView *)view1 edgesAlignToView:(UIView *)view2;
+ (NSArray *)constraintsWithView:(UIView *)view1 centerAlignToView:(UIView *)view2;
+ (NSArray *)constraintsWithView:(UIView *)view1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr, ...;

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr;
+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr2;

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view width:(CGFloat)width;
+ (NSLayoutConstraint *)constraintWithView:(UIView *)view height:(CGFloat)height;

@end
