//
//  CPPassword.m
//  Passone
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassword.h"
#import "CPMemo.h"

@implementation CPPassword

@dynamic colorBlue;
@dynamic creationDate;
@dynamic colorGreen;
@dynamic index;
@dynamic colorRed;
@dynamic text;
@dynamic isUsed;
@dynamic memos;

- (UIColor *)color {
    return [[UIColor alloc] initWithRed:self.colorRed.floatValue green:self.colorGreen.floatValue blue:self.colorBlue.floatValue alpha:1.0];
}

@end
