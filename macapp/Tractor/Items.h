#import <Foundation/Foundation.h>
#import "ItemsRequest.h"

@interface Items : NSObject {
  NSManagedObjectContext *context;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)save;

- (Item *)addItem;
- (Item *)latestItem;

- (ItemsRequest *)request;

@end
