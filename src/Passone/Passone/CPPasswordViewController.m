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

static NSString *LOGIN_VIEW_CONTROLLER_SEGUE_NAME = @"CPLoginViewController";

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [self performSegueWithIdentifier:LOGIN_VIEW_CONTROLLER_SEGUE_NAME sender:self];
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:LOGIN_VIEW_CONTROLLER_SEGUE_NAME]) {
        ((CPLoginViewController *)segue.destinationViewController).delegate = self;
    }
}

#pragma mark - CPLoginViewControllerDelegate implement

- (void)user:(NSString *)user loginFromLoginViewController:(CPLoginViewController *)loginViewController {
    self.userName.text = user;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
