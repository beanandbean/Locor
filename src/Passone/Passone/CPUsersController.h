//
//  CPUsersController.h
//  Passone
//
//  Created by wangyw on 5/11/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPUsersController : NSObject

- (NSString *)userAtIndex:(NSUInteger)index;

- (NSString *)passwordAtIndex:(NSUInteger)index;

- (void)setUser:(NSString *)user password:(NSString *)password atIndex:(NSUInteger)index;

- (void)removeUserAtIndex:(NSUInteger)index;

@end
