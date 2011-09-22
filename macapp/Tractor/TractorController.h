#import <Foundation/Foundation.h>
#import "CurrentApplicationInformer.h"

@interface TractorController : NSObject {
  NSManagedObjectContext *context;
  CurrentApplicationInformer *informer;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)dumpJSON;

@end
