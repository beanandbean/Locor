//
//  CPPassEditViewManager.m
//  Passone
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditViewManager.h"

@interface CPPassEditViewManager ()

@property (strong, nonatomic) NSArray *constraints;

@end

@implementation CPPassEditViewManager

- (UIView *)passwordEditView {
    if (!_passwordEditView) {
        [[NSBundle mainBundle] loadNibNamed:@"CPPassEditView" owner:self options:nil];
        _passwordEditView.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordEditView.backgroundColor = [UIColor blueColor];
    }
    return _passwordEditView;
}

- (NSArray *)constraints {
    if (!_constraints) {
        _constraints = [[NSArray alloc] init];
    }
    return _constraints;
}

- (void)addPassEditViewInView:(UIView *)view forCell:(UIView *)cell inCells:(NSMutableArray *)cells {
    [view addSubview:self.passwordEditView];
    
    // align with cell
    [view removeConstraints:self.constraints];
    self.constraints = [[NSArray alloc] initWithObjects:
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                        nil];
    [view addConstraints:self.constraints];
    [view layoutIfNeeded];

    // enlarge to align with all cells
    [view removeConstraints:self.constraints];
    
    UIView *leftTopCell = [cells objectAtIndex:0];
    UIView *rightBottomCell = [cells lastObject];
    self.constraints = [[NSArray alloc] initWithObjects:
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftTopCell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:leftTopCell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:rightBottomCell attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                        [NSLayoutConstraint constraintWithItem:self.passwordEditView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:rightBottomCell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                        nil];
    [view addConstraints:self.constraints];
    [UIView animateWithDuration:0.5 animations:^{
        [view layoutIfNeeded];
    }];
}

@end
