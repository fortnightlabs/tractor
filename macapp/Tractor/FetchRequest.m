#import "FetchRequest.h"

@implementation FetchRequest

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                        entityName:(NSString *)entityName
{
  self = [super init];
  if (self) {
    context = [managedObjectContext retain];
    [self setEntity:[NSEntityDescription entityForName:entityName
                                inManagedObjectContext:context]];
    
  }
  return self;
}

- (id)first
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

- (void)sortBy:(NSString *)key ascending:(BOOL)yn
{
  NSSortDescriptor *order = [NSSortDescriptor sortDescriptorWithKey:key ascending:yn];
  [self setSortDescriptors:[NSArray arrayWithObjects:order, nil]];
}

- (void)limit:(NSUInteger)count
{
  [self setFetchLimit:count];
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



@end