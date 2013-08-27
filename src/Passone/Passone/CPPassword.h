//
//  CPPassword.h
//  Passone
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPMemo;

@interface CPPassword : NSManagedObject

@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSNumber *isUsed;
@property (nonatomic, retain) NSNumber *colorIndex;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSSet *memos;

- (UIColor *)color;
- (UIColor *)displayColor;
- (UIColor *)reversedColor;

- (NSString *)displayIcon;
- (NSString *)reversedIcon;

@end

@interface CPPassword (CoreDataGeneratedAccessors)

- (void)addMemosObject:(CPMemo *)value;
- (void)removeMemosObject:(CPMemo *)value;
- (void)addMemos:(NSSet *)values;
- (void)removeMemos:(NSSet *)values;

@end
