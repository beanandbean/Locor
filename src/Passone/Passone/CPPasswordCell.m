//
//  CPPasswordCell.m
//  Passone
//
//  Created by wangyw on 6/2/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPasswordCell.h"

@implementation CPPasswordCell

- (id)init {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor lightGrayColor];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
    }
    return self;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
}

@end
