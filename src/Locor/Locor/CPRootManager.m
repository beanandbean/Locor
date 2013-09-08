//
//  CPRootManager.m
//  Locor
//
//  Created by wangyw on 9/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRootManager.h"

#import "CPHelpManager.h"
#import "CPMainViewManager.h"

@interface CPRootManager ()

@property (strong, nonatomic) CPHelpManager *helpManager;
@property (strong, nonatomic) CPMainViewManager *mainViewManager;

//@property (strong, nonatomic) CPMainPasswordManager *mainPasswordManager;
 
@end

@implementation CPRootManager

- (void)loadAnimated:(BOOL)animated {
    NSAssert(self.superview, @"");
    NSAssert(!self.helpManager, @"");
    
    [super loadAnimated:animated];
    
    self.helpManager = [[CPHelpManager alloc] initWithSupermanager:self andSuperview:self.superview];
    [self.helpManager loadAnimated:animated];
}

- (void)submanagerDidUnload:(CPViewManager *)submanager {
    if (submanager == self.helpManager) {
        self.helpManager = nil;
        self.mainViewManager = [[CPMainViewManager alloc] initWithSupermanager:self andSuperview:self.superview];
        [self.mainViewManager loadAnimated:YES];
    }
}

@end
