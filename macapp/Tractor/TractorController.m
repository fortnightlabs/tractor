#import "TractorController.h"
#import "Item.h"
#import "JSONKit.h"


@interface TractorController (PRIVATE)

- (void)checkCurrentState:(NSTimer *)timer;
- (void)checkStateAgainInOneSecond;

- (Item *)latestItem;
- (void)insertOrUpdateWithName:(NSString *)name andInfo:(NSDictionary *)info;

@end

@implementation TractorController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
  self = [super init];
  if (self) {
    context = [managedObjectContext retain];
    informer = [[CurrentApplicationInformer alloc] init];
    [self checkCurrentState:nil];
  }
  
  return self;
}

- (void)checkCurrentState:(NSTimer *)timer
{
  CurrentApplicationInfo *app = [informer currentApplicationInfo];

  [self insertOrUpdateWithName:[app name] andInfo:[app info]];  
  
  [self checkStateAgainInOneSecond];
}

- (void)insertOrUpdateWithName:(NSString *)name andInfo:(NSDictionary *)info
{
  NSDate *now = [NSDate date];
  Item *latest = [self latestItem];
  NSData *infoData = [info JSONData];

  if ([latest matchesApp:name andInfoData:infoData]) {
    [latest setEnd:now]; // update the end time
  } else {
    [latest setEnd:now]; // update the previous item's end time
    
    // insert a new item
    latest = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                           inManagedObjectContext:context];
    [latest setStart:now];
    [latest setEnd:now];

    if (name) { [latest setApp:name]; }
    if (info) { [latest setInfo:infoData]; }
  }

  NSError *error = nil;
  if (![context save:&error]) {
    NSLog(@"Couldn't save: %@", [error localizedDescription]);
  }
}

- (Item *)latestItem
{
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  NSSortDescriptor *startDesc = [NSSortDescriptor sortDescriptorWithKey:@"start" ascending:NO];
  
  [request setEntity:[NSEntityDescription entityForName:@"Item"
                                 inManagedObjectContext:context]];
  [request setSortDescriptors:[NSArray arrayWithObjects:startDesc, nil]];
  [request setFetchLimit:1];
  
  NSError *error;
  NSArray *items = [context executeFetchRequest:request error:&error];
  if (items == nil) {
    NSLog(@"Couldn't fetch: %@", [error localizedDescription]);
    return nil;
  }
  
  return [items count] == 0 ? nil : [items objectAtIndex:0];
}

- (void)dumpJSON
{
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  NSSortDescriptor *startAsc = [NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES];
  
  [request setEntity:[NSEntityDescription entityForName:@"Item"
                                 inManagedObjectContext:context]];
  [request setSortDescriptors:[NSArray arrayWithObjects:startAsc, nil]];
  
  NSError *error;
  NSArray *items = [context executeFetchRequest:request error:&error];
  if (items == nil) {
    NSLog(@"Couldn't fetch: %@", [error localizedDescription]);
    return;
  }
  
  NSMutableArray *json = [NSMutableArray arrayWithCapacity:[items count]];
  for (Item *item in items) {
    [json addObject:[item JSONDictionary]];
  }
  
  NSLog(@"%@", [json JSONString]);
}

- (void)checkStateAgainInOneSecond
{
  NSTimer *timer = [NSTimer timerWithTimeInterval:1 * 10 // 10 seconds for now
                                           target:self
                                         selector:@selector(checkCurrentState:)
                                         userInfo:nil
                                          repeats:NO];
  
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)dealloc
{
  [context release];
  [informer release];
  [super release];
}

@end
