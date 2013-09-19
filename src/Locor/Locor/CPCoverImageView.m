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

#import "CPMainViewController.h"

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRotated) name:CPDeviceOrientationWillChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CPDeviceOrientationWillChangeNotification object:nil];
}

- (NSArray *)positioningConstraints {
    return [NSArray arrayWithObjects:
            [CPAppearanceManager constraintWithView:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardCoverImageCenterX],
            [CPAppearanceManager constraintWithView:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardCoverImageCenterY],
            nil];
}

- (void)deviceRotated {
    self.transform = CGAffineTransformMakeRotation(ORIENTATION_RELATED_OBJ(M_PI_2, 0));
}

@end
