//
//  CPMainPasswordCanvas.m
//  Passone
//
//  Created by wangsw on 8/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainPasswordCanvas.h"

#import "CPPassoneConfig.h"

@implementation CPMainPasswordCanvas

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (self.points && self.points.count > 1) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat color[4] = {0.0, 0.0, 0.0, 1.0};
        CGContextSetStrokeColor(context, color);
        CGContextSetFillColor(context, color);
        CGContextSetLineWidth(context, MAIN_PASSWORD_LINE_WIDTH);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        
        CGContextBeginPath(context);
        
        CGPoint firstPoint = ((NSValue *)[self.points objectAtIndex:0]).CGPointValue;
        CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
        
        for (int i = 1; i < self.points.count; i++) {
            CGPoint currentPoint = ((NSValue *)[self.points objectAtIndex:i]).CGPointValue;
            CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
        }
        
        CGContextStrokePath(context);
    }
}

@end
