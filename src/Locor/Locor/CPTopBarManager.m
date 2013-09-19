//
//  CPTopBarAndSearchManager.m
//  Locor
//
//  Created by wangyw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPTopBarManager.h"

#import "CPLocorConfig.h"

#import "CPCoverImageView.h"

#import "CPMemoCollectionViewManager.h"

#import "CPAppearanceManager.h"

#import "CPBarButtonManager.h"

#import "CPPassDataManager.h"

#import "CPProcessManager.h"
#import "CPSearchingProcess.h"
#import "CPSettingsProcess.h"

static const char *BUTTON_NAMES[] = {"H", "M", "P"}, *BUTTON_SELECTORS[] = {"pressedHelp", "pressedMainPassword", "pressedPurchase"};

@interface CPTopBarManager ()

@property (strong, nonatomic) UIButton *barButton;

@property (weak, nonatomic) UITextField *searchBarTextField;

@property (strong, nonatomic) UIView *resultContainer;

@property (strong, nonatomic) CPCoverImageView *coverImage;

@property (strong, nonatomic) UIView *frontResultContainer;
@property (strong, nonatomic) UIView *backResultContainer;

@property (strong, nonatomic) CPMemoCollectionViewManager *resultMemoCollectionViewManager;

@property (strong, nonatomic) UIView *settingsContainer;
@property (strong, nonatomic) UIView *buttonContainer;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSMutableArray *buttonTopConstraints;

@end

@implementation CPTopBarManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.searchBar];
    [self.superview addSubview:self.barButton];
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BAR_HEIGHT]];
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.barButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.barButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BAR_HEIGHT]];
    
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.searchBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardMarginEdgeLeft]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.barButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeRight multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.barButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardMarginEdgeRight]];
    
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.barButton attribute:NSLayoutAttributeWidth alignToView:self.barButton attribute:NSLayoutAttributeHeight]];
}

- (void)alignContentView:(UIView *)contentView {
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
    
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:contentView alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
}

- (void)openSetting {
    [self.superview addSubview:self.settingsContainer];
    [self alignContentView:self.settingsContainer];
    
    [self.superview bringSubviewToFront:self.searchBar];
    [self.superview bringSubviewToFront:self.barButton];
    
    [CPProcessManager startProcess:SETTINGS_PROCESS withPreparation:^{
        [CPBarButtonManager pushBarButtonStateWithTitle:@"X" target:self action:@selector(closeSetting) andControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSetting)];
        [self.settingsContainer addGestureRecognizer:tapGesture];
        self.settingsContainer.alpha = 0.0;
        self.settingsContainer.backgroundColor = [UIColor blackColor];
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            self.settingsContainer.alpha = 0.9;
        }];
        
        [self.settingsContainer addSubview:self.buttonContainer];
        [self.settingsContainer addConstraints:[CPAppearanceManager constraintsWithView:self.buttonContainer alignToView:self.settingsContainer attribute:NSLayoutAttributeTop, NSLayoutAttributeBottom, ATTR_END]];
        [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.buttonContainer alignToView:self.barButton attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
        
        for (int i = 0; i < SETTINGS_BUTTON_COUNT; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:CSTR_TO_OBJC(BUTTON_NAMES[i]) forState:UIControlStateNormal];
            [button addTarget:self action:NSSelectorFromString(CSTR_TO_OBJC(BUTTON_SELECTORS[i])) forControlEvents:UIControlEventTouchUpInside];
            
            [self.buttons addObject:button];
            [self.buttonContainer addSubview:button];
            
            [self.buttonContainer addConstraints:[CPAppearanceManager constraintsWithView:button alignToView:self.buttonContainer attribute:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
            [button addConstraint:[CPAppearanceManager constraintWithView:button height:BAR_HEIGHT]];
            
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.buttonContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:-BOX_SEPARATOR_SIZE];
            [self.buttonContainer addConstraint:topConstraint];
            [self.buttonTopConstraints addObject:topConstraint];
        }        
        [self.superview layoutIfNeeded];
        
        [self.buttonContainer removeConstraints:self.buttonTopConstraints];
        for (int i = 0; i < SETTINGS_BUTTON_COUNT; i++) {
            UIButton *button = [self.buttons objectAtIndex:i];
            __block NSLayoutConstraint *topConstraint;
            [CPAppearanceManager animateWithDuration:(SETTINGS_BUTTON_COUNT - i) * SETTINGS_BUTTON_ANIMATION_TIME_STEP delay:i * SETTINGS_BUTTON_ANIMATION_TIME_STEP + 0.3 options:0 preparation:^{
                if (i) {
                    topConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self.buttons objectAtIndex:i - 1] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BOX_SEPARATOR_SIZE];
                } else {
                    topConstraint = [CPAppearanceManager constraintWithView:button alignToView:self.buttonContainer attribute:NSLayoutAttributeTop];
                }
                [self.buttonContainer addConstraint:topConstraint];
                [self.buttonTopConstraints addObject:topConstraint];
            } animations:^{
                [self.buttonContainer layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (i == SETTINGS_BUTTON_COUNT - 1) {
                    for (NSLayoutConstraint *constraint in self.buttonTopConstraints) {
                        constraint.constant += BOX_SEPARATOR_SIZE * (SETTINGS_BUTTON_ANIMATION_BOUNCE_MULTIPLIER - 1);
                    }
                    [CPAppearanceManager animateWithDuration:0.2 animations:^{
                        [self.buttonContainer layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        for (NSLayoutConstraint *constraint in self.buttonTopConstraints) {
                            constraint.constant -= BOX_SEPARATOR_SIZE * (SETTINGS_BUTTON_ANIMATION_BOUNCE_MULTIPLIER - 1);
                        }
                        [CPAppearanceManager animateWithDuration:0.2 animations:^{
                            [self.buttonContainer layoutIfNeeded];
                        }];
                    }];
                }
            }];
        }
    }];
}

