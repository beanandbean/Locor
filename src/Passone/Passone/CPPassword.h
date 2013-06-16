//
//  CPPassword.h
//  Passone
//
//  Created by wangyw on 6/14/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPHint;

@interface CPPassword : NSManagedObject

@property (strong, nonatomic) NSString *text;

@property (strong, nonatomic) NSNumber *index;

@property (strong, nonatomic) NSNumber *red;

@property (strong, nonatomic) NSNumber *green;

@property (strong, nonatomic) NSNumber *blue;

@property (strong, nonatomic) NSDate *date;

@property (strong, nonatomic) NSSet *hints;

@end

@interface CPPassword (HintsAccessors)

- (void)addHintsObject:(CPHint *)value;

- (void)removeHintsObject:(CPHint *)value;

- (void)addHints:(NSSet *)value;

- (void)removeHints:(NSSet *)value;

@end
