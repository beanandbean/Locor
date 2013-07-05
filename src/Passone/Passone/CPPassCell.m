//
//  CPPassCell.m
//  Passone
//
//  Created by wangyw on 6/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCell.h"

#import "CPProcessManager.h"
#import "CPDraggingPassCellProcess.h"
#import "CPRemovingPassCellProcess.h"

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
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        // [self.delegate swipePassCell:self];
        if ([CPProcessManager startProcess:[CPDraggingPassCellProcess process]]) {
            [self.delegate startDragPassCell:self];
        }
    } else if (longPressGesture.state == UIGestureRecognizerStateEnded || longPressGesture.state == UIGestureRecognizerStateCancelled || longPressGesture.state == UIGestureRecognizerStateFailed) {
        if ([CPProcessManager stopProcess:[CPDraggingPassCellProcess process]]) {
            [self.delegate stopDragPassCell:self];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if ([CPProcessManager startProcess:[CPRemovingPassCellProcess process]]) {
            // TODO: Handling pass cell pan began, start removing animation.
        }
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        if ([CPProcessManager isInProcess:[CPDraggingPassCellProcess process]]) {
            CGPoint location = [panGesture locationInView:panGesture.view];
            CGPoint translation = [panGesture translationInView:panGesture.view];
            [self.delegate dragPassCell:self location:location translation:translation];
            [panGesture setTranslation:CGPointZero inView:panGesture.view];
        } else if ([CPProcessManager isInProcess:[CPRemovingPassCellProcess process]]) {
            // TODO: Handling pass cell pan changed, record translation and animate.
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        if ([CPProcessManager stopProcess:[CPDraggingPassCellProcess process]]) {
            [self.delegate stopDragPassCell:self];
        } else if ([CPProcessManager stopProcess:[CPRemovingPassCellProcess process]]) {
            // TODO: Handling pass cell pan ended, stop removing animation.
            // TODO: Handling pass cell pan ended, check if translation reach 50%.
            // TODO: Handling pass cell pan ended, may directly access model instead of delegate.
            [self.delegate swipePassCell:self];
        }
    }
}

@end
