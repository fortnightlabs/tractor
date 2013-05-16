#import <Foundation/Foundation.h>
#import "FetchRequest.h"

@interface ManagedObjectCollection : NSObject  {
  NSManagedObjectContext *context;
}

@property (atomic, readonly) NSManagedObjectContext *context;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (FetchRequest *)request;
- (id)insertNewObject;

@end
