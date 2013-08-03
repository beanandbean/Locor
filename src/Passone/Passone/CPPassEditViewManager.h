//
//  CPPassEditViewManager.h
//  Passone
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPPassEditViewManager : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) NSInteger index;

- (id)initWithSuperView:(UIView *)superView cells:(NSArray *)cells;

- (void)showPassEditViewForCellAtIndex:(NSUInteger)index;

- (void)hidePassEditView;

- (void)setPassword;

@end
