//
//  CPPassEditViewManager.m
//  Passone
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CPPassEditViewManager.h"

#import "CPPassoneConfig.h"

#import "CPPassGridManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"
#import "CPMemo.h"

#import "CPAppearanceManager.h"

#import "CPSingleViewMemoCollectionViewManager.h"

#import "CPProcessManager.h"
#import "CPEditingPassCellProcess.h"

@interface CPPassEditViewManager ()

@property (weak, nonatomic) UIView *superView;
@property (weak, nonatomic) UIImageView *superCoverImage;
@property (weak, nonatomic) NSArray *passCells;

@property (strong, nonatomic) UIView *outerView;
@property (strong, nonatomic) NSArray *outerViewConstraints;

@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) CPSingleViewMemoCollectionViewManager *memoCollectionViewManager;

@property (strong, nonatomic) NSArray *constraints;

@end

@implementation CPPassEditViewManager

- (id)initWithSuperView:(UIView *)superView coverImage:(UIImageView *)coverImage andCells:(NSArray *)cells {
    self = [super init];
    if (self) {
        self.index = -1;
        self.superView = superView;
        self.superCoverImage = coverImage;
        self.passCells = cells;
    }
    return self;
}

- (void)showPassEditViewForCellAtIndex:(NSUInteger)index {
    NSAssert(self.index == -1, @"Already have a pass editing view open when opening one!");
    
    [CPProcessManager startProcess:EDITING_PASS_CELL_PROCESS withPreparation:^{
        self.index = index;
        
        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
        
        // Create outer view
        
        self.outerView = [[UIView alloc] init];
        self.outerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.superView addSubview:self.outerView];
        
        self.outerViewConstraints = [CPAppearanceManager constraintsForView:self.outerView toEqualToView:self.superView];
        [self.superView addConstraints:self.outerViewConstraints];
        
        // Create back and front layers
        
        UIView *backLayer = [[UIView alloc] init];
        backLayer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.outerView addSubview:backLayer];
        [self.outerView addConstraints:[CPAppearanceManager constraintsForView:backLayer toEqualToView:self.outerView]];
        
        UIImageView *coverImage = [[UIImageView alloc] initWithImage:self.superCoverImage.image];
        coverImage.translatesAutoresizingMaskIntoConstraints = NO;
        coverImage.transform = self.superCoverImage.transform;
        coverImage.alpha = self.superCoverImage.alpha;
        [self.outerView addSubview:coverImage];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:coverImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superCoverImage attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:coverImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superCoverImage attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        UIView *frontLayer = [[UIView alloc] init];
        frontLayer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.outerView addSubview:frontLayer];
        [self.outerView addConstraints:[CPAppearanceManager constraintsForView:frontLayer toEqualToView:self.outerView]];
        
        // Create top cell
        
        UIView *cellBackground = [[UIView alloc] init];
        cellBackground.hidden = YES;
        cellBackground.backgroundColor = password.color;
        cellBackground.translatesAutoresizingMaskIntoConstraints = NO;
        [backLayer addSubview:cellBackground];
        
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:cellBackground attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:cellBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:cellBackground attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self.passCells objectAtIndex:index] attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:cellBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:[self.passCells objectAtIndex:index] attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        
        UIImageView *cellIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:password.trueIcon]];
        cellIcon.alpha = 0.0;
        cellIcon.translatesAutoresizingMaskIntoConstraints = NO;
        [frontLayer addSubview:cellIcon];
        
        [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:cellIcon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cellBackground attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:cellIcon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cellBackground attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        NSArray *draggingCellDetail = [CPPassGridManager makeDraggingCellFromCell:[self.passCells objectAtIndex:index] onView:self.superView withCover:self.superCoverImage];
        ((CPPassCell *)[self.passCells objectAtIndex:index]).alpha = 0.0;
        
        // Create Password Text Field
        
        UIView *textFieldBackground = [[UIView alloc] init];
        textFieldBackground.backgroundColor = [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        textFieldBackground.translatesAutoresizingMaskIntoConstraints = NO;
        [backLayer addSubview:textFieldBackground];
        
        NSLayoutConstraint *textFieldBackgroundRightConstraint = [NSLayoutConstraint constraintWithItem:textFieldBackground attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
        [backLayer addConstraint:textFieldBackgroundRightConstraint];
        
        [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:textFieldBackground attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:backLayer attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:textFieldBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cellBackground attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:textFieldBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:MEMO_CELL_HEIGHT]];
        
        self.passwordTextField = [[UITextField alloc] init];
        self.passwordTextField.returnKeyType = UIReturnKeyDone;
        self.passwordTextField.textColor = [UIColor whiteColor];
        self.passwordTextField.font = [UIFont boldSystemFontOfSize:24.0];
        self.passwordTextField.backgroundColor = [UIColor clearColor];
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        self.passwordTextField.delegate = self;
        self.passwordTextField.alpha = 0.0;
        
        if (password.isUsed.boolValue) {
            self.passwordTextField.text = password.text;
            self.passwordTextField.secureTextEntry = YES;
        } else {
            self.passwordTextField.text = @"";
            self.passwordTextField.secureTextEntry = NO;
            [self.passwordTextField becomeFirstResponder];
        }
        
        [frontLayer addSubview:self.passwordTextField];
        
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationLessThanOrEqual toItem:textFieldBackground attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:textFieldBackground attribute:NSLayoutAttributeRight multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:textFieldBackground attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [self.superView layoutIfNeeded];
        
        [CPAppearanceManager animateWithDuration:0.4 animations:^{
            for (CPPassCell *cell in self.passCells) {
                if (cell.index != index) {
                    cell.alpha = 0.0;
                }
            }
        }];
        
        __block NSLayoutConstraint *draggingCellCenterXConstraint, *draggingCellTopConstraint;
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            [self.superView removeConstraint:[draggingCellDetail objectAtIndex:1]];
            [self.superView removeConstraint:[draggingCellDetail objectAtIndex:2]];
            
            draggingCellCenterXConstraint = [NSLayoutConstraint constraintWithItem:[draggingCellDetail objectAtIndex:0] attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
            [self.superView addConstraint:draggingCellCenterXConstraint];
            draggingCellTopConstraint = [NSLayoutConstraint constraintWithItem:[draggingCellDetail objectAtIndex:0] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE];
            [self.superView addConstraint:draggingCellTopConstraint];
            
            [self.superView layoutIfNeeded];
            ((UIView *)[draggingCellDetail objectAtIndex:0]).backgroundColor = password.color;
            
            if (!password.isUsed.boolValue) {
                ((UIView *)[draggingCellDetail objectAtIndex:5]).alpha = 0.0;
            }
        } completion:^(BOOL finished) {
            cellBackground.hidden = NO;
            
            if (password.isUsed.boolValue) {
                cellIcon.alpha = 1.0;
            }
            
            [self.superView removeConstraint:draggingCellTopConstraint];
            [self.superView removeConstraint:draggingCellCenterXConstraint];
            [self.superView removeConstraints:[draggingCellDetail objectAtIndex:3]];
            [self.superView removeConstraints:[draggingCellDetail objectAtIndex:4]];
            [(UIView *)[draggingCellDetail objectAtIndex:0] removeFromSuperview];
        }];
        
        [CPAppearanceManager animateWithDuration:0.4 delay:0.3 options:0 animations:^{
            [backLayer removeConstraint:textFieldBackgroundRightConstraint];
            [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:textFieldBackground attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:backLayer attribute:NSLayoutAttributeRight multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
            [backLayer layoutIfNeeded];
        } completion:nil];
        
        [CPAppearanceManager animateWithDuration:0.3 delay:0.4 options:0 animations:^{
            self.passwordTextField.alpha = 1.0;
        } completion:nil];
        
        /*CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
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
                            [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-PASS_EDIT_VIEW_BORDER_WIDTH],
                            [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:-PASS_EDIT_VIEW_BORDER_WIDTH],
                            [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:PASS_EDIT_VIEW_BORDER_WIDTH],
                            [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:PASS_EDIT_VIEW_BORDER_WIDTH],
                            nil];
        [self.superView addConstraints:self.constraints];
        [self.superView layoutIfNeeded];
        
        // enlarge to align with all cells
        [self.superView removeConstraints:self.constraints];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.constraints = [[NSArray alloc] initWithObjects:
                                [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BOX_SEPARATOR_SIZE - PASS_EDIT_VIEW_BORDER_WIDTH],
                                [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE - PASS_EDIT_VIEW_BORDER_WIDTH],
                                [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-BOX_SEPARATOR_SIZE + PASS_EDIT_VIEW_BORDER_WIDTH],
                                [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-BOX_SEPARATOR_SIZE + PASS_EDIT_VIEW_BORDER_WIDTH],
                                nil];
        } else {
            UIView *leftTopCell = [self.passCells objectAtIndex:0];
            UIView *rightBottomCell = [self.passCells lastObject];
            self.constraints = [[NSArray alloc] initWithObjects:
                                [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftTopCell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-PASS_EDIT_VIEW_BORDER_WIDTH],
                                [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:leftTopCell attribute:NSLayoutAttributeTop multiplier:1.0 constant:-PASS_EDIT_VIEW_BORDER_WIDTH],
                                [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:rightBottomCell attribute:NSLayoutAttributeRight multiplier:1.0 constant:PASS_EDIT_VIEW_BORDER_WIDTH],
                                [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:rightBottomCell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:PASS_EDIT_VIEW_BORDER_WIDTH],
                                nil];
        }
        
        [self.superView addConstraints:self.constraints];
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            [self.superView layoutIfNeeded];
            self.view.backgroundColor = password.color;
            
            if (password.isUsed.boolValue) {
                self.memoCollectionViewManager.memos = [[password.memos sortedArrayUsingDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO], nil]] mutableCopy];
            } else {
                self.memoCollectionViewManager.memos = [NSMutableArray array];
            }
        }];
        [CPAppearanceManager animateWithDuration:0.25 delay:0.25 options:0 animations:^{
            for (UIView *subView in self.view.subviews) {
                subView.alpha = 1.0;
            }
        } completion:nil];*/
    }];
}

