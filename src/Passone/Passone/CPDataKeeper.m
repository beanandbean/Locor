//
//  CPDataKeeper.m
//  Passone
//
//  Created by wangsw on 4/30/13.
//  Copyright (c) 2013 wangyw. All rights reserved.
//

#import "CPDataKeeper.h"

static const int COUNT = 9;
static const NSString *KEY_PASSWORD = @"password";
static const NSString *KEY_ITEMS = @"items";
static const NSString *KEY_POSITION_X = @"positionX";
static const NSString *KEY_POSITION_Y = @"positionY";
static const NSString *KEY_STRING = @"string";
static const NSString *KEY_INDEX = @"index";

@interface CPDataKeeper ()

@property (nonatomic, strong) NSArray *passwordData;
@property (nonatomic, strong) NSMutableArray *itemsData;

@end

@implementation CPDataKeeper

# pragma mark - Public Methods

- (void)loadDataForUser:(NSString *)username
{
    NSString *filePath = [CPDataKeeper filePathForUser:username];
    self.passwordData = [NSArray arrayWithContentsOfFile:filePath];
    if (!self.passwordData) {
        NSDictionary *dict = [NSDictionary dictionary];
        self.passwordData = [NSArray arrayWithObjects:dict, dict, dict, dict, dict, dict, dict, dict, dict, nil];
    }
    for (int i = 0; i < COUNT; i++) {
        NSDictionary *dict = [self.passwordData objectAtIndex:i];
        if ([dict count]) {
            NSMutableArray *items = [dict objectForKey:KEY_ITEMS];
            for (int j = 0; j < [items count]; j++) {
                NSString *string = [items objectAtIndex:j];
                NSNumber *index = [NSNumber numberWithInt:i];
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:string, KEY_STRING, index, KEY_INDEX, nil];
                [items replaceObjectAtIndex:j withObject:data];
            }
            self.itemsData = [CPDataKeeper mergeSortedArray1:self.itemsData andArray2:items];
        }
    }
    
}

# pragma mark - Private Methods

+ (NSString *)filePathForUser:(NSString *)username
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"data_%@.plist", username];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (NSMutableArray *)mergeSortedArray1:(NSArray *)array1 andArray2:(NSArray *)array2
{
    NSMutableArray *result = [NSMutableArray array];
    int i = 0, j = 0;
    int c1 = [array1 count];
    int c2 = [array2 count];
    while ((c1 - i) * (c2 - j)) {
        NSString *o1 = [array1 objectAtIndex:i];
        NSString *o2 = [array2 objectAtIndex:j];
        if (o1 < o2) {
            [result addObject:o1];
            i++;
        } else {
            [result addObject:o2];
            j++;
        }
    }
    if (c1 - i) {
        NSRange range;
        range.location = i;
        range.length = c1 - i;
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
        NSArray *items = [array1 objectsAtIndexes:indexes];
        [result addObjectsFromArray:items];
    } else if (c2 - j) {
        NSRange range;
        range.location = j;
        range.length = c2 - j;
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
        NSArray *items = [array2 objectsAtIndexes:indexes];
        [result addObjectsFromArray:items];
    }
    return result;
}

@end
