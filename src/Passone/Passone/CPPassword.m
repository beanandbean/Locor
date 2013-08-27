//
//  CPPassword.m
//  Passone
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassword.h"
#import "CPMemo.h"

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

- (UIColor *)color {
    return [[UIColor alloc] initWithRed:DEFAULT_COLORS[self.colorIndex.intValue * 3] green:DEFAULT_COLORS[self.colorIndex.intValue * 3 + 1] blue:DEFAULT_COLORS[self.colorIndex.intValue * 3 + 2] alpha:1.0];
}

- (UIColor *)displayColor {
    return self.isUsed.boolValue ? self.color : [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
}

- (UIColor *)reversedColor {
    return self.isUsed.boolValue ? [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0] : self.color;
}

- (NSString *)displayIcon {
    NSString *iconName = self.isUsed.boolValue ? self.icon : @"add";
    NSString *suffix = @"";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        suffix = @"_ipad";
    }
    return [NSString stringWithFormat:@"%@%@.png", iconName, suffix];
}

- (NSString *)reversedIcon {
    NSString *iconName = self.isUsed.boolValue ? @"add" : self.icon;
    NSString *suffix = @"";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        suffix = @"_ipad";
    }
    return [NSString stringWithFormat:@"%@%@.png", iconName, suffix];
}

@end
