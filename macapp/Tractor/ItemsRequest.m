#import "ItemsRequest.h"

@implementation ItemsRequest

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
  self = [super init];
  if (self) {
    context = [managedObjectContext retain];
    [self setEntity:[NSEntityDescription entityForName:@"Item"
                                inManagedObjectContext:context]];
    
  }
  return self;
}

- (Item *)first
{
  Item *ret = nil;
  
  [self limit:1];
  NSArray *all = [self all];
  
  if ([all count] > 0) {
    ret = [all objectAtIndex:0];
  }
  
  return ret;
}

- (NSArray *)all
{
  NSError *error;
  
  NSArray *items = [context executeFetchRequest:self error:&error];
  if (items == nil) {
    NSLog(@"Couldn't fetch: %@", [error localizedDescription]);
    items = [NSArray array]; // empty array
  }
  
  return items;
}

- (NSArray *)JSONArray
{
  NSArray *items = [self all];
  
  NSMutableArray *json = [NSMutableArray arrayWithCapacity:[items count]];
  for (Item *item in items) {
    [json addObject:[item JSONDictionary]];
  }
  
  return json;
}

- (void)sortBy:(NSString *)key ascending:(BOOL)yn
{
  NSSortDescriptor *order = [NSSortDescriptor sortDescriptorWithKey:key ascending:yn];
  [self setSortDescriptors:[NSArray arrayWithObjects:order, nil]];
}

- (void)limit:(NSUInteger)count
{
  [self setFetchLimit:1];
}

- (void)dealloc
{
  [context release];
  [super release];
}

@end