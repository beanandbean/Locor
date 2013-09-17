//
//  CPIconPicker.m
//  Locor
//
//  Created by wangsw on 9/6/13.
//  Copyright (c) 2013 beanandbean. All rights reserved.
//

#import "CPIconPicker.h"

#import "CPHelperMacros.h"
#import "CPLocorConfig.h"

static const char *ICON_NAMES[] = {"aries", "taurus", "gemini", "cancer", "leo", "virgo", "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"};

static const NSString *ANIMATION_ID_KEY = @"animationId", *OFFSET_DELTA_KEY = @"offsetDelta";

static float FULL_WIDTH, DRAG_MULTIPLIER;

@interface CPIconPicker ()

@property (weak, nonatomic) id<CPIconPickerDelegate> delegate;

@property (nonatomic) float offset;
@property (nonatomic) float basicOffset;

@property (nonatomic) int currentAnimationId;
@property (strong, nonatomic) NSMutableArray *animationIdFree;

@end

@implementation CPIconPicker

- (id)initWithDelegate:(id<CPIconPickerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.offset = 0.0;
        self.delegate = delegate;
        self.animationIdFree = [NSMutableArray array];
        
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnItems:)]];
        
        [CPMainViewController registerDeviceRotateObserver:self];
        
        // CONSTANTS that are related to device idiom and cannot be determined at compile-time:
        FULL_WIDTH = ICON_PICKER_ITEM_COUNT * ICON_PICKER_ITEM_MAX_SIZE;
        DRAG_MULTIPLIER = 1 / ICON_PICKER_ITEM_POSITION_MULTIPLIER; // A test shows that the following formula determines the best drag multiplier
    }
    return self;
}

- (void)dealloc {
    [CPMainViewController removeDeviceRotateObserver:self];
}

- (void)setStartIcon:(NSString *)iconName {
    int i = 0;
    self.offset = 0.0;
    
    while (i < ICON_PICKER_ITEM_COUNT && ![iconName isEqualToString:CSTR_TO_OBJC(ICON_NAMES[i])]) {
        i++;
        self.offset += ICON_PICKER_ITEM_MAX_SIZE;
    }

    NSAssert(i < ICON_PICKER_ITEM_COUNT, @"CPIconPicker get unknown start icon name!");
}

- (void)setEnabled:(BOOL)enabled {
    self.userInteractionEnabled = enabled;
    self.alpha = enabled ? 1.0 : 0.0;
}

- (void)panOnItems:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.basicOffset = self.offset;
        
        self.currentAnimationId = -1;
        for (int i = 0; i < self.animationIdFree.count; i++) {
            if (((NSNumber *)[self.animationIdFree objectAtIndex:i]).boolValue) {
                self.currentAnimationId = i;
                [self.animationIdFree replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
                break;
            }
        }
        if (self.currentAnimationId == -1) {
            self.currentAnimationId = self.animationIdFree.count;
            [self.animationIdFree addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    self.offset = self.basicOffset - [gestureRecognizer translationInView:gestureRecognizer.view].x * DRAG_MULTIPLIER;
    while (self.offset >= FULL_WIDTH) {
        self.offset -= FULL_WIDTH;
    }
    while (self.offset < 0.0) {
        self.offset += FULL_WIDTH;
    }
    
    [self setNeedsDisplay];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        float oldOffset = fabsf(self.offset), newOffset = 0.0, sign = self.offset / fabsf(self.offset);
        while (oldOffset >= ICON_PICKER_ITEM_MAX_SIZE) {
            oldOffset -= ICON_PICKER_ITEM_MAX_SIZE;
            newOffset += ICON_PICKER_ITEM_MAX_SIZE;
        }
        if (oldOffset != 0.0) {
            if (oldOffset >= ICON_PICKER_ITEM_MAX_SIZE / 2.0) {
                newOffset += ICON_PICKER_ITEM_MAX_SIZE;
            }
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.currentAnimationId], ANIMATION_ID_KEY, [NSNumber numberWithFloat:newOffset * sign - self.offset], OFFSET_DELTA_KEY, nil];
            [NSTimer scheduledTimerWithTimeInterval:1.0 / 50.0 target:self selector:@selector(animationTimerFired:) userInfo:userInfo repeats:NO];
        }
    }
}

