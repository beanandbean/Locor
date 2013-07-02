//
//  CPPassEditViewManager.h
//  Passone
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPPassEditViewManager : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) NSInteger index;

@property (strong, nonatomic) IBOutlet UIView *passwordEditView;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UITableView *memosTableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *hintEditorCell;

- (id)initWithSuperView:(UIView *)superView cells:(NSArray *)cells;

- (void)showPassEditViewForCellAtIndex:(NSUInteger)index;

- (void)hidePassEditView;

- (void)setPassword;

- (IBAction)addMemo:(id)sender;

@end