- (void)closeSetting {
    [CPProcessManager stopProcess:SETTINGS_PROCESS withPreparation:^{
        [CPBarButtonManager popBarButtonState];
        [self.buttonContainer removeConstraints:self.buttonTopConstraints];
        
        for (int i = 0; i < SETTINGS_BUTTON_COUNT; i++) {
            UIButton *button = [self.buttons objectAtIndex:i];
            [CPAppearanceManager animateWithDuration:(i + 1) * SETTINGS_BUTTON_ANIMATION_TIME_STEP animations:^{
                [self.buttonContainer addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.buttonContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:-BOX_SEPARATOR_SIZE]];
                [self.buttonContainer layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (i == SETTINGS_BUTTON_COUNT - 1) {
                    [self.buttonContainer removeFromSuperview];
                }
            }];
        }
        
        [CPAppearanceManager animateWithDuration:0.5 delay:SETTINGS_BUTTON_COUNT * SETTINGS_BUTTON_ANIMATION_TIME_STEP - 0.2 options:0 animations:^{
            self.settingsContainer.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.settingsContainer removeFromSuperview];
            self.settingsContainer = nil;
            self.buttonContainer = nil;
            self.buttons = nil;
            self.buttonTopConstraints = nil;
        }];
    }];
}

- (void)stopSearching {
    NSAssert(IS_IN_PROCESS(SEARCHING_PROCESS), @"Receive an unexpected stop searching request!");
    [self.resultMemoCollectionViewManager endEditing];
    [CPProcessManager stopProcess:SEARCHING_PROCESS withPreparation:^{
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            self.resultContainer.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.resultContainer removeFromSuperview];
            
            [CPBarButtonManager popBarButtonState];
            
            self.backResultContainer = nil;
            self.coverImage = nil;
            self.frontResultContainer = nil;
            self.resultMemoCollectionViewManager = nil;
            
            self.resultContainer = nil;
            
            self.searchBar.text = @"";
            if ([self.searchBar isFirstResponder]) {
                [self.searchBar resignFirstResponder];
            }
            
            [CPAppearanceManager animateWithDuration:0.5 animations:^{
                [self.superview layoutIfNeeded];
            }];
        }];
    }];
}

- (void)handleTapOnSearchBar:(UITapGestureRecognizer *)tapGesture {
    self.searchBarTextField.enabled = YES;
    if (![self.searchBar isFirstResponder]) {
        [self.resultMemoCollectionViewManager endEditing];
        [self.searchBar becomeFirstResponder];
    }
}

