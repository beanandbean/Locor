//
//  CPAppearanceManager.m
//  Locor
//
//  Created by wangsw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPAppearanceManager.h"

#import "CPHelperMacros.h"

#import "CPProcessManager.h"

static NSMutableArray *g_standardViews, *g_standardAttrs, *g_standardMultipliers, *g_standardConstants;

@interface CPAppearanceManager ()

+ (NSMutableArray *)arrayWithInitialValue:(id)value;

@end

@implementation CPAppearanceManager

+ (NSMutableArray *)arrayWithInitialValue:(id)value {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:CPStandardPositionCount];
    for (int i = 0; i < CPStandardPositionCount; i++) {
        [result addObject:value];
    }
    return result;
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations {
    [CPAppearanceManager animateWithDuration:duration delay:0.0 options:0 preparation:nil animations:animations completion:nil];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
    [CPAppearanceManager animateWithDuration:duration delay:0.0 options:0 preparation:nil animations:animations completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
    [CPAppearanceManager animateWithDuration:duration delay:delay options:options preparation:nil animations:animations completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options preparation:(void (^)(void))preparation animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {    
    DELAY_BLOCK(delay, ^{
        INCREASE_FORBIDDEN_COUNT;
        if (preparation) {
            preparation();
        }
        [UIView animateWithDuration:duration delay:0.0 options:options animations:animations completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
            DECREASE_FORBIDDEN_COUNT;
        }];
    });
}

#pragma mark - Constraint Helper

+ (NSArray *)constraintsWithView:(UIView *)view1 edgesAlignToView:(UIView *)view2 {
    return [CPAppearanceManager constraintsWithView:view1 alignToView:view2 attribute:NSLayoutAttributeLeft, NSLayoutAttributeTop, NSLayoutAttributeRight, NSLayoutAttributeBottom, ATTR_END];
}

+ (NSArray *)constraintsWithView:(UIView *)view1 centerAlignToView:(UIView *)view2 {
    return [CPAppearanceManager constraintsWithView:view1 alignToView:view2 attribute:NSLayoutAttributeCenterX, NSLayoutAttributeCenterY, ATTR_END];
}

+ (NSArray *)constraintsWithView:(UIView *)view1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)firstAttr, ... {
    NSMutableArray *result = [NSMutableArray array];
    
    NSLayoutAttribute eachAttr;
    va_list attrList;
    if (firstAttr != ATTR_END) {
        [result addObject:[CPAppearanceManager constraintWithView:view1 alignToView:view2 attribute:firstAttr]];
        va_start(attrList, firstAttr);
        while ((eachAttr = va_arg(attrList, NSLayoutAttribute)) != ATTR_END) {
            [result addObject:[CPAppearanceManager constraintWithView:view1 alignToView:view2 attribute:eachAttr]];
        }
        va_end(attrList);
    }
    
    return result;
}

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr multiplier:1.0 constant:0.0];
}

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr2 {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr2 multiplier:1.0 constant:0.0];
}

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view width:(CGFloat)width {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
}

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view height:(CGFloat)height {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
}

#pragma mark - Standard Constraints Helper

+ (void)registerStandardForPosition:(CPStandardPosition)edge asItem:(UIView *)view attribute:(NSLayoutAttribute)attr multiplier:(CGFloat)multiplier constant:(CGFloat)c {
    if (!g_standardViews) {
        g_standardViews = [CPAppearanceManager arrayWithInitialValue:[NSNull null]];
    }
    if (!g_standardAttrs) {
        g_standardAttrs = [CPAppearanceManager arrayWithInitialValue:[NSNumber numberWithInt:NSLayoutAttributeNotAnAttribute]];
    }
    if (!g_standardMultipliers) {
        g_standardMultipliers = [CPAppearanceManager arrayWithInitialValue:[NSNumber numberWithFloat:0.0]];
    }
    if (!g_standardConstants) {
        g_standardConstants = [CPAppearanceManager arrayWithInitialValue:[NSNumber numberWithFloat:0.0]];
    }
    if (view) {
        [g_standardViews replaceObjectAtIndex:edge withObject:view];
    } else {
        [g_standardViews replaceObjectAtIndex:edge withObject:[NSNull null]];
    }
    [g_standardAttrs replaceObjectAtIndex:edge withObject:[NSNumber numberWithInt:attr]];
    [g_standardMultipliers replaceObjectAtIndex:edge withObject:[NSNumber numberWithFloat:multiplier]];
    [g_standardConstants replaceObjectAtIndex:edge withObject:[NSNumber numberWithFloat:c]];
}

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attr relatedBy:(NSLayoutRelation)relation constant:(CGFloat)c toPosition:(CPStandardPosition)edge {
    id toView = [g_standardViews objectAtIndex:edge];
    if (toView == [NSNull null]) {
        toView = nil;
    }
    NSLayoutAttribute toAttr = ((NSNumber *)[g_standardAttrs objectAtIndex:edge]).intValue;
    CGFloat multiplier = ((NSNumber *)[g_standardMultipliers objectAtIndex:edge]).floatValue;
    CGFloat standardConstant = ((NSNumber *)[g_standardConstants objectAtIndex:edge]).floatValue;
    CGFloat finalConstant = standardConstant + c;
    return [NSLayoutConstraint constraintWithItem:view attribute:attr relatedBy:relation toItem:toView attribute:toAttr multiplier:multiplier constant:finalConstant];
}

@end
