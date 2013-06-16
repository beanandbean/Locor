//
//  PassoneTests.m
//  PassoneTests
//
//  Created by wangyw on 6/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassDataManagerTests.h"

#import "CPHint.h"
#import "CPPassDataManager.h"
#import "CPPassword.h"

@interface CPPassDataManagerTests ()

@property (strong, nonatomic) CPPassDataManager *passDataManager;

@end

@implementation CPPassDataManagerTests

- (void)setUp {
    [super setUp];
    
    self.passDataManager = [CPPassDataManager defaultManager];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSetPasswordTextAtIndex {
    NSArray *passwordsText = [[NSArray alloc] initWithObjects:@"password1", @"password2", @"password3", nil];
    for (int index = 0; index < passwordsText.count; index++) {
        [self.passDataManager setPasswordText:[passwordsText objectAtIndex:index] red:1.0 green:1.0 blue:1.0 atIndex:index];
    }
    
    STAssertEquals((NSUInteger)9, self.passDataManager.passwords.count, @"");
    for (int index = 0; index < passwordsText.count; index++) {
        CPPassword *password = [self.passDataManager.passwords objectAtIndex:index];
        STAssertEquals([passwordsText objectAtIndex:index], password.text, @"");
    }
    
    // TODO: use variable for @"changed"
    [self.passDataManager setPasswordText:@"changed" red:1.0 green:1.0 blue:1.0 atIndex:0];
    
    STAssertEquals((NSUInteger)9, self.passDataManager.passwords.count, @"");
    for (int index = 0; index < passwordsText.count; index++) {
        CPPassword *password = [self.passDataManager.passwords objectAtIndex:index];
        if (index) {
            STAssertEquals([passwordsText objectAtIndex:index], password.text, @"");
        } else {
            STAssertEquals(@"changed", password.text, @"");
        }
    }
}

@end
