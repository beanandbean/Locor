//
//  CPPassCell.m
//  Passone
//
//  Created by wangyw on 6/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCell.h"

@interface CPPassCell ()

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
        
        // TODO: Adjust pass cell shadow.
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.layer.shadowOpacity = 0.6;

        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
        
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        swipeGestureRecognizer.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:swipeGestureRecognizer];
        
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)]];
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
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
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        // TODO: Now use long press to simulate two-finger swipe, change it later.
        [self.delegate swipePassCell:self];
        // [self.delegate startDragPassCell:self];
    } else if (longPressGesture.state == UIGestureRecognizerStateEnded || longPressGesture.state == UIGestureRecognizerStateCancelled || longPressGesture.state == UIGestureRecognizerStateFailed) {
        // [self.delegate stopDragPassCell:self];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self.delegate startDragPassCell:self];
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [panGesture locationInView:panGesture.view];
        CGPoint translation = [panGesture translationInView:panGesture.view];
        [self.delegate dragPassCell:self location:location translation:translation];
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        [self.delegate stopDragPassCell:self];
    }
}

@end
