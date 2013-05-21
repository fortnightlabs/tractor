//
//  ManagedObjectContext.m
//  Tractor
//
//  Created by Gerad Suyderhoud on 12/23/12.
//
//

#import "ManagedObjectContext.h"

static ManagedObjectContext *sharedManagedObjectContext = nil;

@implementation ManagedObjectContext

@synthesize context=__managedObjectContext;

#pragma mark - Singleton

+ (ManagedObjectContext *)context {
  if (!sharedManagedObjectContext) {
    sharedManagedObjectContext = [[self alloc] init];
  }
  return sharedManagedObjectContext;
}

#pragma mark - Lifecycle

- (id)init
{
  self = [super init];
  if (self) {
    __projects = nil;
    __items = nil;
    __rules = nil;

    __managedObjectContext = nil;
    __persistentStoreCoordinator = nil;
    __managedObjectModel = nil;
  }

  return self;
}

- (void)dealloc
{
  [__projects release], __projects = nil;
  [__items release], __items = nil;
  [__rules release], __rules = nil;

  [__managedObjectContext release], __managedObjectContext = nil;
  [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
  [__managedObjectModel release], __managedObjectModel = nil;
  [super dealloc];
}

#pragma mark - Accessors

- (Items *)items
{
  if (!__items) {
    __items = [[Items alloc] initWithManagedObjectContext:[self managedObjectContext]];
  }
  
  return __items;
}


- (Projects *)projects
{
  if (!__projects) {
    __projects = [[Projects alloc] initWithManagedObjectContext:[self managedObjectContext]];
  }
  
  return __projects;
}

- (Rules *)rules
{
  if (!__rules) {
    __rules = [[Rules alloc] initWithManagedObjectContext:[self managedObjectContext]];
  }

  return __rules;
}


#pragma mark - Methods

- (BOOL)save
{
  BOOL couldSave = NO;
  NSError *error = nil;

  if (![__managedObjectContext save:&error]) {
    NSLog(@"Couldn't save: %@", [error localizedDescription]);
  } else {
    couldSave = YES;
  }

  return couldSave;
}



#pragma mark - NSManagedObjectContext helpers

/**
 Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Tractor" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
  return [libraryURL URLByAppendingPathComponent:@"Tractor"];
}

/**
 Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
  if (__managedObjectModel) {
    return __managedObjectModel;
  }
	
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tractor" withExtension:@"momd"];
  __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (__persistentStoreCoordinator) {
    return __persistentStoreCoordinator;
  }
  
  NSManagedObjectModel *mom = [self managedObjectModel];
  if (!mom) {
    NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
    return nil;
  }
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
  NSError *error = nil;
  
  NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
  
  if (!properties) {
    BOOL ok = NO;
    if ([error code] == NSFileReadNoSuchFileError) {
      ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (!ok) {
      [[NSApplication sharedApplication] presentError:error];
      return nil;
    }
  }
  else {
    if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
      // Customize and localize this error.
      NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
      
      NSMutableDictionary *dict = [NSMutableDictionary dictionary];
      [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
      error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
      
      [[NSApplication sharedApplication] presentError:error];
      return nil;
    }
  }
  
  NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Tractor.storedata"];
  __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
  NSDictionary *options = @{
                            NSMigratePersistentStoresAutomaticallyOption: @YES,
                            NSInferMappingModelAutomaticallyOption: @YES };
  if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]) {
    [[NSApplication sharedApplication] presentError:error];
    [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
    return nil;
  }
  
  return __persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.)
 */
- (NSManagedObjectContext *)managedObjectContext {
  if (__managedObjectContext) {
    return __managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (!coordinator) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
    [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
    NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
    [[NSApplication sharedApplication] presentError:error];
    return nil;
  }
  __managedObjectContext = [[NSManagedObjectContext alloc] init];
  [__managedObjectContext setPersistentStoreCoordinator:coordinator];
  
  return __managedObjectContext;
}

@end