- (void)animateOffsetBy:(float)delta underAnimationId:(int)animationId {
    int sign = delta / fabsf(delta);
    if (fabsf(delta) >= ICON_PICKER_ANIMATION_SPEED_MULTIPLIER) {
        self.offset += sign * ICON_PICKER_ANIMATION_SPEED_MULTIPLIER;
        [self setNeedsDisplay];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:animationId], ANIMATION_ID_KEY, [NSNumber numberWithFloat:delta - sign * ICON_PICKER_ANIMATION_SPEED_MULTIPLIER], OFFSET_DELTA_KEY, nil];
        [NSTimer scheduledTimerWithTimeInterval:1.0 / ICON_PICKER_ANIMATION_FRAME_PER_SECOND target:self selector:@selector(animationTimerFired:) userInfo:userInfo repeats:NO];
    } else {
        self.offset += delta;
        [self setNeedsDisplay];
        
        int index = (int)(self.offset / ICON_PICKER_ITEM_MAX_SIZE) % ICON_PICKER_ITEM_COUNT;
        [self.delegate iconSelected:CSTR_TO_OBJC(ICON_NAMES[index])];
    }
}

- (void)animationTimerFired:(NSTimer *)timer {
    NSDictionary *userInfo = timer.userInfo;
    int animationId = ((NSNumber *)[userInfo objectForKey:ANIMATION_ID_KEY]).intValue;
    if (animationId == self.currentAnimationId) {
        [self animateOffsetBy:((NSNumber *)[userInfo objectForKey:OFFSET_DELTA_KEY]).floatValue underAnimationId:animationId];
    } else {
        [self.animationIdFree replaceObjectAtIndex:animationId withObject:[NSNumber numberWithBool:YES]];
        while (((NSNumber *)self.animationIdFree.lastObject).boolValue) {
            [self.animationIdFree removeLastObject];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    float maxOffset = self.frame.size.width / 2;
    float xCenter = maxOffset, yCenter = self.frame.size.height / 2;
    for (int i = 0; i < ICON_PICKER_ITEM_COUNT; i++) {
        float centerOffset = i * ICON_PICKER_ITEM_MAX_SIZE - self.offset;
        while (fabsf(centerOffset + FULL_WIDTH) < fabsf(centerOffset)) {
            centerOffset += FULL_WIDTH;
        }
        while (fabsf(centerOffset - FULL_WIDTH) < fabsf(centerOffset)) {
            centerOffset -= FULL_WIDTH;
        }
        if (fabsf(centerOffset) < maxOffset) {
            int sign = centerOffset > 0 ? 1 : -1;
            float ratio = fabsf(centerOffset) / maxOffset;
            
            UIImage *iconImage = [UIImage imageNamed:DEVICE_RELATED_PNG(CSTR_TO_OBJC(ICON_NAMES[i]))];
            
            float itemSize = ICON_PICKER_ITEM_MAX_SIZE * (1 - powf(ratio, ICON_PICKER_ITEM_SIZE_EXPONENT));
            CGRect rect = CGRectMake(xCenter + maxOffset * powf(ratio, ICON_PICKER_ITEM_POSITION_EXPONENT) * sign * ICON_PICKER_ITEM_POSITION_MULTIPLIER - itemSize / 2, yCenter - itemSize / 2, itemSize, itemSize);
            
            [iconImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:powf(1 - ratio, ICON_PICKER_ITEM_ALPHA_EXPONENT)];
        }
    }
}

#pragma mark - CPDeviceRotateObserver implement

- (void)deviceWillRotateToOrientation:(UIInterfaceOrientation)orientation {
    [self setNeedsDisplay];
}

@end
