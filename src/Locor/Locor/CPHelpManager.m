//
//  CPHelpManager.m
//  Locor
//
//  Created by wangyw on 9/6/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPHelpManager.h"

#import "CPAppearanceManager.h"

@interface CPHelpManager ()

- (void)closeButtonTouched:(id)sender;

@end

@implementation CPHelpManager

- (void)loadAnimated:(BOOL)animated {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor grayColor];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:scrollView];
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = 3;
    pageControl.currentPage = 0;
    pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:pageControl];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeButton addTarget:self action:@selector(closeButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:closeButton];
    
    [scrollView addConstraints:[NSArray arrayWithObjects:
                                [CPAppearanceManager constraintWithView:closeButton width:100.0],
                                [CPAppearanceManager constraintWithView:closeButton height:44.0],
                                nil]];
    [scrollView addConstraints:[CPAppearanceManager constraintsWithView:closeButton centerAlignToView:scrollView]];
    
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:scrollView alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeTop, ATTR_END]];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:pageControl alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom, ATTR_END]];
    
    [self.superview addConstraints:[NSArray arrayWithObjects:
                                    [CPAppearanceManager constraintWithView:pageControl height:44.0],
                                    [CPAppearanceManager constraintWithView:scrollView attribute:NSLayoutAttributeBottom alignToView:pageControl attribute:NSLayoutAttributeTop],
                                    nil]];
}

- (void)unloadAnimated:(BOOL)animated {
    [self.supermanager submanagerWillUnload:self];
    
    for (UIView *view in self.superview.subviews) {
        [view removeFromSuperview];
    }
    
    [self.supermanager submanagerDidUnload:self];
}

- (void)closeButtonTouched:(id)sender {
    [self unloadAnimated:YES];
}

@end
