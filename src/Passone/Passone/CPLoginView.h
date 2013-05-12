//
//  CPLoginView.h
//  Passone
//
//  Created by wangyw on 5/1/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPLoginView;

@protocol CPLoginViewDelgate <NSObject>

- (void)addUser:(NSString *)user password:(NSString *)password fromLoginView:(CPLoginView *)loginView;

- (void)user:(NSString *)user loginFromLoginView:(CPLoginView *)loginView;

@end

@interface CPLoginView : UIView

@property (weak, nonatomic) id<CPLoginViewDelgate> loginViewDelegate;

@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) IBOutlet UIView *userView;
@property (strong, nonatomic) IBOutlet UIView *registerView;
@property (strong, nonatomic) IBOutlet UIView *loginView;

@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@property (weak, nonatomic) IBOutlet UIView *registerBackgroundView;

@property (weak, nonatomic) IBOutlet UITextField *registerUserName;
@property (weak, nonatomic) IBOutlet UITextField *registerPassword;
@property (weak, nonatomic) IBOutlet UITextField *registerConfirmedPassword;

@property (weak, nonatomic) IBOutlet UIView *loginBackgroundView;

@property (weak, nonatomic) IBOutlet UILabel *loginUserName;
@property (weak, nonatomic) IBOutlet UITextField *loginPassword;

- (id)initWithSmallSize:(CGFloat)smallSize largeSize:(CGFloat)largeSize user:(NSString *)user password:(NSString *)password;

- (void)shrink;

- (IBAction)register:(id)sender;

- (IBAction)login:(id)sender;

@end
