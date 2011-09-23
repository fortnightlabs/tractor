#import <Foundation/Foundation.h>
#import "Item.h"

@interface ItemsRequest : NSFetchRequest {
  NSManagedObjectContext *context;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (Item *)first;
- (NSArray *)all;

- (NSArray *)JSONArray;

- (void)sortBy:(NSString *)key ascending:(BOOL)yn;
- (void)limit:(NSUInteger)count;

@end