#pragma mark - UISearchBarDelegate implement

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (IS_IN_PROCESS(SEARCHING_PROCESS)) {
        self.resultMemoCollectionViewManager.memos = [[[CPPassDataManager defaultManager] memosContainText:searchBar.text] mutableCopy];
        return YES;
    } else {
        // TODO: When search bar is focused, stop if being currently editing memo cells in pass edit view.
        return [CPProcessManager startProcess:SEARCHING_PROCESS withPreparation:^{
            [self.superview addSubview:self.resultContainer];
            
            [self alignContentView:self.resultContainer];
            
            [self.resultContainer addSubview:self.backResultContainer];
            [self.resultContainer addSubview:self.coverImage];
            [self.resultContainer addSubview:self.frontResultContainer];
            
            [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.frontResultContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardMarginEdgeLeft]];
            [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.frontResultContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardMarginEdgeRight]];
            
            [self.resultContainer addConstraints:[CPAppearanceManager constraintsWithView:self.frontResultContainer alignToView:self.resultContainer attribute:NSLayoutAttributeTop, NSLayoutAttributeBottom, ATTR_END]];
            
            [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.backResultContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardMarginEdgeLeft]];
            [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.backResultContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual constant:0.0 toPosition:CPStandardMarginEdgeRight]];
            
            [self.resultContainer addConstraints:[CPAppearanceManager constraintsWithView:self.backResultContainer alignToView:self.resultContainer attribute:NSLayoutAttributeTop, NSLayoutAttributeBottom, ATTR_END]];
            
            [self.superview addConstraints:self.coverImage.positioningConstraints];
            
            [CPBarButtonManager pushBarButtonStateWithTitle:@"X" target:self action:@selector(stopSearching) andControlEvents:UIControlEventTouchUpInside];
            
            self.coverImage.alpha = 0.0;
            
            self.resultMemoCollectionViewManager.memos = [[[CPPassDataManager defaultManager] memosContainText:searchBar.text] mutableCopy];
            
            [self.superview layoutIfNeeded];
            
            [self.resultMemoCollectionViewManager showMemoCollectionViewAnimated];
            
            [CPAppearanceManager animateWithDuration:0.3 animations:^{
                self.coverImage.alpha = WATER_MARK_ALPHA;
                self.resultContainer.backgroundColor = [UIColor blackColor];
            } completion:nil];
        }];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.searchBarTextField.enabled = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultMemoCollectionViewManager.memos = [[[CPPassDataManager defaultManager] memosContainText:searchText] mutableCopy];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.resultMemoCollectionViewManager endEditing];
}

- (void)pressedHelp {
}

- (void)pressedMainPassword {
}

- (void)pressedPurchase {
}

#pragma mark - lazy init

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
        _searchBar.autocapitalizationType = NO;
        
        UIGraphicsBeginImageContext(CGSizeMake(1.0, 34.0));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0);
        CGContextFillRect(context, CGRectMake(0.0, 0.0, 1.0, 34.0));
        UIImage *backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        UIGraphicsEndImageContext();
        
        _searchBar.backgroundImage = backgroundImage;
        [_searchBar setSearchFieldBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        [self.searchBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnSearchBar:)]];
        
        for (UIView *view in _searchBar.subviews) {
            if ([view.class isSubclassOfClass:[UITextField class]]) {
                self.searchBarTextField = (UITextField *)view;
                self.searchBarTextField.enabled = NO;
                break;
            }
        }
    }
    return _searchBar;
}

- (UIButton *)barButton {
    if (!_barButton) {
        _barButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _barButton.translatesAutoresizingMaskIntoConstraints = NO;
        _barButton.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        [_barButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [CPBarButtonManager initializeWithBarButton:_barButton];
        [CPBarButtonManager pushBarButtonStateWithTitle:@"S" target:self action:@selector(openSetting) andControlEvents:UIControlEventTouchUpInside];
    }
    return _barButton;
}

- (UIView *)resultContainer {
    if (!_resultContainer) {
        _resultContainer = [[UIView alloc] init];
        _resultContainer.clipsToBounds = YES;
        _resultContainer.backgroundColor = [UIColor clearColor];
        _resultContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _resultContainer;
}

- (UIView *)frontResultContainer {
    if (!_frontResultContainer) {
        _frontResultContainer = [[UIView alloc] init];
        _frontResultContainer.backgroundColor = [UIColor clearColor];
        _frontResultContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _frontResultContainer;
}

- (UIView *)backResultContainer {
    if (!_backResultContainer) {
        _backResultContainer = [[UIView alloc] init];
        _backResultContainer.backgroundColor = [UIColor clearColor];
        _backResultContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _backResultContainer;
}

- (CPCoverImageView *)coverImage {
    if (!_coverImage) {
        _coverImage = [[CPCoverImageView alloc] init];
    }
    return _coverImage;
}

- (CPMemoCollectionViewManager *)resultMemoCollectionViewManager {
    if (!_resultMemoCollectionViewManager) {
        _resultMemoCollectionViewManager = [[CPMemoCollectionViewManager alloc] initWithSuperview:self.superview frontLayer:self.frontResultContainer backLayer:self.backResultContainer andDelegate:nil];
    }
    return _resultMemoCollectionViewManager;
}

- (UIView *)settingsContainer {
    if (!_settingsContainer) {
        _settingsContainer = [[UIView alloc] init];
        _settingsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _settingsContainer;
}

- (UIView *)buttonContainer {
    if (!_buttonContainer) {
        _buttonContainer = [[UIView alloc] init];
        _buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _buttonContainer;
}

- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (NSMutableArray *)buttonTopConstraints {
    if (!_buttonTopConstraints) {
        _buttonTopConstraints = [NSMutableArray array];
    }
    return _buttonTopConstraints;
}

@end
