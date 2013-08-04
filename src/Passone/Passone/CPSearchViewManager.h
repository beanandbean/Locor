//
//  CPSearchViewManager.h
//  Passone
//
//  Created by wangyw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

@interface CPSearchViewManager : NSObject <UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;

- (id)initWithSuperView:(UIView *)superView;

@end
