//
//  CPPassDataManager.h
//  Passone
//
//  Created by wangyw on 6/13/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPPassDataManager : NSObject

@property (strong, nonatomic) NSArray *passwords;

+ (CPPassDataManager *)defaultManager;

- (NSURL *)applicationDocumentsDirectory;

- (void)saveContext;

- (void)setPasswordText:(NSString *)text atIndex:(NSInteger)index;

- (void)addHintText:(NSString *)text intoIndex:(NSInteger)index;

@end