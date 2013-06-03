//
//  CPPasswordCell.m
//  Passone
//
//  Created by wangyw on 6/2/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCell.h"

@interface CPPassCell ()

@property (weak, nonatomic) id<CPPassCellDelegate> delegate;

@end

@implementation CPPassCell

- (id)initWithDelegate:(id<CPPassCellDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor lightGrayColor];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
    }
    return self;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.delegate editPassCell:self];
}

@end
