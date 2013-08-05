//
//  CPMemoCellRemoving.h
//  Passone
//
//  Created by wangsw on 7/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPMemoCellRemoving : UICollectionViewCell

@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) UILabel *leftLabel;
@property (strong, nonatomic) UILabel *rightLabel;

- (void)setImageLeftOffset:(float)offset;

@end
