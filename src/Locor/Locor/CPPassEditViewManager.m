//
//  CPPassEditViewManager.m
//  Locor
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditViewManager.h"

#import "CPLocorConfig.h"

#import "CPDraggingPassCell.h"
#import "CPCoverImageView.h"
#import "CPIconPicker.h"

#import "CPBarButtonManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"
#import "CPMemo.h"

#import "CPAppearanceManager.h"

#import "CPProcessManager.h"
#import "CPEditingPassCellProcess.h"

@interface CPPassEditViewManager ()

@property (weak, nonatomic) UIView *superview;
@property (weak, nonatomic) NSArray *passCells;

@property (nonatomic) BOOL allowEdit;

@property (strong, nonatomic) UIView *outerView;

@property (strong, nonatomic) CPCoverImageView *coverImage;

@property (strong, nonatomic) CPIconPicker *cellIcon;
@property (strong, nonatomic) UIView *cellBackground;

@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIView *passwordTextFieldBackground;

@property (strong, nonatomic) CPMemoCollectionViewManager *memoCollectionViewManager;

@end

@implementation CPPassEditViewManager

- (id)initWithSuperview:(UIView *)superview andCells:(NSArray *)cells {
    self = [super init];
    if (self) {
        self.index = -1;
        self.superview = superview;
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
        [self.superview addSubview:self.outerView];
        
        [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.outerView alignToView:self.superview attribute:NSLayoutAttributeTop, NSLayoutAttributeBottom, ATTR_END]];
        [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.outerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardMarginEdgeLeft]];
        [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.outerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardMarginEdgeRight]];
        
        // - Back And Front Layers Initialization
        
        UIView *backLayer = [[UIView alloc] init];
        backLayer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.outerView addSubview:backLayer];
        [self.outerView addConstraints:[CPAppearanceManager constraintsWithView:backLayer edgesAlignToView:self.outerView]];
        
        self.coverImage = [[CPCoverImageView alloc] init];
        self.coverImage.alpha = 0.0;
        [self.outerView addSubview:self.coverImage];
        [self.superview addConstraints:self.coverImage.positioningConstraints];
        
        UIView *frontLayer = [[UIView alloc] init];
        frontLayer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.outerView addSubview:frontLayer];
        [self.superview addConstraints:[CPAppearanceManager constraintsWithView:frontLayer edgesAlignToView:backLayer]];
        
        // - Top Cell Initialization
        
        self.cellBackground = [[UIView alloc] init];
        self.cellBackground.hidden = YES;
        self.cellBackground.backgroundColor = password.realColor;
        self.cellBackground.translatesAutoresizingMaskIntoConstraints = NO;
        [backLayer addSubview:self.cellBackground];
        
        [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellBackground attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.outerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.outerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
        [self.outerView addConstraint:[CPAppearanceManager constraintWithView:self.cellBackground height:PASS_EDIT_VIEW_CELL_SIZE]];
        [self.outerView addConstraint:[CPAppearanceManager constraintWithView:self.cellBackground width:PASS_EDIT_VIEW_CELL_SIZE]];
        
        self.cellIcon = [[CPIconPicker alloc] initWithDelegate:self];
        self.cellIcon.enabled = NO;
        self.cellIcon.startIcon = password.icon;
        self.cellIcon.backgroundColor = [UIColor clearColor];
        self.cellIcon.translatesAutoresizingMaskIntoConstraints = NO;
        [frontLayer addSubview:self.cellIcon];
        
        [self.outerView addConstraints:[CPAppearanceManager constraintsWithView:self.cellIcon alignToView:self.cellBackground attribute:NSLayoutAttributeTop, NSLayoutAttributeBottom, ATTR_END]];
        [self.outerView addConstraints:[CPAppearanceManager constraintsWithView:self.cellIcon alignToView:self.outerView attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
        
        CPDraggingPassCell *draggingCell = [[CPDraggingPassCell alloc] initWithCell:[self.passCells objectAtIndex:index] onView:self.superview withShadow:NO];
        ((CPPassCellManager *)[self.passCells objectAtIndex:index]).hidden = YES;
        
        // - Password Text Field Initialization
        
        self.passwordTextFieldBackground = [[UIView alloc] init];
        self.passwordTextFieldBackground.backgroundColor = [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        self.passwordTextFieldBackground.translatesAutoresizingMaskIntoConstraints = NO;
        [backLayer addSubview:self.passwordTextFieldBackground];
        
        NSLayoutConstraint *textFieldBackgroundWidthConstraint = [NSLayoutConstraint constraintWithItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.0];
        [backLayer addConstraint:textFieldBackgroundWidthConstraint];
        
        [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:backLayer attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
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
        
        [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0]];
        [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0]];
        [self.outerView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
                
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
        
        [self.outerView addConstraints:[CPAppearanceManager constraintsWithView:frontMemoContainer edgesAlignToView:backMemoContainer]];
        
        self.memoCollectionViewManager = [[CPMemoCollectionViewManager alloc] initWithSuperview:self.superview frontLayer:frontMemoContainer backLayer:backMemoContainer andDelegate:self];
        self.memoCollectionViewManager.enabled = password.isUsed.boolValue;
        self.memoCollectionViewManager.inPasswordMemoColor = password.realColor;
        
        if (password.isUsed.boolValue) {
            self.memoCollectionViewManager.memos = [[password.memos sortedArrayUsingDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"text" ascending:NO], nil]] mutableCopy];
        } else {
            self.memoCollectionViewManager.memos = [NSMutableArray array];
        }
                
        [self.superview layoutIfNeeded];
        
        // Animations
        
        // - Pass Cell Animations
        [CPAppearanceManager animateWithDuration:0.4 animations:^{
            for (CPPassCellManager *cell in self.passCells) {
                if (cell.index != index) {
                    cell.alpha = 0.0;
                }
            }
            
            self.coverImage.alpha = WATER_MARK_ALPHA;
        }];
        
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            [self.superview removeConstraint:draggingCell.leftConstraint];
            [self.superview removeConstraint:draggingCell.topConstraint];
            [self.superview removeConstraints:draggingCell.sizeConstraints];
            
            [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:draggingCell attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
            [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:draggingCell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
            [self.superview addConstraint:[CPAppearanceManager constraintWithView:draggingCell height:PASS_EDIT_VIEW_CELL_SIZE]];
            [self.superview addConstraint:[CPAppearanceManager constraintWithView:draggingCell width:PASS_EDIT_VIEW_CELL_SIZE]];
            
            [self.superview layoutIfNeeded];
            draggingCell.backgroundColor = password.realColor;
            
            if (!password.isUsed.boolValue) {
                draggingCell.icon.alpha = 0.0;
            }
        } completion:^(BOOL finished) {
            self.cellBackground.hidden = NO;
            
            if (password.isUsed.boolValue) {
                [CPAppearanceManager animateWithDuration:0.3 animations:^{
                    self.cellIcon.enabled = YES;
                } completion:^(BOOL finished) {
                    [draggingCell removeFromSuperview];
                }];
            } else {
                [draggingCell removeFromSuperview];
            }
        }];
        
        // - Text Field Animations
        [CPAppearanceManager animateWithDuration:0.4 delay:0.3 options:0 animations:^{
            [backLayer removeConstraint:textFieldBackgroundWidthConstraint];
            [backLayer addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:backLayer attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
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
        
        if (password.isUsed.boolValue) {
            [self.memoCollectionViewManager showMemoCollectionViewAnimated];
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
            for (CPPassCellManager *cell in self.passCells) {
                if (cell.index != self.index) {
                    cell.alpha = 1.0;
                }
            }
            
            self.coverImage.alpha = 0.0;
        } completion:nil];
        
        CPDraggingPassCell *draggingCell = [[CPDraggingPassCell alloc] initWithCell:[self.passCells objectAtIndex:self.index] onView:self.superview withShadow:NO];
        
        [self.superview removeConstraint:draggingCell.leftConstraint];
        [self.superview removeConstraint:draggingCell.topConstraint];
        [self.superview removeConstraints:draggingCell.sizeConstraints];
        
        NSLayoutConstraint *draggingCellCenterXConstraint = [NSLayoutConstraint constraintWithItem:draggingCell attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        [self.superview addConstraint:draggingCellCenterXConstraint];
        NSLayoutConstraint *draggingCellTopConstraint = [NSLayoutConstraint constraintWithItem:draggingCell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE];
        [self.superview addConstraint:draggingCellTopConstraint];
        
        NSArray *draggingCellSizeConstraints = [NSArray arrayWithObjects:
                                                [CPAppearanceManager constraintWithView:draggingCell height:PASS_EDIT_VIEW_CELL_SIZE],
                                                [CPAppearanceManager constraintWithView:draggingCell width:PASS_EDIT_VIEW_CELL_SIZE],
                                                nil];
        [self.superview addConstraints:draggingCellSizeConstraints];

        
        [self.superview layoutIfNeeded];
        draggingCell.backgroundColor = password.realColor;
        
        if (!password.isUsed.boolValue) {
            draggingCell.icon.alpha = 0.0;
        }
        
        self.cellBackground.hidden = YES;
        
        [CPAppearanceManager animateWithDuration:0.3 animations:^{
            self.cellIcon.enabled = NO;
        }];
        
        [CPAppearanceManager animateWithDuration:0.5 delay:0.3 options:0 animations:^{
            [self.superview removeConstraint:draggingCellCenterXConstraint];
            [self.superview removeConstraint:draggingCellTopConstraint];
            [self.superview removeConstraints:draggingCellSizeConstraints];
            
            [self.superview addConstraint:draggingCell.leftConstraint];
            [self.superview addConstraint:draggingCell.topConstraint];
            [self.superview addConstraints:draggingCell.sizeConstraints];

            [self.superview layoutIfNeeded];
            draggingCell.backgroundColor = password.displayColor;
            draggingCell.icon.alpha = 1.0;
        } completion:^(BOOL finished) {
            ((CPPassCellManager *)[self.passCells objectAtIndex:self.index]).hidden = NO;
            
            [draggingCell removeFromSuperview];
            [self.outerView removeFromSuperview];
            
            self.outerView = nil;
            
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

#pragma mark - CPIconPickerDelegate implement

- (void)iconSelected:(NSString *)iconName {
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    password.icon = iconName;
    [[CPPassDataManager defaultManager] saveContext];
}

#pragma mark - CPMemoCollectionViewManagerDelegate implement

- (CPMemo *)newMemo {
    return [[CPPassDataManager defaultManager] newMemoText:@"" inIndex:self.index];
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
                self.cellIcon.enabled = self.memoCollectionViewManager.enabled = NO;
            }];
        }
    } else if ([textField.text isEqualToString:@""]) {
        if (!self.allowEdit) {
            self.allowEdit = YES;
            [CPAppearanceManager animateWithDuration:0.3 animations:^{
                self.cellIcon.enabled = self.memoCollectionViewManager.enabled = YES;
            }];
        }
    }
    
    return YES;
}

@end
