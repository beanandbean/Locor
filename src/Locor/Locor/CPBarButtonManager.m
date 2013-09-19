//
//  CPBarButtonManager.m
//  Locor
//
//  Created by wangsw on 9/4/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPBarButtonManager.h"

static UIButton *g_barButton;
static NSMutableArray *g_barButtonTitles, *g_barButtonTargets, *g_barButtonActions, *g_barButtonControlEvents;

@implementation CPBarButtonManager

+ (void)initializeWithBarButton:(UIButton *)button {
    g_barButton = button;
    
    g_barButtonTitles = [NSMutableArray array];
    g_barButtonTargets = [NSMutableArray array];
    g_barButtonActions = [NSMutableArray array];
    g_barButtonControlEvents = [NSMutableArray array];
}

+ (void)pushBarButtonStateWithTitle:(NSString *)title target:(id)target action:(SEL)action andControlEvents:(UIControlEvents)controlEvents {
    if (g_barButtonTitles.count) {
        [g_barButton removeTarget:[g_barButtonTargets lastObject] action:((NSValue *)[g_barButtonActions lastObject]).pointerValue forControlEvents:((NSNumber *)[g_barButtonControlEvents lastObject]).intValue];
    }
    
    [g_barButton setTitle:title forState:UIControlStateNormal];
    
    [g_barButton addTarget:target action:action forControlEvents:controlEvents];
    
    [g_barButtonTitles addObject:title];
    [g_barButtonTargets addObject:target];
    [g_barButtonActions addObject:[NSValue valueWithPointer:action]];
    [g_barButtonControlEvents addObject:[NSNumber numberWithInt:controlEvents]];
}

+ (void)popBarButtonState {
    [g_barButton removeTarget:[g_barButtonTargets lastObject] action:((NSValue *)[g_barButtonActions lastObject]).pointerValue forControlEvents:((NSNumber *)[g_barButtonControlEvents lastObject]).intValue];

    [g_barButtonTitles removeLastObject];
    [g_barButtonTargets removeLastObject];
    [g_barButtonActions removeLastObject];
    [g_barButtonControlEvents removeLastObject];
    
    if (g_barButtonTitles.count) {
        [g_barButton setTitle:[g_barButtonTitles lastObject] forState:UIControlStateNormal];
        [g_barButton addTarget:[g_barButtonTargets lastObject] action:((NSValue *)[g_barButtonActions lastObject]).pointerValue forControlEvents:((NSNumber *)[g_barButtonControlEvents lastObject]).intValue];
    } else {
        [g_barButton setTitle:@"" forState:UIControlStateNormal];
    }
}

@end
