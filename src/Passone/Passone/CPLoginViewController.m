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
static const int SPACE = 20;
static const int WHOLE = WIDTH*2+SPACE;

@interface CPLoginViewController ()

@property (nonatomic, strong) NSDictionary *views;

@end

@implementation CPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIView *lt = [[UIView alloc] init];
    [lt setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:lt];
    UIView *rb = [[UIView alloc] init];
    [rb setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:rb];
    UIView *c = [[UIView alloc] init];
    [c setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:c];

    CPLoginView *loginView1 = [[CPLoginView alloc] init];
    [self.view addSubview:loginView1];
    CPLoginView *loginView2 = [[CPLoginView alloc] init];
    [self.view addSubview:loginView2];
    CPLoginView *loginView3 = [[CPLoginView alloc] init];
    [self.view addSubview:loginView3];
    CPLoginView *loginView4 = [[CPLoginView alloc] init];
    [self.view addSubview:loginView4];
    
    self.views = NSDictionaryOfVariableBindings(loginView1, loginView2, loginView3, loginView4, lt, rb, c);
    [self reloadConstraintsWithBigBlockIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadConstraintsWithBigBlockIndex:(int)block {
    NSNumber *width1 = [NSNumber numberWithInt:WIDTH];
    NSNumber *width2 = [NSNumber numberWithInt:WIDTH];
    NSNumber *width3 = [NSNumber numberWithInt:WIDTH];
    NSNumber *width4 = [NSNumber numberWithInt:WIDTH];
    NSNumber *space = [NSNumber numberWithInt:SPACE];
    NSNumber *whole = [NSNumber numberWithInt:WHOLE];
    
    UIView *frontView = nil;
    
    switch (block) {
        case 1:
            width1 = [NSNumber numberWithInt:WHOLE];
            frontView = [self.views objectForKey:@"loginView1"];
            break;
            
        case 2:
            width2 = [NSNumber numberWithInt:WHOLE];
            frontView = [self.views objectForKey:@"loginView2"];
            break;
            
        case 3:
            width3 = [NSNumber numberWithInt:WHOLE];
            frontView = [self.views objectForKey:@"loginView3"];
            break;
            
        case 4:
            width4 = [NSNumber numberWithInt:WHOLE];
            frontView = [self.views objectForKey:@"loginView4"];
            break;
            
        default:
            break;
    }
    
    if (frontView) {
        [self.view bringSubviewToFront:frontView];
    }

    NSDictionary *metrics = NSDictionaryOfVariableBindings(width1, width2, width3, width4, space, whole);
    
    [self.view removeConstraints:self.view.constraints];
    
    NSArray *constraintArray = [NSArray arrayWithObjects:@"H:|-[lt]-[c(==whole)]-[rb(==lt)]-|", @"H:|-[lt]-[loginView1(==width1)]", @"H:[loginView2(==width2)]-[rb]-|", @"H:|-[lt]-[loginView3(==width3)]", @"H:[loginView4(==width4)]-[rb]-|", @"V:|-[lt]-[c(==whole)]-[rb(==lt)]-|", @"V:|-[lt]-[loginView1(==width1)]", @"V:[loginView3(==width3)]-[rb]-|", @"V:|-[lt]-[loginView2(==width2)]", @"V:[loginView4(==width4)]-[rb]-|", nil];
    
    for (int i = 0; i < [constraintArray count]; i++) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:[constraintArray objectAtIndex:i] options:0 metrics:metrics views:self.views];
        [self.view addConstraints:constraints];
    }
    
    [self.view layoutIfNeeded];
}

@end
