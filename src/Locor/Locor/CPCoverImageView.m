//
//  CPCoverImageView.m
//  Locor
//
//  Created by wangsw on 9/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPCoverImageView.h"

#import "CPHelperMacros.h"
#import "CPLocorConfig.h"

#import "CPAppearanceManager.h"

static UIImage *g_coverImage;

@implementation CPCoverImageView

- (id)init {
    if (!g_coverImage) {
        g_coverImage = [UIImage imageNamed:DEVICE_RELATED_PNG(@"cover")];
    }
    
    self = [super initWithImage:g_coverImage];
    if (self) {
        self.transform = CGAffineTransformMakeRotation(ORIENTATION_RELATED_OBJ(M_PI_2, 0));
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.alpha = WATER_MARK_ALPHA;
        
        [CPMainViewController registerDeviceRotateObserver:self];
    }
    return self;
}

- (void)dealloc {
    [CPMainViewController removeDeviceRotateObserver:self];
}

- (NSArray *)positioningConstraints {
    return [NSArray arrayWithObjects:
            [CPAppearanceManager constraintWithView:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardCoverImageCenterX],
            [CPAppearanceManager constraintWithView:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardCoverImageCenterY],
            nil];
}

#pragma mark - CPDeviceRotateObserver implement

- (void)deviceWillRotateToOrientation:(UIInterfaceOrientation)orientation {
    self.transform = CGAffineTransformMakeRotation(SPECIFIED_ORIENTATION_RELATED_OBJ(orientation, M_PI_2, 0));
}

@end
