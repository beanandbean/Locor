//
//  CPTopBarAndSearchManager.h
//  Locor
//
//  Created by wangyw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

#import "CPViewManager.h"

#import "CPSettingsManager.h"

@interface CPTopBarManager : CPViewManager <CPSettingsManagerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;

@end
