//
//  CPMemoCell.m
//  Passone
//
//  Created by wangyw on 7/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

#import "CPMemoCollectionViewManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"
#import "CPMemo.h"

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
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    CPPassword *password = ((CPMemo *)[self.delegate.memos objectAtIndex:[(UICollectionView *)self.superview indexPathForCell:self].row]).password;
    [UIPasteboard generalPasteboard].string = password.text;
    [CPNotificationCenter insertNotification:[NSString stringWithFormat:@"Password No %d copied to clipboard.", password.index.intValue]];
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self startEditing];
}

- (void)refreshingConstriants {
    float offset = ((UIScrollView *)self.superview).contentOffset.y;
    
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
    
    [CPProcessManager startProcess:[CPEditingMemoCellProcess process] withPreparation:^{
        self.delegate.editingCell = self;
        
        float offset = ((UIScrollView *)self.superview).contentOffset.y;
        
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
        [CPProcessManager stopProcess:[CPEditingMemoCellProcess process] withPreparation:^{
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
