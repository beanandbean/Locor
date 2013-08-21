//
//  CPAdManager.m
//  Passone
//
//  Created by wangsw on 8/21/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPAdManager.h"

#import "Reachability.h"

@interface CPAdManager ()

@property (strong, nonatomic) UIView *superview;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@property (strong, nonatomic) ADBannerView *iAdBannerView;

@property (strong, nonatomic) Reachability *appleReachability;

@end

@implementation CPAdManager

- (ADBannerView *)iAdBannerView {
    if (!_iAdBannerView) {
        _iAdBannerView = [[ADBannerView alloc] init];
        _iAdBannerView.delegate = self;
        _iAdBannerView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.superview addSubview:_iAdBannerView];
        
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:_iAdBannerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:_iAdBannerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:_iAdBannerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:_iAdBannerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    }
    return _iAdBannerView;
}

- (id)initWithSuperview:(UIView *)superview {
    self = [super init];
    if (self) {
        self.superview = superview;
        self.superview.backgroundColor = [UIColor redColor];
        //self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
        //[self.superview addConstraint:self.heightConstraint];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayAdBanner) name:kReachabilityChangedNotification object:nil];
        self.appleReachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
        [self.appleReachability startNotifier];
        
        [self displayAdBanner];
    }
    return self;
}

- (void)displayAdBanner {
    if (self.appleReachability.currentReachabilityStatus == NotReachable || !self.iAdBannerView.bannerLoaded) {
        //self.heightConstraint.constant = 0.0;
        self.iAdBannerView.hidden = YES;
    } else {
        //self.heightConstraint.constant = 100.0;
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
         
@end
