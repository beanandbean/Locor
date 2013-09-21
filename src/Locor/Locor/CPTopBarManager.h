//
//  CPTopBarAndSearchManager.h
//  Locor
//
//  Created by wangyw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

#import "CPIAPHelper.h"
#import "CPViewManager.h"

@interface CPTopBarManager : CPViewManager <CPIAPHelperDelegate, UIActionSheetDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UIToolbar *topBar;

@end
