#import <Foundation/Foundation.h>
#import "CurrentApplicationInformer.h"
#import "ManagedObjectContext.h"
#import "Item.h"

@interface TractorController : NSObject {
  CurrentApplicationInformer *informer;
  ManagedObjectContext *context;
  Item *latestItem;
}

- (id)initWithManagedObjectContext:(ManagedObjectContext *)managedObjectContext;

@end
