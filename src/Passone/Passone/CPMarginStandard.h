//
//  CPMarginStandard.h
//  Passone
//
//  Created by wangsw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

typedef enum {
    CPMarginEdgeLeft,
    CPMarginEdgeRight,
    CPMarginEdgeCount
} CPMarginEdge;

@interface CPMarginStandard : NSObject

+ (void)registerStandardForEdge:(CPMarginEdge)edge asItem:(id)view attribute:(NSLayoutAttribute)attr multiplier:(CGFloat)multiplier constant:(CGFloat)c;

+ (NSLayoutConstraint *)constraintWithItem:(id)view attribute:(NSLayoutAttribute)attr relatedBy:(NSLayoutRelation)relation constant:(CGFloat)c toEdge:(CPMarginEdge)edge;

@end
