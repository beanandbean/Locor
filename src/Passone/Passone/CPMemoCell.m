//
//  CPMemoCell.m
//  Passone
//
//  Created by wangyw on 7/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

static CPMemoCell *editingCell;
static UIView *textFieldContainer;

@interface CPMemoCell ()

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) NSArray *textFieldConstraints;

@end

@implementation CPMemoCell

+ (void)setTextFieldContainer:(UIView *)container {
    textFieldContainer = container;
}

+ (CPMemoCell *)editingCell {
    return editingCell;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont boldSystemFontOfSize:35.0];
        _label.backgroundColor = [UIColor clearColor];
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

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        _textField.textColor = self.label.textColor;
        _textField.font = self.label.font;
        _textField.backgroundColor = [UIColor clearColor];
        _textField.enabled = NO;
        _textField.delegate = self;
        [textFieldContainer addSubview:_textField];
        
        [textFieldContainer.superview addConstraints:self.textFieldConstraints];
    }
    return _textField;
}

- (NSArray *)textFieldConstraints {
    if (!_textFieldConstraints) {
        float offset = ((UIScrollView *)self.superview).contentOffset.y;
        
        _textFieldConstraints = [[NSArray alloc] initWithObjects:
                                 [NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:12.0 - offset],
                                 [NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0],
                                 [NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:10.0],
                                 [NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-5.0 - offset],
                                 nil];
    }
    return _textFieldConstraints;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
    }
    return self;
}

- (void)dealloc {
    if (textFieldContainer) {
        [textFieldContainer removeConstraints:self.textFieldConstraints];
        [self.textField removeFromSuperview];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (editingCell) {
        [editingCell endEditing];
    }
    editingCell = self;
    
    self.label.alpha = 0.0;
    self.textField.alpha = 1.0;
    self.textField.enabled = YES;
    self.textField.text = self.label.text;
    
    [self refreshingConstriants];
    [self.textField becomeFirstResponder];
}

- (void)refreshingConstriants {
    float offset = ((UIScrollView *)self.superview).contentOffset.y;
    
    ((NSLayoutConstraint *)[self.textFieldConstraints objectAtIndex:0]).constant = 12.0 - offset;
    ((NSLayoutConstraint *)[self.textFieldConstraints objectAtIndex:3]).constant = -5.0 - offset;
}

- (BOOL)isEditing {
    return editingCell == self;
}

- (void)endEditing {
    if ([self isEditing]) {
        editingCell = nil;
        self.label.alpha = 1.0;
        self.textField.alpha = 0.0;
        self.textField.enabled = NO;
        
        if ([self.textField isFirstResponder]) {
            [self.textField resignFirstResponder];
        }
    }
}

#pragma mark - UITextFieldDelegate implement

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self endEditing];
}

@end
