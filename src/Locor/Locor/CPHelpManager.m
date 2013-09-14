//
//  CPHelpManager.m
//  Locor
//
//  Created by wangyw on 9/6/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPHelpManager.h"

#import "CPAppearanceManager.h"
#import "CPLocorConfig.h"

@interface CPHelpManager ()

@property (nonatomic) BOOL manualScrolling;

@property (strong, nonatomic) NSArray *texts;
@property (strong, nonatomic) NSArray *images;

@property (strong, nonatomic) UIImageView *frontImageView;
@property (strong, nonatomic) UIImageView *backImageView;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

- (void)createViews;
- (void)createTextLabels;

- (void)autoScrollToNextPage;

- (void)pageControlValueChanged:(id)sender;
- (void)startButtonTouched:(id)sender;

@end

@implementation CPHelpManager

static const NSTimeInterval PAGE_DELAY_TIME = 3.0;

- (void)loadAnimated:(BOOL)animated {
    [self createViews];
    [self performSelector:@selector(autoScrollToNextPage) withObject:nil afterDelay:PAGE_DELAY_TIME];
}

- (void)unloadAnimated:(BOOL)animated {
    [self.supermanager submanagerDidUnload:self];
}

- (void)createViews {
    UILabel *title = [[UILabel alloc] init];
    title.backgroundColor = [UIColor clearColor];
    title.text = @"LOCOR";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:title];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:title alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeTop, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:title height:HELP_TITLE_HEIGHT]];

    UIView *buttonView = [[UIView alloc] init];
    buttonView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:buttonView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:buttonView alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:buttonView height:HELP_BUTTON_VIEW_HEIGHT]];
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startButton setTitle:@"Open My LOCOR" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    startButton.translatesAutoresizingMaskIntoConstraints = NO;
    [buttonView addSubview:startButton];
    [startButton addConstraint:[CPAppearanceManager constraintWithView:startButton width:HELP_START_BUTTON_WIDTH]];
    [startButton addConstraint:[CPAppearanceManager constraintWithView:startButton height:HELP_START_BUTTON_HEIGHT]];
    [buttonView addConstraints:[CPAppearanceManager constraintsWithView:startButton centerAlignToView:buttonView]];
    
    [self.superview addSubview:self.backImageView];
    [self.superview addSubview:self.frontImageView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.backImageView alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.backImageView attribute:NSLayoutAttributeTop alignToView:title attribute:NSLayoutAttributeBottom]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.backImageView attribute:NSLayoutAttributeBottom alignToView:buttonView attribute:NSLayoutAttributeTop]];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.frontImageView edgesAlignToView:self.backImageView]];
    
    [self.superview addSubview:self.scrollView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.scrollView edgesAlignToView:self.backImageView]];
    
    [self.superview addSubview:self.pageControl];
    [self.pageControl addConstraint:[CPAppearanceManager constraintWithView:self.pageControl height:HELP_PAGE_CONTROL_HEIGHT]];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.pageControl alignToView:self.scrollView attribute:NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight, ATTR_END]];

    [self createTextLabels];
}

- (void)createTextLabels {
    [self.superview layoutIfNeeded];
    float pageWidth = self.scrollView.bounds.size.width;
    float pageHeight = self.scrollView.bounds.size.height;
    self.scrollView.contentSize = CGSizeMake(pageWidth * self.texts.count, pageHeight);
    int page = 0;
    for (NSString *text in self.texts) {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(page * pageWidth, pageHeight - self.pageControl.frame.size.height - HELP_TEXT_HEIGHT, pageWidth, HELP_TEXT_HEIGHT)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.numberOfLines = 2;
        textLabel.text = text;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor whiteColor];
        [self.scrollView addSubview:textLabel];
        page++;
    }
}

- (void)autoScrollToNextPage {
    if (!self.manualScrolling) {
        int nextPage = (self.pageControl.currentPage + 1) % self.pageControl.numberOfPages;
        [self.scrollView setContentOffset:CGPointMake(nextPage * self.scrollView.bounds.size.width, 0) animated:YES];
        
        [self performSelector:@selector(autoScrollToNextPage) withObject:nil afterDelay:PAGE_DELAY_TIME];
    }
}

- (void)pageControlValueChanged:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(self.pageControl.currentPage * self.scrollView.bounds.size.width, 0) animated:YES];

    self.manualScrolling = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)startButtonTouched:(id)sender {
    [self unloadAnimated:YES];
}

#pragma mark - UIScrollViewDelegate implement

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isTracking) {
        self.manualScrolling = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    
    float offset = scrollView.contentOffset.x / scrollView.bounds.size.width;
    int page = offset;
    self.frontImageView.image = [self.images objectAtIndex:page];
    self.backImageView.image = [self.images objectAtIndex:(page + 1) % self.pageControl.numberOfPages];
    
    float alpha = offset - page;
    self.frontImageView.alpha = 1 - alpha;
    self.backImageView.alpha = alpha;
    
    self.pageControl.currentPage = offset + 0.5;
}

#pragma mark - lazy init

- (NSArray *)texts {
    if (!_texts) {
        _texts = [NSArray arrayWithObjects:
                  @"Nine passwords is enough\nfor your security!",
                  @"Set your password here",
                  @"Drag to remove",
                  nil];
    }
    return _texts;
}

- (NSArray *)images {
    if (!_images) {
        UIGraphicsBeginImageContext(CGSizeMake(300.0, 300.0));
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextFillRect(context, CGRectMake(0.0, 0.0, 300.0, 300.0));
        UIImage *help1 = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];

        CGContextSetRGBFillColor(context, 1.0, 0.0, 1.0, 1.0);
        CGContextFillRect(context, CGRectMake(0.0, 0.0, 300.0, 300.0));
        UIImage *help2 = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];

        CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
        CGContextFillRect(context, CGRectMake(0.0, 0.0, 300.0, 300.0));
        UIImage *help3 = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        
        UIGraphicsEndImageContext();

        _images = [NSArray arrayWithObjects:help1, help2, help3, nil];
    }
    return _images;
}

- (UIImageView *)frontImageView {
    if (!_frontImageView) {
        _frontImageView = [[UIImageView alloc] init];
        _frontImageView.alpha = 1.0;
        _frontImageView.image = [self.images objectAtIndex:0];
        _frontImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _frontImageView;
}

- (UIImageView *)backImageView {
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.alpha = 0.0;
        _backImageView.image = [self.images objectAtIndex:1];
        _backImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _backImageView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _scrollView;
}

-(UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = self.texts.count;
        _pageControl.currentPage = 0;
        [_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pageControl;
}

@end
