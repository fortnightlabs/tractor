#import <Foundation/Foundation.h>
#import "ManagedObjectCollection.h"

@interface Items : ManagedObjectCollection

- (Item *)addItem;
- (Item *)latestItem;

- (NSArray *)itemsForDay:(NSDate *)date;
- (NSArray *)appGroupsForDay:(NSDate *)date;

- (void)dumpJSONToFileURL:(NSURL *)url;
- (void)uploadJSONToURL:(NSURL *)url;

@end
