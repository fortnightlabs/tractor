#import "Items.h"

@implementation Items

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
  self = [super init];
  if (self) {
    context = [managedObjectContext retain];
  }

  return self;
}

- (void)save
{
  NSError *error = nil;
  if (![context save:&error]) {
    NSLog(@"Couldn't save: %@", [error localizedDescription]);
  }
}

- (Item *)addItem
{
  return [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                       inManagedObjectContext:context];
}

- (Item *)latestItem
{
  ItemsRequest *request = [self request];
  [request sortBy:@"start" ascending:NO];
  return [request first];
}

- (ItemsRequest *)request
{
  return [[[ItemsRequest alloc] initWithManagedObjectContext:context] autorelease];
}

- (void)dealloc
{
  [context release];
  [super release];
}

@end
