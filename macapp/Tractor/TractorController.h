#import <Foundation/Foundation.h>
#import "CurrentApplicationInformer.h"
#import "Item.h"

@interface TractorController : NSObject {
  NSManagedObjectContext *context;
  CurrentApplicationInformer *informer;
  Item *latestItem;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)dumpJSONToURL:(NSURL *)url;

@end
