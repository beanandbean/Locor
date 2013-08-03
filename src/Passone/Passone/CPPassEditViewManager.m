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

@property (weak, nonatomic) UIView *superView;
@property (weak, nonatomic) NSArray *passCells;

@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UITableView *memosTableView;

@property (strong, nonatomic) NSArray *constraints;

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

- (void)showPassEditViewForCellAtIndex:(NSUInteger)index {
    NSAssert(self.index == -1, @"");
    self.index = index;
    
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    self.view.backgroundColor = password.displayColor;
    
    if (password.isUsed.boolValue) {
        self.passwordTextField.text = password.text;
        self.passwordTextField.secureTextEntry = YES;
        self.memos = [[NSMutableArray alloc] initWithArray:[password.memos sortedArrayUsingDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO], nil]]];
    } else {
        self.passwordTextField.text = @"";
        self.passwordTextField.secureTextEntry = NO;
        [self.passwordTextField becomeFirstResponder];
        self.memos = [[NSMutableArray alloc] init];
    }
    
    [self.memosTableView reloadData];
    
    for (UIView *subview in self.view.subviews) {
        subview.alpha = 0.0;
    }
    [self.superView addSubview:self.view];
    
    UIView *cell = [self.passCells objectAtIndex:self.index];
    
    // align with cell
    [self.superView removeConstraints:self.constraints];
    self.constraints = [[NSArray alloc] initWithObjects:
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                        nil];
    [self.superView addConstraints:self.constraints];
    [self.superView layoutIfNeeded];
    
    // enlarge to align with all cells
    [self.superView removeConstraints:self.constraints];
    
    UIView *leftTopCell = [self.passCells objectAtIndex:0];
    UIView *rightBottomCell = [self.passCells lastObject];
    self.constraints = [[NSArray alloc] initWithObjects:
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftTopCell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:leftTopCell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:rightBottomCell attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:rightBottomCell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                        nil];
    [self.superView addConstraints:self.constraints];
    [CPAppearanceManager animateWithDuration:0.5 animations:^{
        [self.superView layoutIfNeeded];
        self.view.backgroundColor = password.color;
    }];
    // This animation is contained in previous one, not needing to use CPAppearanceManager's animation
    [UIView animateWithDuration:0.25 delay:0.25 options:0 animations:^{
        for (UIView *subView in self.view.subviews) {
            subView.alpha = 1.0;
        }
    } completion:nil];
}

- (void)hidePassEditView {
    UIView *cell = [self.passCells objectAtIndex:self.index];
    [self.superView removeConstraints:self.constraints];
    self.constraints = [[NSArray alloc] initWithObjects:
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                        nil];
    [self.superView addConstraints:self.constraints];
    
    // This animation is contained in next one, not needing to use CPAppearanceManager's animation
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView *subview in self.view.subviews) {
            subview.alpha = 0.0;
        }
    }];
    [CPAppearanceManager animateWithDuration:0.5 animations:^{
        [self.superView layoutIfNeeded];
        self.view.backgroundColor = cell.backgroundColor;
    } completion:^(BOOL finished) {
        [self.superView removeConstraints:self.constraints];
        [self.view removeFromSuperview];
        self.index = -1;
    }];
}

- (void)setPassword {
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    if (self.passwordTextField.text && ![self.passwordTextField.text isEqualToString:password.text]) {
        [[CPPassDataManager defaultManager] setPasswordText:self.passwordTextField.text atIndex:self.index];
    }
}

#pragma mark - Property methods

- (UIView *)view {
    if (!_view) {
        _view = [[UIView alloc] init];
        _view.translatesAutoresizingMaskIntoConstraints = NO;
        [_view addSubview:self.passwordTextField];
        [_view addConstraints:[[NSArray alloc] initWithObjects:
                               [NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0],
                               [NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0],
                               [NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0],
                               nil]];
        
        [_view addSubview:self.memosTableView];
        [_view addConstraints:[[NSArray alloc] initWithObjects:
                               [NSLayoutConstraint constraintWithItem:self.memosTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0],
                               [NSLayoutConstraint constraintWithItem:self.memosTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0],
                               [NSLayoutConstraint constraintWithItem:self.memosTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0],
                               [NSLayoutConstraint constraintWithItem:self.memosTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0],
                               nil]];
    }
    return _view;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        // TODO: Set the return key type of text field in Pass Edit View to done.
        // The following line doesn't work.
        // _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.backgroundColor = [UIColor whiteColor];
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField.delegate = self;
    }
    return _passwordTextField;
}

- (UITableView *)memosTableView {
    if (!_memosTableView) {
        _memosTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _memosTableView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _memosTableView;
}

- (NSArray *)constraints {
    if (!_constraints) {
        _constraints = [[NSArray alloc] init];
    }
    return _constraints;
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
        //cell = self.hintEditorCell;
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
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        self.passwordTextField.secureTextEntry = NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        self.passwordTextField.secureTextEntry = YES;
    } else if (self.editingNewHint) {
        NSString *memoText = textField.text;
        if (memoText && ![memoText isEqualToString:@""]) {
            CPMemo *memo = [[CPPassDataManager defaultManager] addMemoText:memoText intoIndex:self.index];
            [self.memos insertObject:memo atIndex:0];
        }
        self.editingNewHint = NO;
        // [self.memosTableView reloadData];
    }
}

@end