- (void)hidePassEditView {
    [self.memoCollectionViewManager endEditing];
    
    [CPProcessManager stopProcess:EDITING_PASS_CELL_PROCESS withPreparation:^{
        self.index = -1;
        
        /*CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
        if (self.passwordTextField.text && ![self.passwordTextField.text isEqualToString:password.text]) {
            [[CPPassDataManager defaultManager] setPasswordText:self.passwordTextField.text atIndex:self.index];
        }
        
        UIView *cell = [self.passCells objectAtIndex:self.index];
        [self.superView removeConstraints:self.constraints];
        self.constraints = [[NSArray alloc] initWithObjects:
                            [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-PASS_EDIT_VIEW_BORDER_WIDTH],
                            [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:-PASS_EDIT_VIEW_BORDER_WIDTH],
                            [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:PASS_EDIT_VIEW_BORDER_WIDTH],
                            [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:PASS_EDIT_VIEW_BORDER_WIDTH],
                            nil];
        [self.superView addConstraints:self.constraints];
        
        [CPAppearanceManager animateWithDuration:0.25 animations:^{
            for (UIView *subview in self.view.subviews) {
                subview.alpha = 0.0;
            }
        }];
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            self.memoCollectionViewManager.memos = [NSMutableArray array];
            
            [self.superView layoutIfNeeded];
            self.view.backgroundColor = cell.backgroundColor;
        } completion:^(BOOL finished) {
            [self.superView removeConstraints:self.constraints];
            [self.view removeFromSuperview];
            self.index = -1;
        }];*/
    }];
}

