//
//  CPHelperMacros.h
//  Locor
//
//  Created by wangsw on 9/13/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#ifndef _HELPER_MACROS
#define _HELPER_MACROS

#define CSTR_TO_OBJC(str) /* Using ASCII for string encoding */ \
    [NSString stringWithCString:str encoding:NSASCIIStringEncoding]

#define CURRENT_ORIENTATION \
    ([UIApplication sharedApplication].statusBarOrientation)

#define DELAY_BLOCK(delay, block) /* Avoid comma in 'block' because it will break the macro */ \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block)

#define DEVICE_RELATED_OBJ(phone, pad) \
    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? phone : pad)

#define DEVICE_RELATED_PNG(name) /* The acceptable way of naming files is to call them 'some_pic.png' & 'some_pic_ipad.png' */ \
    [name stringByAppendingFormat:@"%@.png", DEVICE_RELATED_OBJ(@"", @"_ipad")]

#define ORIENTATION_RELATED_OBJ(landscape, portrait) \
    SPECIFIED_ORIENTATION_RELATED_OBJ(CURRENT_ORIENTATION, landscape, portrait)

#define SPECIFIED_ORIENTATION_RELATED_OBJ(orientation, landscape, portrait) \
    (UIInterfaceOrientationIsLandscape(orientation) ? landscape : portrait)

#endif
