#import <Foundation/Foundation.h>
#import "Items.h"
#import "Projects.h"
#import "Rules.h"

@interface ManagedObjectContext : NSObject {
  NSPersistentStoreCoordinator *__persistentStoreCoordinator;
  NSManagedObjectModel *__managedObjectModel;
  NSManagedObjectContext *__managedObjectContext;

  Items *__items;
  Projects *__projects;
  Rules *__rules;
}

@property (nonatomic, readonly) Items *items;
@property (nonatomic, readonly) Projects *projects;
@property (nonatomic, readonly) Rules *rules;
@property (nonatomic, readonly) NSManagedObjectContext *context;

#pragma mark - Singleton

+ (ManagedObjectContext *)context;

#pragma mark - Methods

- (BOOL)save;


@end
