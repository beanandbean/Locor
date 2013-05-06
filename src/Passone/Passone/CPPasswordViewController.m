//
//  CPPasswordViewController.m
//  Passone
//
//  Created by wangyw on 5/6/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPasswordViewController.h"

@interface CPPasswordViewController ()

@end

@implementation CPPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [self performSegueWithIdentifier:@"CPLoginViewController" sender:self];
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
