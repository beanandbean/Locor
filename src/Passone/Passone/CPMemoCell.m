//
//  CPMemoCell.m
//  Passone
//
//  Created by wangyw on 7/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

#import "CPPassoneConfig.h"

#import "CPMemoCollectionViewManager.h"

#import "CPPassword.h"

#import "CPNotificationCenter.h"

#import "CPProcessManager.h"
#import "CPEditingMemoCellProcess.h"

@implementation CPMemoCell

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_label];
        
        [self.contentView addConstraints:[[NSArray alloc] initWithObjects:
                                          [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:5.0],
                                          [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0],
                                          [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0],
                                          [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-5.0],
                                          nil]];
    }
    return _label;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        NSMutableArray *gestureArray = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null], nil];
        
        UITapGestureRecognizer *editing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditingGesture:)];
        editing.numberOfTapsRequired = EDITING_TAP_NUMBER;
        [self addGestureRecognizer:editing];
        [gestureArray replaceObjectAtIndex:EDITING_TAP_NUMBER - 1 withObject:editing];
        
        UITapGestureRecognizer *copyPassword = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCopyPasswordGesture:)];
        copyPassword.numberOfTapsRequired = COPY_PASSWORD_TAP_NUMBER;
        [self addGestureRecognizer:copyPassword];
        [gestureArray replaceObjectAtIndex:COPY_PASSWORD_TAP_NUMBER - 1 withObject:copyPassword];
        
        [[gestureArray objectAtIndex:0] requireGestureRecognizerToFail:[gestureArray objectAtIndex:1]];
    }
    return self;
}

- (void)handleEditingGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self startEditing];
}

- (void)handleCopyPasswordGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    CPPassword *password = ((CPMemo *)[self.delegate.memos objectAtIndex:[(UICollectionView *)self.superview indexPathForCell:self].row]).password;
    [UIPasteboard generalPasteboard].string = password.text;
    [CPNotificationCenter insertNotification:[NSString stringWithFormat:@"Password No %d copied to clipboard.", password.index.intValue]];
}

- (void)refreshingConstriants {
    float offset = ((UIScrollView *)self.superview).contentOffset.y;
    
    // The constant parts of the following 2 constraints are determined by trying. The aim of putting these contants is to let the words in text field stay in exactly same place as self.label.
    ((NSLayoutConstraint *)[self.delegate.textFieldConstraints objectAtIndex:0]).constant = 12.0 - offset;
    ((NSLayoutConstraint *)[self.delegate.textFieldConstraints objectAtIndex:3]).constant = -5.0 - offset;
}

- (BOOL)isEditing {
    return self.delegate.editingCell == self;
}

- (void)startEditing {
    if (self.delegate.editingCell) {
        [self.delegate.editingCell endEditingAtIndexPath:[(UICollectionView *)self.superview indexPathForCell:self.delegate.editingCell]];
    }
    
    [CPProcessManager startProcess:EDITING_MEMO_CELL_PROCESS withPreparation:^{
        self.delegate.editingCell = self;
        
        float offset = ((UIScrollView *)self.superview).contentOffset.y;
        
        // The constant parts of the following 4 constraints are determined by trying. The aim of putting these contants is to let the words in text field stay in exactly same place as self.label.
        self.delegate.textFieldConstraints = [[NSArray alloc] initWithObjects:
                                [NSLayoutConstraint constraintWithItem:self.delegate.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:12.0 - offset],
                                [NSLayoutConstraint constraintWithItem:self.delegate.textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0],
                                [NSLayoutConstraint constraintWithItem:self.delegate.textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:10.0],
                                [NSLayoutConstraint constraintWithItem:self.delegate.textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-5.0 - offset],
                                nil];
        
        [self.delegate.textFieldContainer.superview addConstraints:self.delegate.textFieldConstraints];
        [self.delegate.textFieldContainer.superview layoutIfNeeded];
        
        self.label.hidden = YES;
        
        self.delegate.textField.textColor = self.label.textColor;
        self.delegate.textField.font = self.label.font;
        self.delegate.textField.backgroundColor = self.label.backgroundColor;
        self.delegate.textField.delegate = self;
        self.delegate.textField.hidden = NO;
        self.delegate.textField.enabled = YES;
        self.delegate.textField.text = self.label.text;
        
        [self.delegate.textField becomeFirstResponder];
    }];
}

- (void)endEditingAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isEditing]) {
        [CPProcessManager stopProcess:EDITING_MEMO_CELL_PROCESS withPreparation:^{
            self.delegate.editingCell = nil;
            self.label.hidden = NO;
            self.delegate.textField.hidden = YES;
            self.delegate.textField.enabled = NO;
            
            self.label.text = self.delegate.textField.text;
            
            [self.delegate memoCellAtIndexPath:indexPath updateText:self.delegate.textField.text];
            
            if ([self.delegate.textField isFirstResponder]) {
                [self.delegate.textField resignFirstResponder];
            }
            
            [self.delegate.textFieldContainer.superview removeConstraints:self.delegate.textFieldConstraints];
            self.delegate.textFieldConstraints = nil;
        }];
    }
}

#pragma mark - UITextFieldDelegate implement

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditingAtIndexPath:[(UICollectionView *)self.superview indexPathForCell:self]];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self endEditingAtIndexPath:[(UICollectionView *)self.superview indexPathForCell:self]];
}

@end
