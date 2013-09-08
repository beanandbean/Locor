//
//  CPAdManager.m
//  Locor
//
//  Created by wangsw on 8/21/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPAdManager.h"

#import "CPAppearanceManager.h"

#import "Reachability.h"

@interface CPAdManager ()

@property (strong, nonatomic) ADBannerView *iAdBannerView;

@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@property (strong, nonatomic) Reachability *appleReachability;

@end

@implementation CPAdManager

- (void)loadAnimated:(BOOL)animated {
    [super loadAnimated:animated];
    
    [self.superview addSubview:self.iAdBannerView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.superview edgesAlignToView:self.iAdBannerView]];
    [self.superview addConstraint:self.heightConstraint];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [self.appleReachability startNotifier];
    [self displayAdBanner];
}

- (void)unloadAnimated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [super unloadAnimated:animated];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    [self displayAdBanner];
}

- (void)displayAdBanner {
    if (self.appleReachability.currentReachabilityStatus == NotReachable || !self.iAdBannerView.bannerLoaded) {
        // TODO: Use other advertisements when apple's iAd is not reachable.
        
        // self.heightConstraint.constant = 0.0;
        // self.iAdBannerView.hidden = YES;
    } else {
        self.heightConstraint.constant = ((UIView *)[self.iAdBannerView.subviews objectAtIndex:0]).frame.size.height;
        self.iAdBannerView.hidden = NO;
    }
}

#pragma mark - AdBannerViewDelegate implementation

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self displayAdBanner];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self displayAdBanner];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
}

#pragma mark - lazy init

- (ADBannerView *)iAdBannerView {
    if (!_iAdBannerView) {
        _iAdBannerView = [[ADBannerView alloc] init];
        _iAdBannerView.delegate = self;
        _iAdBannerView.translatesAutoresizingMaskIntoConstraints = NO;        
    }
    return _iAdBannerView;
}

- (NSLayoutConstraint *)heightConstraint {
    if (!_heightConstraint) {
        _heightConstraint = [CPAppearanceManager constraintWithView:self.superview height:0.0];
    }
    return _heightConstraint;
}

- (Reachability *)appleReachability {
    if (!_appleReachability) {
        _appleReachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    }
    return _appleReachability;
}
         
@end
