//
//  CPPassEditViewManager.h
//  Passone
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPPassEditViewManager : NSObject

@property (strong, nonatomic) IBOutlet UIView *passwordEditView;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (void)addPassEditViewInView:(UIView *)view forCell:(UIView *)cell inCells:(NSMutableArray *)cells;

@end
