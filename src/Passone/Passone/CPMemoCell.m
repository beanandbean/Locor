//
//  CPMemoCell.m
//  Passone
//
//  Created by wangyw on 7/8/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

@interface CPMemoCell ()

@property (strong, nonatomic) UITextField *textField;

@end

@implementation CPMemoCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.label = [[UILabel alloc] init];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont boldSystemFontOfSize:35.0];
        self.label.backgroundColor = [UIColor clearColor];

        [self addConstraints:[[NSArray alloc] initWithObjects:
                              [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:5.0],
                              [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5.0],
                              [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-5.0],
                              [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-5.0],
                              nil]];
        
        [self.contentView addSubview:self.label];

        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
    }
    return self;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    self.textField = [[UITextField alloc] init];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.text = self.label.text;
    self.textField.delegate = self;
    [self addSubview:self.textField];

    [self addConstraints:[[NSArray alloc] initWithObjects:
                          [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:5.0],
                          [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5.0],
                          [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-5.0],
                          [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-5.0],
                          nil]];
    
    [self.textField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate implement

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSLog(@".......");
    return YES;
}

@end
