//
//  CPLoginViewController.m
//  Passone
//
//  Created by wangyw on 4/30/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPLoginViewController.h"
#import "CPUsersController.h"

static const int SPACE = 10;

@interface CPLoginViewController ()

@property (strong, nonatomic) CPUsersController *users;

@property (strong, nonatomic) NSMutableArray *loginViews;

@end

@implementation CPLoginViewController

- (CPUsersController *)users {
    if (!_users) {
        _users = [[CPUsersController alloc] init];
    }
    return _users;
}

- (NSMutableArray *)loginViews {
    if (!_loginViews) {
        _loginViews = [[NSMutableArray alloc] init];
    }
    return _loginViews;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int hAttribute[] = {NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeLeft, NSLayoutAttributeRight};
    int vAttribute[] = {NSLayoutAttributeTop, NSLayoutAttributeTop, NSLayoutAttributeBottom, NSLayoutAttributeBottom};
    int hSign[] = {-1, 1, -1, 1};
    int vSign[] = {-1, -1, 1, 1};
    
    CGFloat width = fminf(self.view.frame.size.width, self.view.frame.size.height) / 2 - SPACE * 3;
    if (width > 200.0) {
        width = 200.0;
    }
    for (int i = 0; i < 4; i++) {
        CPLoginView *view = [[CPLoginView alloc] initWithSmallSize:width largeSize:(width + SPACE) * 2 user:[self.users userAtIndex:i] password:[self.users passwordAtIndex:i]];
        view.loginViewDelegate = self;
        [self.loginViews addObject:view];
        [self.view addSubview:view];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:hAttribute[i] relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:hSign[i] * (width + SPACE)]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:vAttribute[i] relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:vSign[i] * (width + SPACE)]];
    }

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBy:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tappedBy:(UITapGestureRecognizer *)tapGuesture {
    for (CPLoginView *view in self.loginViews) {
        [view shrink];
    }
}

#pragma mark - CPLoginViewDelgate implement

- (void)addUser:(NSString *)user password:(NSString *)password fromLoginView:(CPLoginView *)loginView {
    NSUInteger index = 0;
    for (CPLoginView *view in self.loginViews) {
        if (view == loginView) {
            [self.users setUser:user password:password atIndex:index];
            [view shrink];
            break;
        }
        index++;
    }
}

- (void)user:(NSString *)user loginFromLoginView:(CPLoginView *)loginView {
    [self.delegate user:user loginFromLoginViewController:self];
}

@end
