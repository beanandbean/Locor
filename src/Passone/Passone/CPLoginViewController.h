//
//  CPLoginViewController.h
//  Passone
//
//  Created by wangyw on 4/30/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPLoginView.h"

@class CPLoginViewController;

@protocol CPLoginViewControllerDelegate <NSObject>

- (void)user:(NSString *)user loginFromLoginViewController:(CPLoginViewController *)loginViewController;

@end

@interface CPLoginViewController : UIViewController <CPLoginViewDelgate>

@property (weak, nonatomic) id<CPLoginViewControllerDelegate> delegate;

@end
