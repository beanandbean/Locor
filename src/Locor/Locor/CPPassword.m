//
//  CPPassword.m
//  Locor
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassword.h"

#import "CPHelperMacros.h"

static const CGFloat DEFAULT_COLORS[] = {
    1.000, 0.000, 0.000,
    0.000, 0.800, 0.000,
    0.000, 0.000, 0.800,
    1.000, 0.867, 0.000,
    0.867, 0.000, 1.000,
    1.000, 0.533, 0.000,
    0.200, 0.800, 0.800,
    0.600, 0.400, 0.200,
    0.400, 0.200, 0.600
};

@implementation CPPassword

@dynamic index;
@dynamic text;
@dynamic isUsed;
@dynamic colorIndex;
@dynamic icon;
@dynamic memos;

- (UIColor *)realColor {
    return [[UIColor alloc] initWithRed:DEFAULT_COLORS[self.colorIndex.intValue * 3] green:DEFAULT_COLORS[self.colorIndex.intValue * 3 + 1] blue:DEFAULT_COLORS[self.colorIndex.intValue * 3 + 2] alpha:1.0];
}

- (UIColor *)displayColor {
    return self.isUsed.boolValue ? self.realColor : [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
}

- (UIColor *)reversedColor {
    return self.isUsed.boolValue ? [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0] : self.realColor;
}

- (NSString *)realIcon {
    return DEVICE_RELATED_PNG(self.icon);
}

- (NSString *)displayIcon {
    return DEVICE_RELATED_PNG(self.isUsed.boolValue ? self.icon : @"add");
}

- (NSString *)reversedIcon {
    return DEVICE_RELATED_PNG(self.isUsed.boolValue ? @"add" : self.icon);
}

@end
