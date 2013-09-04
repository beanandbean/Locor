//
//  CPPassEditViewManager.m
//  Locor
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CPPassEditViewManager.h"

#import "CPLocorConfig.h"

#import "CPPassGridManager.h"

#import "CPBarButtonManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"
#import "CPMemo.h"

#import "CPAppearanceManager.h"

#import "CPProcessManager.h"
#import "CPEditingPassCellProcess.h"

@interface CPPassEditViewManager ()

@property (weak, nonatomic) UIView *superView;
@property (weak, nonatomic) UIImageView *superCoverImage;
@property (weak, nonatomic) NSArray *passCells;

@property (nonatomic) BOOL allowEdit;

@property (strong, nonatomic) UIView *outerView;
@property (strong, nonatomic) NSArray *outerViewConstraints;

@property (strong, nonatomic) UIImageView *cellIcon;
@property (strong, nonatomic) UIView *cellBackground;

@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIView *passwordTextFieldBackground;

@property (strong, nonatomic) CPMemoCollectionViewManager *memoCollectionViewManager;

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
        self.allowEdit = password.isUsed.boolValue;
        
        [CPBarButtonManager pushBarButtonStateWithTitle:@"X" target:self action:@selector(hidePassEditView) andControlEvents:UIControlEventTouchUpInside];
        
        // View Initialization
        
        // - Outer View Initialization
        
        self.outerView = [[UIView alloc] init];
        self.outerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.superView addSubview:self.outerView];
        
        self.outerViewConstraints = [CPAppearanceManager constraintsForView:self.outerView toEqualToView:self.superView];
        [self.superView addConstraints:self.outerViewConstraints];
        
        // - Back And Front Layers Initialization
        
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
        
        // - Top Cell Initialization
        
        self.cellBackground = [[UIView alloc] init];
        self.cellBackground.hidden = YES;
        self.cellBackground.backgroundColor = password.color;
        self.cellBackground.translatesAutoresizingMaskIntoConstraints = NO;
        [backLayer addSubview:self.cellBackground];
        
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellBackground attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellBackground attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self.passCells objectAtIndex:index] attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:[self.passCells objectAtIndex:index] attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        
        self.cellIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:password.trueIcon]];
        self.cellIcon.alpha = 0.0;
        self.cellIcon.translatesAutoresizingMaskIntoConstraints = NO;
        [frontLayer addSubview:self.cellIcon];
        
        [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellIcon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.cellBackground attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellIcon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.cellBackground attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        NSArray *draggingCellDetail = [CPPassGridManager makeDraggingCellFromCell:[self.passCells objectAtIndex:index] onView:self.superView withCover:self.superCoverImage];
        ((CPPassCell *)[self.passCells objectAtIndex:index]).hidden = YES;
        
        // - Password Text Field Initialization
        
        self.passwordTextFieldBackground = [[UIView alloc] init];
        self.passwordTextFieldBackground.backgroundColor = [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        self.passwordTextFieldBackground.translatesAutoresizingMaskIntoConstraints = NO;
        [backLayer addSubview:self.passwordTextFieldBackground];
        
        NSLayoutConstraint *textFieldBackgroundRightConstraint = [NSLayoutConstraint constraintWithItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
        [backLayer addConstraint:textFieldBackgroundRightConstraint];
        
        [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:backLayer attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cellBackground attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:MEMO_CELL_HEIGHT]];
        
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
        
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeRight multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
        [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
                
        // - Memo Collection View Initialization
        
        UIView *backMemoContainer = [[UIView alloc] init];
        backMemoContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [backLayer addSubview:backMemoContainer];
        
        [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:backMemoContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:backLayer attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:backMemoContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:backLayer attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:backMemoContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:backMemoContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:backLayer attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
        
        UIView *frontMemoContainer = [[UIView alloc] init];
        frontMemoContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [frontLayer addSubview:frontMemoContainer];
        
        [self.superView addConstraints:[CPAppearanceManager constraintsForView:frontMemoContainer toEqualToView:backMemoContainer]];
        
        self.memoCollectionViewManager = [[CPMemoCollectionViewManager alloc] initWithSuperview:self.superView frontLayer:frontMemoContainer backLayer:backMemoContainer style:CPMemoCollectionViewStyleInPassCell andDelegate:self];
        
        if (password.isUsed.boolValue) {
            self.memoCollectionViewManager.memos = [[password.memos sortedArrayUsingDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"text" ascending:NO], nil]] mutableCopy];
        } else {
            self.memoCollectionViewManager.memos = [NSMutableArray array];
        }
                
        [self.superView layoutIfNeeded];
        
        // Animations
        
        // - Pass Cell Animations
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
            self.cellBackground.hidden = NO;
            
            if (password.isUsed.boolValue) {
                self.cellIcon.alpha = 1.0;
            }
            
            [self.superView removeConstraint:draggingCellTopConstraint];
            [self.superView removeConstraint:draggingCellCenterXConstraint];
            [self.superView removeConstraints:[draggingCellDetail objectAtIndex:3]];
            [self.superView removeConstraints:[draggingCellDetail objectAtIndex:4]];
            [(UIView *)[draggingCellDetail objectAtIndex:0] removeFromSuperview];
        }];
        
        // - Text Field Animations
        [CPAppearanceManager animateWithDuration:0.4 delay:0.3 options:0 animations:^{
            [backLayer removeConstraint:textFieldBackgroundRightConstraint];
            [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:backLayer attribute:NSLayoutAttributeRight multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
            [backLayer layoutIfNeeded];
        } completion:nil];
        
        [CPAppearanceManager animateWithDuration:0.3 delay:0.4 options:0 animations:^{
            self.passwordTextField.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (!password.isUsed.boolValue) {
                [self.passwordTextField becomeFirstResponder];
            }
        }];
        
        // - Memo Collection View Animations
        UIView *fakeMemoContainer = [[UIView alloc] init];
        fakeMemoContainer.clipsToBounds = YES;
        fakeMemoContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [backLayer addSubview:fakeMemoContainer];
        
        NSArray *fakeMemoContainerConstraints = [CPAppearanceManager constraintsForView:fakeMemoContainer toEqualToView:backMemoContainer];
        [backLayer addConstraints:fakeMemoContainerConstraints];
        
        NSMutableArray *fakeMemos = [NSMutableArray array];
        NSMutableArray *fakeMemoConstraints = [NSMutableArray array];
        for (UIView *realMemo in self.memoCollectionViewManager.backCollectionView.subviews) {
            UIView *fakeMemo = [[UIView alloc] init];
            fakeMemo.backgroundColor = realMemo.backgroundColor;
            fakeMemo.translatesAutoresizingMaskIntoConstraints = NO;
            [fakeMemoContainer addSubview:fakeMemo];
            [fakeMemos addObject:fakeMemo];
            
            NSLayoutConstraint *fakeMemoTopConstraint = [NSLayoutConstraint constraintWithItem:fakeMemo attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:realMemo attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
            [backLayer addConstraint:fakeMemoTopConstraint];
            [fakeMemoConstraints addObject:fakeMemoTopConstraint];
            NSLayoutConstraint *fakeMemoBottomConstraint = [NSLayoutConstraint constraintWithItem:fakeMemo attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:realMemo attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
            [backLayer addConstraint:fakeMemoBottomConstraint];
            [fakeMemoConstraints addObject:fakeMemoBottomConstraint];
            NSLayoutConstraint *fakeMemoLeftConstraint = [NSLayoutConstraint constraintWithItem:fakeMemo attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:realMemo attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
            [backLayer addConstraint:fakeMemoLeftConstraint];
            [fakeMemoConstraints addObject:fakeMemoLeftConstraint];
            NSLayoutConstraint *fakeMemoWidthConstraint= [NSLayoutConstraint constraintWithItem:fakeMemo attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
            [fakeMemo addConstraint:fakeMemoWidthConstraint];
        }
        
        for (UIView *subview in self.memoCollectionViewManager.frontCollectionView.subviews) {
            subview.alpha = 0.0;
        }
        for (UIView *subview in self.memoCollectionViewManager.backCollectionView.subviews) {
            subview.alpha = 0.0;
        }
        
        [self.superView layoutIfNeeded];
        
        for (int i = 0; i < fakeMemos.count; i++) {
            [CPAppearanceManager animateWithDuration:0.4 delay:0.34 + 0.04 * i options:0 animations:^{
                ((NSLayoutConstraint *)[((UIView *)[fakeMemos objectAtIndex:i]).constraints objectAtIndex:0]).constant = self.memoCollectionViewManager.backCollectionView.frame.size.width - 2 * BOX_SEPARATOR_SIZE;
                [(UIView *)[fakeMemos objectAtIndex:i] layoutIfNeeded];
            } completion:^(BOOL finished) {
                ((UIView *)[self.memoCollectionViewManager.backCollectionView.subviews objectAtIndex:i]).alpha = 1.0;
                
                if (i == fakeMemos.count - 1) {
                    [backLayer removeConstraints:fakeMemoContainerConstraints];
                    [fakeMemoContainer removeFromSuperview];
                }
            }];
            
            [CPAppearanceManager animateWithDuration:0.3 delay:0.44 + 0.04 * i options:0 animations:^{
                ((UIView *)[self.memoCollectionViewManager.frontCollectionView.subviews objectAtIndex:i]).alpha = 1.0;
            } completion:nil];
        }
    }];
}

#pragma mark - Touch handler

- (void)hidePassEditView {
    [self.memoCollectionViewManager endEditing];
    
    [CPProcessManager stopProcess:EDITING_PASS_CELL_PROCESS withPreparation:^{
        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
        if (self.passwordTextField.text && ![self.passwordTextField.text isEqualToString:password.text]) {
            [[CPPassDataManager defaultManager] setPasswordText:self.passwordTextField.text atIndex:self.index];
        }
        
        [CPBarButtonManager popBarButtonState];
        
        // Animations
        
        // - Memo Collection View & Text Field Animations
        
        [CPAppearanceManager animateWithDuration:0.4 animations:^{
            self.passwordTextField.alpha = 0.0;
            self.passwordTextFieldBackground.alpha = 0.0;
            self.memoCollectionViewManager.frontCollectionView.alpha = 0.0;
            self.memoCollectionViewManager.backCollectionView.alpha = 0.0;
        }];
        
        // - Pass Cell Animations
        
        [CPAppearanceManager animateWithDuration:0.4 delay:0.2 options:0 animations:^{
            for (CPPassCell *cell in self.passCells) {
                if (cell.index != self.index) {
                    cell.alpha = 1.0;
                }
            }
        } completion:nil];
        
        NSArray *draggingCellDetail = [CPPassGridManager makeDraggingCellFromCell:[self.passCells objectAtIndex:self.index] onView:self.superView withCover:self.superCoverImage];
        
        [self.superView removeConstraint:[draggingCellDetail objectAtIndex:1]];
        [self.superView removeConstraint:[draggingCellDetail objectAtIndex:2]];
        
        NSLayoutConstraint *draggingCellCenterXConstraint = [NSLayoutConstraint constraintWithItem:[draggingCellDetail objectAtIndex:0] attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        [self.superView addConstraint:draggingCellCenterXConstraint];
        NSLayoutConstraint *draggingCellTopConstraint = [NSLayoutConstraint constraintWithItem:[draggingCellDetail objectAtIndex:0] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE];
        [self.superView addConstraint:draggingCellTopConstraint];
        
        [self.superView layoutIfNeeded];
        ((UIView *)[draggingCellDetail objectAtIndex:0]).backgroundColor = password.color;
        
        if (!password.isUsed.boolValue) {
            ((UIView *)[draggingCellDetail objectAtIndex:5]).alpha = 0.0;
        }
        
        self.cellBackground.hidden = YES;
        self.cellIcon.alpha = 0.0;
        
        [CPAppearanceManager animateWithDuration:0.5 delay:0.3 options:0 animations:^{
            [self.superView removeConstraint:draggingCellCenterXConstraint];
            [self.superView removeConstraint:draggingCellTopConstraint];
            
            [self.superView addConstraint:[draggingCellDetail objectAtIndex:1]];
            [self.superView addConstraint:[draggingCellDetail objectAtIndex:2]];

            [self.superView layoutIfNeeded];
            ((UIView *)[draggingCellDetail objectAtIndex:0]).backgroundColor = password.displayColor;
            ((UIView *)[draggingCellDetail objectAtIndex:5]).alpha = 1.0;
        } completion:^(BOOL finished) {
            ((CPPassCell *)[self.passCells objectAtIndex:self.index]).hidden = NO;
            
            [self.superView removeConstraint:draggingCellTopConstraint];
            [self.superView removeConstraint:draggingCellCenterXConstraint];
            [self.superView removeConstraints:[draggingCellDetail objectAtIndex:3]];
            [self.superView removeConstraints:[draggingCellDetail objectAtIndex:4]];
            [(UIView *)[draggingCellDetail objectAtIndex:0] removeFromSuperview];
            
            [self.superView removeConstraints:self.outerViewConstraints];
            [self.outerView removeFromSuperview];
            
            self.outerView = nil;
            self.outerViewConstraints = nil;
            
            self.cellIcon = nil;
            self.cellBackground = nil;
            
            self.passwordTextField = nil;
            self.passwordTextFieldBackground = nil;
            
            self.memoCollectionViewManager = nil;
            
            self.index = -1;
        }];
    }];
}

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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (!range.location && range.length == textField.text.length && [string isEqualToString:@""]) {
        if (self.allowEdit) {
            self.allowEdit = NO;
            [CPAppearanceManager animateWithDuration:0.3 animations:^{
                self.cellIcon.alpha = 0.0;
            }];
        }
    } else if ([textField.text isEqualToString:@""]) {
        if (!self.allowEdit) {
            self.allowEdit = YES;
            [CPAppearanceManager animateWithDuration:0.3 animations:^{
                self.cellIcon.alpha = 1.0;
            }];
        }
    }
    
    return YES;
}

@end
