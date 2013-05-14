//
//  ManagedObjectContext.h
//  Tractor
//
//  Created by Gerad Suyderhoud on 12/23/12.
//
//

#import <Foundation/Foundation.h>
#import "Items.h"
#import "Projects.h"

@interface ManagedObjectContext : NSObject {
  NSPersistentStoreCoordinator *__persistentStoreCoordinator;
  NSManagedObjectModel *__managedObjectModel;
  NSManagedObjectContext *__managedObjectContext;

  Items *__items;
  Projects *__projects;
}

@property (nonatomic, readonly) Items *items;
@property (nonatomic, readonly) Projects *projects;

#pragma mark - Singleton

+ (ManagedObjectContext *)context;

#pragma mark - Methods

- (BOOL)save;


@end
