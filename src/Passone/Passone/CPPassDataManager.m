//
//  CPPassDataManager.m
//  Passone
//
//  Created by wangyw on 6/13/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassDataManager.h"

#import "CPMemo.h"
#import "CPPassword.h"

#import "CPNotificationCenter.h"

@interface CPPassDataManager ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation CPPassDataManager

static CPPassDataManager *_defaultManager = nil;

+ (CPPassDataManager *)defaultManager {
    if (!_defaultManager) {
        _defaultManager = [[CPPassDataManager alloc] init];
    }
    return _defaultManager;
}

- (NSFetchedResultsController *)passwordsController {
    if (!_passwordsController) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Password" inManagedObjectContext:self.managedObjectContext];
        request.sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES], nil];
        _passwordsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"PasswordCache"];
        [_passwordsController performFetch:nil];
        
        if (!_passwordsController.fetchedObjects.count) {
            static const CGFloat colors[] = {
                1.0, 0.0, 0.0,
                1.0, 0.89, 0.0,
                0.22, 0.08, 0.68,
                0.0, 0.8, 0.0,
                1.0, 0.57, 0.0,
                0.8, 0.96, 0.0,
                0.65, 0.0, 0.65,
                0.04, 0.38, 0.64,
                0.0, 0.32, 1.0
            };
            // TODO: The third and last two colors for cells are too similar, so they need to be changed.
            for (NSUInteger index = 0; index < 9; index++) {
                CPPassword *password = [NSEntityDescription insertNewObjectForEntityForName:@"Password" inManagedObjectContext:self.managedObjectContext];
                password.isUsed = [NSNumber numberWithBool:NO];
                password.text = @"";
                password.index = [NSNumber numberWithUnsignedInteger:index];
                password.creationDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
                password.colorRed = [NSNumber numberWithFloat:colors[index * 3]];
                password.colorGreen = [NSNumber numberWithFloat:colors[index * 3 + 1]];
                password.colorBlue = [NSNumber numberWithFloat:colors[index * 3 + 2]];
            }
            [_passwordsController performFetch:nil];
        }
    }
    return _passwordsController;
}

- (void)setPasswordText:(NSString *)text atIndex:(NSUInteger)index {
    CPPassword *password = [self.passwordsController.fetchedObjects objectAtIndex:index];
    NSAssert(password, @"");
    
    // TODO: Show notification when removing a pass cell by setting an empty text.
    if ([text isEqualToString:@""]) {
        password.isUsed = [NSNumber numberWithBool:NO];
    } else {
        if (!password.isUsed.boolValue) {
            for (CPMemo *memo in password.memos) {
                [self.managedObjectContext deleteObject:memo];
            }
            [password removeMemos:password.memos];
        }
        password.text = text;
        password.creationDate = [[NSDate alloc] init];
        password.isUsed = [NSNumber numberWithBool:YES];
    }
    
    [self saveContext];
}

- (CPMemo *)addMemoText:(NSString *)text intoIndex:(NSUInteger)index {
    CPPassword *password = [self.passwordsController.fetchedObjects objectAtIndex:index];
    NSAssert(password, @"");
    
    CPMemo *memo = [NSEntityDescription insertNewObjectForEntityForName:@"Memo" inManagedObjectContext:self.managedObjectContext];
    memo.text = text;
    memo.creationDate = [[NSDate alloc] init];
    memo.password = password;
    [password addMemosObject:memo];
    
    [self saveContext];
    return memo;
}

- (BOOL)canToggleRemoveStateOfPasswordAtIndex:(NSUInteger)index {
    CPPassword *password = [self.passwordsController.fetchedObjects objectAtIndex:index];
    NSAssert(password, @"");

    return ![password.text isEqualToString:@""];
}

- (void)toggleRemoveStateOfPasswordAtIndex:(NSUInteger)index {
    CPPassword *password = [self.passwordsController.fetchedObjects objectAtIndex:index];
    NSAssert(password, @"");
    
    NSString *notification = nil;
    if ([password.text isEqualToString:@""]) {
        notification = [[NSString alloc] initWithFormat:@"Password No %d cannot be recovered as it is empty.", index];
    } else {
        password.isUsed = [NSNumber numberWithBool:!password.isUsed.boolValue];
        [self saveContext];
        
        if (password.isUsed.boolValue) {
            notification = [[NSString alloc] initWithFormat:@"Password No %d is recovered.", index];
        } else {
            notification = [[NSString alloc] initWithFormat:@"Password No %d is removed, swipe again to recover it.", index];
        }
    }
    [CPNotificationCenter insertNotification:notification];
}

- (void)exchangePasswordBetweenIndex1:(NSUInteger)index1 andIndex2:(NSUInteger)index2 {
    CPPassword *password = [self.passwordsController.fetchedObjects objectAtIndex:index1];
    password.index = [NSNumber numberWithUnsignedInteger:index2];
    password = [self.passwordsController.fetchedObjects objectAtIndex:index2];
    password.index = [NSNumber numberWithUnsignedInteger:index1];
    [self saveContext];
}

- (NSArray *)memosContainText:(NSString *)text {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Memo" inManagedObjectContext:self.managedObjectContext]];
    
    if (text && ![text isEqualToString:@""]) {
        request.predicate = [NSPredicate predicateWithFormat:@"password.isUsed = YES && text contains %@", text];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"password.isUsed = YES", text];
    }
    request.sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"text" ascending:YES], nil];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             TODO: MAY ABORT! Handle the error appropriately when saving context.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if (coordinator) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Passone" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Passone.sqlite"];
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            /*
             TODO: MAY ABORT! Handle the error appropriately when initializing persistent store coordinator.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

@end
