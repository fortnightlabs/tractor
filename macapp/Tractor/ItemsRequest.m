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
  return [[self class] JSONArray:[self all]];
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

- (void)filter:(NSString *)filter, ...
{
  va_list args;
  va_start(args, filter);
  [self setPredicate:[NSPredicate predicateWithFormat:filter arguments:args]];
  va_end(args);
}

- (void)dealloc
{
  [context release];
  [super dealloc];
}

+ (NSArray *)JSONArray:(NSArray *)array
{  
  NSMutableArray *json = [NSMutableArray arrayWithCapacity:[array count]];
  for (Item *item in array) {
    [json addObject:[item JSONDictionary]];
  }
  return json;
}

@end