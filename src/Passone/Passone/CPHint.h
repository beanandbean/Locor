//
//  CPHint.h
//  Passone
//
//  Created by wangyw on 6/14/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPPassword;

@interface CPHint : NSManagedObject

@property (nonatomic, retain) NSString * text;

@property (nonatomic, retain) NSDate * date;

@property (nonatomic, retain) CPPassword *password;

@end
