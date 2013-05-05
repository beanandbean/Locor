//
//  CPLoginViewController.m
//  Passone
//
//  Created by wangyw on 4/30/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPLoginViewController.h"
#import "CPLoginView.h"

static const int WIDTH = 200;
static const int SPACE = 10;
static const int WHOLE = WIDTH*2+SPACE;

@interface CPLoginViewController ()

@property (nonatomic, strong) NSMutableArray *loginViews;

@end

@implementation CPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int hAttribute[] = {NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeLeft, NSLayoutAttributeRight};
    int vAttribute[] = {NSLayoutAttributeTop, NSLayoutAttributeTop, NSLayoutAttributeBottom, NSLayoutAttributeBottom};
    int hSign[] = {-1, 1, -1, 1};
    int vSign[] = {-1, -1, 1, 1};
    
    for (int i = 0; i < 4; i++) {
        CPLoginView *view = [[CPLoginView alloc] initWithSize:WIDTH];
        [self.loginViews addObject:view];
        [self.view addSubview:view];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                             attribute:hAttribute[i]
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                               constant:hSign[i] * (WIDTH + SPACE)]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                              attribute:vAttribute[i]
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:vSign[i] * (WIDTH + SPACE)]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
