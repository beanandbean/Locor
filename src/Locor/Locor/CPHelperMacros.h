//
//  CPHelperMacros.h
//  Locor
//
//  Created by wangsw on 9/13/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#ifndef _HELPER_MACROS
#define _HELPER_MACROS

#define CSTR_TO_OBJC(str) \
    [NSString stringWithCString:str encoding:NSASCIIStringEncoding]

#define DELAY_BLOCK(delay, block) \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block)

#define DEVICE_RELATED_OBJ(phone, pad) \
    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? phone : pad)

#define DEVICE_RELATED_PNG(name) \
    [name stringByAppendingFormat:@"%@.png", DEVICE_RELATED_OBJ(@"", @"_ipad")]

#endif
