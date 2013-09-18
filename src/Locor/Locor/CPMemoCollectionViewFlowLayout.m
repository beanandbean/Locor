//
//  CPMemoCollectionViewFlowLayout.m
//  Locor
//
//  Created by wangsw on 9/18/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCollectionViewFlowLayout.h"

#import "CPLocorConfig.h"

@implementation CPMemoCollectionViewFlowLayout

- (id)init {
    self = [super init];
    if (self) {
        self.minimumLineSpacing = BOX_SEPARATOR_SIZE;
    }
    return self;
}

- (CGSize)itemSize {
    return CGSizeMake(self.collectionView.frame.size.width, MEMO_CELL_HEIGHT);
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:itemIndexPath];
    
    // [ARGUMENTs decided by TESTING] The two FLT_MAX are important, for if that is some other number, then after the animation the removed cell will like flying at the back of the other cells to outside of the screen. The FLT_MAX moved them away during the animation and make no 'spirit' of removed cell flying around.
    attributes.frame = CGRectMake(FLT_MAX, FLT_MAX, self.collectionView.frame.size.width, 0.0);
    
    return attributes;
}

@end
