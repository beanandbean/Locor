//
//  CPCoverImageView.m
//  Locor
//
//  Created by wangsw on 9/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPCoverImageView.h"

#import "CPLocorConfig.h"

static UIImage *coverImage;

@implementation CPCoverImageView

- (id)init {
    if (!coverImage) {
        NSString *coverName;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            coverName = @"bg-iphone";
        } else {
            coverName = @"bg-ipad";
        }
        coverImage = [UIImage imageNamed:coverName];
    }
    
    self = [super initWithImage:coverImage];
    if (self) {
        [self deviceWillRotateToOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.alpha = WATER_MARK_ALPHA;
    }
    return self;
}

- (void)deviceWillRotateToOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
    } else {
        self.transform = CGAffineTransformMakeRotation(0);
    }
}

@end
