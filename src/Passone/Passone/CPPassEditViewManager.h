//
//  CPPassEditViewManager.h
//  Passone
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPPassEditViewManager : NSObject <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *passwordEditView;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (void)addPassEditViewInView:(UIView *)view index:(NSUInteger)index inCells:(NSArray *)cells;

- (void)removePassEditViewFromView:(UIView *)view index:(NSUInteger)index inCells:(NSArray *)cells;

- (void)setPasswordForIndex:(NSUInteger)index;

@end