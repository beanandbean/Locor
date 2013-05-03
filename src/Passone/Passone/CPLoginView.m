//
//  CPLoginView.m
//  Passone
//
//  Created by wangyw on 5/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPLoginView.h"

@implementation CPLoginView

- (id)init {
    self = [super init];
    if (self) {
        float red = (rand() % 256) / 256.0;
        float green = (rand() % 256) / 256.0;
        float blue = (rand() % 256) / 256.0;
        self.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
        self.frame = CGRectMake(0, 0, 200, 200);
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return self;
}

@end
