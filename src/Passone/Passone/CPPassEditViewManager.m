//
//  CPPassEditViewManager.m
//  Passone
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditViewManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"
#import "CPMemo.h"

#import "CPAppearanceManager.h"

@interface CPPassEditViewManager ()

@property (strong, nonatomic) NSArray *constraints;

@property (weak, nonatomic) UIView *superView;

@property (weak, nonatomic) NSArray *passCells;

@property (strong, nonatomic) NSMutableArray *memos;

@property (nonatomic) BOOL editingNewHint;

@end

@implementation CPPassEditViewManager

- (id)initWithSuperView:(UIView *)superView cells:(NSArray *)cells {
    self = [super init];
    if (self) {
        self.index = -1;
        self.superView = superView;
        self.passCells = cells;
    }
    return self;
}

- (UIView *)passwordEditView {
    if (!_passwordEditView) {
        [[NSBundle mainBundle] loadNibNamed:@"CPPassEditView" owner:self options:nil];
        _passwordEditView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _passwordEditView;
}

- (NSArray *)constraints {
    if (!_constraints) {
        _constraints = [[NSArray alloc] init];
    }
    return _constraints;
}

- (void)showPassEditViewForCellAtIndex:(NSUInteger)index {
    NSAssert(self.index == -1, @"");
    
    self.index = index;
    
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    self.passwordEditView.backgroundColor = password.displayColor;
    
    if (password.isUsed.boolValue) {
        self.passwordTextField.text = password.text;
        self.memos = [[NSMutableArray alloc] initWithArray:[password.memos sortedArrayUsingDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO], nil]]];
    } else {
        self.passwordTextField.text = @"";
        [self.passwordTextField becomeFirstResponder];
        self.memos = [[NSMutableArray alloc] init];
    }
    
    // TODO: When showing pass edit view, if the cell has been set, hide the password for security.
	
    [self.memosTableView reloadData];
    
    for (UIView *subview in self.passwordEditView.subviews) {
        subview.alpha = 0.0;
    }
    [self.superView addSubview:self.passwordEditView];
    
    UIView *cell = [self.passCells objectAtIndex:self.index];
    
    // align with cell
    [self.superView removeConstraints:self.constraints];
    self.constraints = [[NSArray alloc] initWithObjects:
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                        nil];
    [self.superView addConstraints:self.constraints];
    [self.superView layoutIfNeeded];
    
    // enlarge to align with all cells
    [self.superView removeConstraints:self.constraints];
    
    UIView *leftTopCell = [self.passCells objectAtIndex:0];
    UIView *rightBottomCell = [self.passCells lastObject];
    self.constraints = [[NSArray alloc] initWithObjects:
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftTopCell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:leftTopCell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:rightBottomCell attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:rightBottomCell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                        nil];
    [self.superView addConstraints:self.constraints];
    [CPAppearanceManager animateWithDuration:0.5 animations:^{
        [self.superView layoutIfNeeded];
        self.passwordEditView.backgroundColor = password.color;
    }];
    sleep(0.25);
    // This animation is contained in previous one, not needing to use CPAppearanceManager's animation
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView *subView in self.passwordEditView.subviews) {
            subView.alpha = 1.0;
        }        
    }];
}

- (void)hidePassEditView {
    UIView *cell = [self.passCells objectAtIndex:self.index];
    [self.superView removeConstraints:self.constraints];
    self.constraints = [[NSArray alloc] initWithObjects:
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                        nil];
    [self.superView addConstraints:self.constraints];
    
    // This animation is contained in next one, not needing to use CPAppearanceManager's animation
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView *subview in self.passwordEditView.subviews) {
            subview.alpha = 0.0;
        }
    }];
    [CPAppearanceManager animateWithDuration:0.5 animations:^{
        [self.superView layoutIfNeeded];
        self.passwordEditView.backgroundColor = cell.backgroundColor;
    } completion:^(BOOL finished) {
        [self.superView removeConstraints:self.constraints];
        [self.passwordEditView removeFromSuperview];
        self.index = -1;
    }];
}

- (void)setPassword {
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    if (self.passwordTextField.text && ![self.passwordTextField.text isEqualToString:password.text]) {
        [[CPPassDataManager defaultManager] setPasswordText:self.passwordTextField.text atIndex:self.index];
    }
}

- (IBAction)addMemo:(id)sender {
    self.editingNewHint = YES;
    [self.memosTableView reloadData];
}

#pragma mark - UITableViewDataSource implement

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.memos.count;
    if (self.editingNewHint) {
        count++;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (self.editingNewHint && indexPath.row == 0) {
        cell = self.hintEditorCell;
    } else {
        static NSString *CellIdentifier = @"MemoCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        NSUInteger index = indexPath.row;
        if (self.editingNewHint) {
            index--;
        }
        CPMemo *hint = [self.memos objectAtIndex:index];
        cell.textLabel.text = hint.text;
    }
    return cell;
}

#pragma mark - UITextFieldDelegate implement

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.editingNewHint && textField != self.passwordTextField) {
        NSString *memoText = textField.text;
        if (memoText && ![memoText isEqualToString:@""]) {
            CPMemo *memo = [[CPPassDataManager defaultManager] addMemoText:memoText intoIndex:self.index];
            [self.memos insertObject:memo atIndex:0];
        }
        self.editingNewHint = NO;
        [self.memosTableView reloadData];
    }
    return YES;
}

@end
