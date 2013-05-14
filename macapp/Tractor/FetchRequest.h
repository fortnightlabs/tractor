#import <Foundation/Foundation.h>
#import "Item.h"

@interface FetchRequest : NSFetchRequest {
  NSManagedObjectContext *context;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                    entityName:(NSString *)entityName;

- (id)first;
- (NSArray *)all;

- (void)sortBy:(NSString *)key ascending:(BOOL)yn;
- (void)limit:(NSUInteger)count;
- (void)filter:(NSString *)filter, ...;

@end
