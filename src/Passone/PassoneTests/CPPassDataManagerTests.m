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
    [self.passDataManager removeAllPasswords];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSetPasswordTextAtIndex {
    NSArray *passwordsText = [[NSArray alloc] initWithObjects:@"password1", @"password2", @"password3", nil];
    for (int index = 0; index < passwordsText.count; index++) {
        [self.passDataManager setPasswordText:[passwordsText objectAtIndex:index] atIndex:index];
    }
    
    STAssertEquals(passwordsText.count, self.passDataManager.passwords.count, @"");
    for (CPPassword *password in self.passDataManager.passwords) {
        STAssertEquals([passwordsText objectAtIndex:password.index.intValue], password.text, @"");
    }
    
    // TODO: use variable for @"changed"
    [self.passDataManager setPasswordText:@"changed" atIndex:0];
    
    STAssertEquals(passwordsText.count, self.passDataManager.passwords.count, @"");
    for (CPPassword *password in self.passDataManager.passwords) {
        if (password.index.intValue) {
            STAssertEquals([passwordsText objectAtIndex:password.index.intValue], password.text, @"");
        } else {
            STAssertEquals(@"changed", password.text, @"");
        }
    }
}

@end
