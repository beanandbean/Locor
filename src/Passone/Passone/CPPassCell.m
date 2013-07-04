//
//  CPPassCell.m
//  Passone
//
//  Created by wangyw on 6/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

enum CPPassCellState {
    CPPassCellStateNormal,
    CPPassCellStateDrugging
};

#import "CPPassCell.h"

@interface CPPassCell ()

@property (nonatomic) int state;

@property (weak, nonatomic) id<CPPassCellDelegate> delegate;

@end

@implementation CPPassCell

- (id)initWithIndex:(NSUInteger)index color:(UIColor *)color delegate:(id<CPPassCellDelegate>)delegate {
    self = [super init];
    if (self) {
        self.index = index;
        self.backgroundColor = color;
        self.delegate = delegate;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.state = CPPassCellStateNormal;
        
        // TODO: Tap once on pass cell to copy password. Tap twice to show pass edit view.
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
        
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        swipeGestureRecognizer.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:swipeGestureRecognizer];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        longPress.delegate = self;
        [self addGestureRecognizer: longPress];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delegate = self;
        [self addGestureRecognizer: pan];
    }
    return self;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.delegate tapPassCell:self];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    [self.delegate swipePassCell:self];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) || ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])) {
        return YES;
    } else {
        return NO;
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture {
    NSLog(@"(%d, %d, %d, %d), %d", UIGestureRecognizerStateBegan, UIGestureRecognizerStateEnded, UIGestureRecognizerStateCancelled, UIGestureRecognizerStateFailed, longPressGesture.state);
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        // [self.delegate swipePassCell:self];
        if (self.state == CPPassCellStateNormal) {
            [self.delegate startDragPassCell:self];
            self.state = CPPassCellStateDrugging;
        }
    } else if (longPressGesture.state == UIGestureRecognizerStateEnded || longPressGesture.state == UIGestureRecognizerStateCancelled || longPressGesture.state == UIGestureRecognizerStateFailed) {
        if (self.state == CPPassCellStateDrugging) {
            [self.delegate stopDragPassCell:self];
            self.state = CPPassCellStateNormal;
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        // [self.delegate startDragPassCell:self];
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        if (self.state == CPPassCellStateDrugging) {
            CGPoint location = [panGesture locationInView:panGesture.view];
            CGPoint translation = [panGesture translationInView:panGesture.view];
            [self.delegate dragPassCell:self location:location translation:translation];
            [panGesture setTranslation:CGPointZero inView:panGesture.view];
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        if (self.state == CPPassCellStateDrugging) {
            [self.delegate stopDragPassCell:self];
            self.state = CPPassCellStateNormal;
        }
    }
}

@end
