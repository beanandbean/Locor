//
//  CPBarButtonManager.m
//  Locor
//
//  Created by wangsw on 9/4/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPBarButtonManager.h"

static UIButton *barButton;
static NSMutableArray *barButtonTitles, *barButtonTargets, *barButtonActions, *barButtonControlEvents;

@implementation CPBarButtonManager

+ (void)initializeWithBarButton:(UIButton *)button {
    barButton = button;
    
    barButtonTitles = [NSMutableArray array];
    barButtonTargets = [NSMutableArray array];
    barButtonActions = [NSMutableArray array];
    barButtonControlEvents = [NSMutableArray array];
}

+ (void)pushBarButtonStateWithTitle:(NSString *)title target:(id)target action:(SEL)action andControlEvents:(UIControlEvents)controlEvents {
    if (barButtonTitles.count) {
        [barButton removeTarget:[barButtonTargets lastObject] action:((NSValue *)[barButtonActions lastObject]).pointerValue forControlEvents:((NSNumber *)[barButtonControlEvents lastObject]).intValue];
    }
    
    [barButton setTitle:title forState:UIControlStateNormal];
    
    [barButton addTarget:target action:action forControlEvents:controlEvents];
    
    [barButtonTitles addObject:title];
    [barButtonTargets addObject:target];
    [barButtonActions addObject:[NSValue valueWithPointer:action]];
    [barButtonControlEvents addObject:[NSNumber numberWithInt:controlEvents]];
}

+ (void)popBarButtonState {
    [barButton removeTarget:[barButtonTargets lastObject] action:((NSValue *)[barButtonActions lastObject]).pointerValue forControlEvents:((NSNumber *)[barButtonControlEvents lastObject]).intValue];

    [barButtonTitles removeLastObject];
    [barButtonTargets removeLastObject];
    [barButtonActions removeLastObject];
    [barButtonControlEvents removeLastObject];
    
    if (barButtonTitles.count) {
        [barButton setTitle:[barButtonTitles lastObject] forState:UIControlStateNormal];
        [barButton addTarget:[barButtonTargets lastObject] action:((NSValue *)[barButtonActions lastObject]).pointerValue forControlEvents:((NSNumber *)[barButtonControlEvents lastObject]).intValue];
    } else {
        [barButton setTitle:@"" forState:UIControlStateNormal];
    }
}

@end
