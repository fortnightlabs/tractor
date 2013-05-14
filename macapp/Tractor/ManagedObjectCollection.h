#import <Foundation/Foundation.h>
#import "FetchRequest.h"

@interface ManagedObjectCollection : NSObject  {
  NSManagedObjectContext *context;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (FetchRequest *)request;
- (id)insertNewObject;

@end
