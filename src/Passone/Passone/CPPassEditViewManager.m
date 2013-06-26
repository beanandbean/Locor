//
//  CPPassEditViewManager.m
//  Passone
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditViewManager.h"

#import "CPHint.h"
#import "CPPassDataManager.h"
#import "CPPassword.h"

@interface CPPassEditViewManager ()

@property (strong, nonatomic) NSArray *constraints;

@property (weak, nonatomic) UIView *superView;

@property (weak, nonatomic) NSArray *passCells;

@property (strong, nonatomic) NSMutableArray *hints;

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
    
    CPPassword *password = [[CPPassDataManager defaultManager].passwords objectAtIndex:self.index];
    self.passwordEditView.backgroundColor = [[UIColor alloc] initWithRed:password.colorRed.floatValue green:password.colorGreen.floatValue blue:password.colorBlue.floatValue alpha:1.0];
    self.passwordTextField.text = password.text;
	
	self.hints = [[NSMutableArray alloc] initWithArray:[password.hints sortedArrayUsingDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO], nil]]];

    [self.hintsTableView reloadData];
    
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
    [UIView animateWithDuration:0.5 animations:^{
        [self.superView layoutIfNeeded];
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
    [UIView animateWithDuration:0.5 animations:^{
        [self.superView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.superView removeConstraints:self.constraints];
        [self.passwordEditView removeFromSuperview];
        self.index = -1;
    }];
}

- (void)setPassword {
    if (self.passwordTextField.text && ![self.passwordTextField.text isEqualToString:@""]) {
        [[CPPassDataManager defaultManager] setPasswordText:self.passwordTextField.text atIndex:self.index];
    }
}

- (IBAction)addHint:(id)sender {
    self.editingNewHint = YES;
    [self.hintsTableView reloadData];
}

#pragma mark - UITableViewDataSource implement

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.hints.count;
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
        static NSString *CellIdentifier = @"HintCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        NSUInteger index = indexPath.row;
        if (self.editingNewHint) {
            index--;
        }
        CPHint *hint = [self.hints objectAtIndex:index];
        cell.textLabel.text = hint.text;
    }
    return cell;
}

#pragma mark - UITextFieldDelegate implement

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.editingNewHint && textField != self.passwordTextField) {
        NSString *hintText = textField.text;
        if (hintText && ![hintText isEqualToString:@""]) {
            CPHint * hint = [[CPPassDataManager defaultManager] addHintText:hintText intoIndex:self.index];
            [self.hints insertObject:hint atIndex:0];
        }
        self.editingNewHint = NO;
        [self.hintsTableView reloadData];
    }
    return YES;
}

@end
