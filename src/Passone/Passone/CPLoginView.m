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
        self.backgroundColor = [UIColor lightGrayColor];
        self.frame = CGRectMake(0, 0, 200, 200);
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return self;
}

@end
