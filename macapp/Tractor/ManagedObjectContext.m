//
//  ManagedObjectContext.m
//  Tractor
//
//  Created by Gerad Suyderhoud on 12/23/12.
//
//

#import "ManagedObjectContext.h"

static NSManagedObjectContext *sharedManagedObjectContext = nil;

@implementation ManagedObjectContext

+ (NSManagedObjectContext *)context {
  if (!sharedManagedObjectContext) {
    ManagedObjectContext *context = [[self alloc] init];
    sharedManagedObjectContext = [[context managedObjectContext] retain];
    [context release];
  }
  return sharedManagedObjectContext;
}

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
  if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
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

-(void)dealloc
{
  [__managedObjectContext release];
  [__persistentStoreCoordinator release];
  [__managedObjectModel release];
  [super dealloc];
}

@end
