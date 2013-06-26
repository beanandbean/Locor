//
//  CPPassword.h
//  Passone
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPHint;

@interface CPPassword : NSManagedObject

@property (nonatomic, retain) NSNumber *colorBlue;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSNumber *colorGreen;
@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) NSNumber *colorRed;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSNumber *isUsed;
@property (nonatomic, retain) NSSet *hints;
@end

@interface CPPassword (CoreDataGeneratedAccessors)

- (void)addHintsObject:(CPHint *)value;
- (void)removeHintsObject:(CPHint *)value;
- (void)addHints:(NSSet *)values;
- (void)removeHints:(NSSet *)values;

@end
