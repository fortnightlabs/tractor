//
//  ManagedObjectContext.h
//  Tractor
//
//  Created by Gerad Suyderhoud on 12/23/12.
//
//

#import <Foundation/Foundation.h>

@interface ManagedObjectContext : NSObject {
  NSPersistentStoreCoordinator *__persistentStoreCoordinator;
  NSManagedObjectModel *__managedObjectModel;
  NSManagedObjectContext *__managedObjectContext;
}

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

+(NSManagedObjectContext *)context;

@end
