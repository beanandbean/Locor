//
//  CPUsersController.m
//  Passone
//
//  Created by wangyw on 5/11/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPUsersController.h"

@interface CPUsersController ()

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) NSMutableArray *users;

@end

@implementation CPUsersController

static const int MAX_USER_NUMBER = 4;

- (NSString *)filePath {
    if (!_filePath) {
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _filePath = [documents stringByAppendingPathComponent:@"users.plist"];
    }
    return _filePath;
}

- (NSMutableArray *)users {
    if (!_users) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
            _users = [NSMutableArray arrayWithContentsOfFile:self.filePath];
        } else {
            _users = [[NSMutableArray alloc] initWithCapacity:MAX_USER_NUMBER];
            for (int i = 0; i < MAX_USER_NUMBER; i++) {
                [_users addObject:[NSDictionary dictionary]];
            }
            [_users writeToFile:self.filePath atomically:YES];
        }
    }
    return _users;
}

static const NSString *KEY_USER = @"user";
static const NSString *KEY_PASSWORD = @"password";

- (NSString *)userAtIndex:(NSUInteger)index {
    NSDictionary *dictionary = [self.users objectAtIndex:index];
    return [dictionary objectForKey:KEY_USER];
}

- (NSString *)passwordAtIndex:(NSUInteger)index {
    NSDictionary *dictionary = [self.users objectAtIndex:index];
    return [dictionary objectForKey:KEY_PASSWORD];
}

- (void)setUser:(NSString *)user password:(NSString *)password atIndex:(NSUInteger)index {
    [self.users replaceObjectAtIndex:index withObject:[[NSDictionary alloc] initWithObjectsAndKeys:user, KEY_USER, password, KEY_PASSWORD, nil]];
    [_users writeToFile:self.filePath atomically:YES];
}

- (void)removeUserAtIndex:(NSUInteger)index {
    [self.users replaceObjectAtIndex:index withObject:[NSNull null]];
    [_users writeToFile:self.filePath atomically:YES];
}

@end