/*#pragma mark - Property methods

- (UIView *)view {
    if (!_view) {
        _view = [[UIView alloc] init];
        _view.translatesAutoresizingMaskIntoConstraints = NO;
        
        _view.layer.borderColor = [UIColor blackColor].CGColor;
        _view.layer.borderWidth = PASS_EDIT_VIEW_BORDER_WIDTH;
        
        UIView *passwordTextFieldContainer = [[UIView alloc] init];
        passwordTextFieldContainer.backgroundColor = [UIColor clearColor];
        passwordTextFieldContainer.layer.borderColor = [UIColor whiteColor].CGColor;
        passwordTextFieldContainer.layer.borderWidth = 3.0;
        passwordTextFieldContainer.translatesAutoresizingMaskIntoConstraints = NO;
        
        [passwordTextFieldContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchOnPasswordTextFieldContainer)]];
        
        [_view addSubview:passwordTextFieldContainer];
        [_view addConstraints:[[NSArray alloc] initWithObjects:
                               [NSLayoutConstraint constraintWithItem:passwordTextFieldContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:PASS_EDIT_VIEW_BORDER_WIDTH + BOX_SEPARATOR_SIZE],
                               [NSLayoutConstraint constraintWithItem:passwordTextFieldContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeTop multiplier:1.0 constant:PASS_EDIT_VIEW_BORDER_WIDTH + BOX_SEPARATOR_SIZE],
                               [NSLayoutConstraint constraintWithItem:passwordTextFieldContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-PASS_EDIT_VIEW_BORDER_WIDTH - BOX_SEPARATOR_SIZE],
                               nil]];
        
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.textColor = [UIColor whiteColor];
        _passwordTextField.font = [UIFont boldSystemFontOfSize:24.0];
        _passwordTextField.backgroundColor = [UIColor clearColor];
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField.delegate = self;
        
        [passwordTextFieldContainer addSubview:_passwordTextField];
        [passwordTextFieldContainer addConstraints:[[NSArray alloc] initWithObjects:
                                                    [NSLayoutConstraint constraintWithItem:_passwordTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:passwordTextFieldContainer attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0],
                                                    [NSLayoutConstraint constraintWithItem:_passwordTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:passwordTextFieldContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0],
                                                    [NSLayoutConstraint constraintWithItem:_passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:passwordTextFieldContainer attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0],
                                                    [NSLayoutConstraint constraintWithItem:_passwordTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:passwordTextFieldContainer attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0],
                                                    nil]];
        
        UIView *memosView = [[UIView alloc] init];
        memosView.translatesAutoresizingMaskIntoConstraints = NO;
        [_view addSubview:memosView];
        [_view addConstraints:[[NSArray alloc] initWithObjects:
                               [NSLayoutConstraint constraintWithItem:memosView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:PASS_EDIT_VIEW_BORDER_WIDTH],
                               [NSLayoutConstraint constraintWithItem:memosView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:passwordTextFieldContainer attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE],
                               [NSLayoutConstraint constraintWithItem:memosView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-PASS_EDIT_VIEW_BORDER_WIDTH],
                               [NSLayoutConstraint constraintWithItem:memosView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-PASS_EDIT_VIEW_BORDER_WIDTH - BOX_SEPARATOR_SIZE],
                               nil]];
        
        _memoCollectionViewManager = [[CPMemoCollectionViewManager alloc] initWithSuperview:memosView style:CPMemoCollectionViewStyleInPassCell andDelegate:self];
    }
    return _view;
}

- (NSArray *)constraints {
    if (!_constraints) {
        _constraints = [[NSArray alloc] init];
    }
    return _constraints;
}*/

#pragma mark - Touch handler

- (void)handleTouchOnPasswordTextFieldContainer {
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - CPMemoCollectionViewManagerDelegate

- (CPMemo *)newMemo {
    return [[CPPassDataManager defaultManager] addMemoText:@"" intoIndex:self.index];
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
