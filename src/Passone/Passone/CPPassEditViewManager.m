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

#import "CPMemoCollectionViewManager.h"

#import "CPProcessManager.h"
#import "CPEditingPassCellProcess.h"

@interface CPPassEditViewManager ()

@property (weak, nonatomic) UIView *superView;
@property (weak, nonatomic) NSArray *passCells;

@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) CPMemoCollectionViewManager *memoCollectionViewManager;

@property (strong, nonatomic) NSArray *constraints;

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
    
    [CPProcessManager startProcess:[CPEditingPassCellProcess process] withPreparation:^{
        self.index = index;
        
        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
        self.view.backgroundColor = password.displayColor;
        
        if (password.isUsed.boolValue) {
            self.passwordTextField.text = password.text;
            self.passwordTextField.secureTextEntry = YES;
        } else {
            self.passwordTextField.text = @"";
            self.passwordTextField.secureTextEntry = NO;
            [self.passwordTextField becomeFirstResponder];
        }
        
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
        } completion:^(BOOL finished) {
            if (password.isUsed.boolValue) {
                self.memoCollectionViewManager.memos = [[password.memos sortedArrayUsingDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO], nil]] mutableCopy];
            } else {
                self.memoCollectionViewManager.memos = [[NSMutableArray alloc] init];
            }
            
            [self.memoCollectionViewManager.collectionView reloadData];
        }];
        // This animation is contained in previous one, not needing to use CPAppearanceManager's animation
        [UIView animateWithDuration:0.25 delay:0.25 options:0 animations:^{
            for (UIView *subView in self.view.subviews) {
                subView.alpha = 1.0;
            }
        } completion:nil];
    }];
}

- (void)hidePassEditView {
    [CPProcessManager stopProcess:[CPEditingPassCellProcess process] withPreparation:^{
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
            self.memoCollectionViewManager.memos = [[NSMutableArray alloc] init];
            
            [self.superView removeConstraints:self.constraints];
            [self.view removeFromSuperview];
            self.index = -1;
        }];
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
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.backgroundColor = [UIColor whiteColor];
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField.delegate = self;
        
        _view = [[UIView alloc] init];
        _view.translatesAutoresizingMaskIntoConstraints = NO;
        [_view addSubview:_passwordTextField];
        [_view addConstraints:[[NSArray alloc] initWithObjects:
                               [NSLayoutConstraint constraintWithItem:_passwordTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0],
                               [NSLayoutConstraint constraintWithItem:_passwordTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0],
                               [NSLayoutConstraint constraintWithItem:_passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0],
                               nil]];
        
        UIView *memosView = [[UIView alloc] init];
        memosView.translatesAutoresizingMaskIntoConstraints = NO;
        [_view addSubview:memosView];
        [_view addConstraints:[[NSArray alloc] initWithObjects:
                               [NSLayoutConstraint constraintWithItem:memosView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:memosView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_passwordTextField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0],
                               [NSLayoutConstraint constraintWithItem:memosView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:memosView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                               nil]];
        
        _memoCollectionViewManager = [[CPMemoCollectionViewManager alloc] initWithSuperview:memosView];
    }
    return _view;
}

- (NSArray *)constraints {
    if (!_constraints) {
        _constraints = [[NSArray alloc] init];
    }
    return _constraints;
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
    }
}

@end
