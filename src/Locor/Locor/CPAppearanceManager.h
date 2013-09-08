//
//  CPAppearanceManager.h
//  Locor
//
//  Created by wangsw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#define ATTR_END -1

typedef enum {
    CPStandardMarginEdgeLeft,
    CPStandardMarginEdgeRight,
    CPStandardCoverImageCenterX,
    CPStandardCoverImageCenterY,
    CPStandardPositionCount
} CPStandardPosition;

@interface CPAppearanceManager : NSObject

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion;
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL))completion;

#pragma mark - Constraints Helper

+ (NSArray *)constraintsWithView:(UIView *)view1 edgesAlignToView:(UIView *)view2;
+ (NSArray *)constraintsWithView:(UIView *)view1 centerAlignToView:(UIView *)view2;
+ (NSArray *)constraintsWithView:(UIView *)view1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr, ...;

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr;
+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr2;

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view width:(CGFloat)width;
+ (NSLayoutConstraint *)constraintWithView:(UIView *)view height:(CGFloat)height;

#pragma mark - Standard Constraints Helper

+ (void)registerStandardForPosition:(CPStandardPosition)edge asItem:(UIView *)view attribute:(NSLayoutAttribute)attr multiplier:(CGFloat)multiplier constant:(CGFloat)c;

+ (NSArray *)constraintsWithViewCenterAlignToStandardCoverImageCenter:(UIView *)view;

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attr relatedBy:(NSLayoutRelation)relation constant:(CGFloat)c toPosition:(CPStandardPosition)edge;

@end
