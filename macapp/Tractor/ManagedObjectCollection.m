#import "ManagedObjectCollection.h"

@implementation ManagedObjectCollection

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
  self = [super init];
  if (self) {
    context = [managedObjectContext retain];
  }
  
  return self;
}

- (id)insertNewObject
{
  return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                       inManagedObjectContext:context];
}

- (FetchRequest *)request
{
  return [[[FetchRequest alloc] initWithManagedObjectContext:context entityName:[self entityName]] autorelease];
}


- (NSString *)entityName
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}


@end
