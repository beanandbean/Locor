//
//  CPAppearanceManager.m
//  Passone
//
//  Created by wangsw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPAppearanceManager.h"

#import "CPProcessManager.h"

static NSMutableArray *standardViews, *standardAttrs, *standardMultipliers, *standardConstants;

@interface CPAppearanceManager ()

+ (NSMutableArray *)arrayWithInitialValue:(id)value;

@end

@implementation CPAppearanceManager

+ (NSMutableArray *)arrayWithInitialValue:(id)value {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:CPMarginEdgeCount];
    for (int i = 0; i < CPMarginEdgeCount; i++) {
        [result addObject:value];
    }
    return result;
}

+ (void)registerStandardForEdge:(CPMarginEdge)edge asItem:(id)view attribute:(NSLayoutAttribute)attr multiplier:(CGFloat)multiplier constant:(CGFloat)c {
    if (!standardViews) {
        standardViews = [CPAppearanceManager arrayWithInitialValue:[NSNull null]];
    }
    if (!standardAttrs) {
        standardAttrs = [CPAppearanceManager arrayWithInitialValue:[NSNumber numberWithInt:NSLayoutAttributeNotAnAttribute]];
    }
    if (!standardMultipliers) {
        standardMultipliers = [CPAppearanceManager arrayWithInitialValue:[NSNumber numberWithFloat:0.0]];
    }
    if (!standardConstants) {
        standardConstants = [CPAppearanceManager arrayWithInitialValue:[NSNumber numberWithFloat:0.0]];
    }
    if (view) {
        [standardViews replaceObjectAtIndex:edge withObject:view];
    } else {
        [standardViews replaceObjectAtIndex:edge withObject:[NSNull null]];
    }
    [standardAttrs replaceObjectAtIndex:edge withObject:[NSNumber numberWithInt:attr]];
    [standardMultipliers replaceObjectAtIndex:edge withObject:[NSNumber numberWithFloat:multiplier]];
    [standardConstants replaceObjectAtIndex:edge withObject:[NSNumber numberWithFloat:c]];
}

+ (NSLayoutConstraint *)constraintWithItem:(id)view attribute:(NSLayoutAttribute)attr relatedBy:(NSLayoutRelation)relation constant:(CGFloat)c toEdge:(CPMarginEdge)edge {
    id toView = [standardViews objectAtIndex:edge];
    if (toView == [NSNull null]) {
        toView = nil;
    }
    NSLayoutAttribute toAttr = ((NSNumber *)[standardAttrs objectAtIndex:edge]).intValue;
    CGFloat multiplier = ((NSNumber *)[standardMultipliers objectAtIndex:edge]).floatValue;
    CGFloat standardConstant = ((NSNumber *)[standardConstants objectAtIndex:edge]).floatValue;
    CGFloat finalConstant = standardConstant + c;
    return [NSLayoutConstraint constraintWithItem:view attribute:attr relatedBy:relation toItem:toView attribute:toAttr multiplier:multiplier constant:finalConstant];
}

+ (NSArray *)constraintsForView:(UIView *)view1 toEqualToView:(UIView *)view2 {
    return [NSArray arrayWithObjects:
            [NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
            [NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
            [NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
            [NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
            nil];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations {
    [CPProcessManager increaseForbiddenCount];
    [UIView animateWithDuration:duration animations:animations completion:^(BOOL finished) {
        [CPProcessManager decreaseForbiddenCount];
    }];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
    [CPProcessManager increaseForbiddenCount];
    [UIView animateWithDuration:duration animations:animations completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        [CPProcessManager decreaseForbiddenCount];
    }];
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    [CPProcessManager increaseForbiddenCount];
    [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        [CPProcessManager decreaseForbiddenCount];
    }];
}

@end
