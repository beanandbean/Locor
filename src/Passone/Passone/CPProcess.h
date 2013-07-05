//
//  CPProcess.h
//  Passone
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPProcess <NSObject>

+ (id<CPProcess>)process;
- (bool)allowSubprocess:(id<CPProcess>)process;

@end
