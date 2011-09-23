#import "TractorController.h"
#import "JSONKit.h"

#include <IOKit/IOKitLib.h>
static int64_t SystemIdleSeconds(void);

@interface TractorController (PRIVATE)

- (void)checkCurrentState:(NSTimer *)timer;
- (void)checkStateAgainInOneSecond;

- (void)insertOrUpdateItemWithName:(NSString *)name
                           andInfo:(NSDictionary *)info
                            atTime:(NSDate *)now;

- (void)updateLatestItemFromDataStore;

@end

@implementation TractorController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
  self = [super init];
  if (self) {
    context = [managedObjectContext retain];
    informer = [[CurrentApplicationInformer alloc] init];
    [self updateLatestItemFromDataStore];
    [self checkCurrentState:nil];
  }
  
  return self;
}

- (void)checkCurrentState:(NSTimer *)timer
{
  int64_t idleSeconds = SystemIdleSeconds();
  NSString *name = nil;
  NSDictionary *info = nil;
  NSDate *now = [NSDate date];

  if (idleSeconds > 5 * 60) { // 5 minutes hard coded for now
    now = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval)idleSeconds];
  } else {
    CurrentApplicationInfo *app = [informer currentApplicationInfo];
    name = [app name];
    info = [app info];
  }
  [self insertOrUpdateItemWithName:name
                           andInfo:info
                            atTime:now];  
  
  [self checkStateAgainInOneSecond];
}

- (void)insertOrUpdateItemWithName:(NSString *)name
                           andInfo:(NSDictionary *)info
                            atTime:(NSDate *)now;
{
  NSData *infoData = [info JSONData];

  // TODO handle when now is before start (can happen due to idle time)

  if ([latestItem matchesApp:name andInfoData:infoData]) {
    [latestItem setEnd:now]; // update the end time
  } else {
    [latestItem setEnd:now]; // update the previous item's end time
    
    // insert a new item
    [latestItem autorelease];
    latestItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                           inManagedObjectContext:context];
    [latestItem retain];

    [latestItem setStart:now];
    [latestItem setEnd:now];

    if (name) { [latestItem setApp:name]; }
    if (info) { [latestItem setInfo:infoData]; }
  }

  NSError *error = nil;
  if (![context save:&error]) {
    NSLog(@"Couldn't save: %@", [error localizedDescription]);
  }
}

- (void)updateLatestItemFromDataStore
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
  }
  
  latestItem = [items count] == 0 ? nil : [items objectAtIndex:0];
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
  NSTimer *timer = [NSTimer timerWithTimeInterval:1
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
  [latestItem release];
  [super release];
}

@end

/**
 Returns the number of seconds the machine has been idle or -1 if an error occurs.
 The code is compatible with Tiger/10.4 and later (but not iOS).

 Source: http://www.danandcheryl.com/2010/06/how-to-check-the-system-idle-time-using-cocoa
 */
int64_t SystemIdleSeconds(void) {
  int64_t idlesecs = -1;
  io_iterator_t iter = 0;
  if (IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iter) == KERN_SUCCESS) {
    io_registry_entry_t entry = IOIteratorNext(iter);
    if (entry) {
      CFMutableDictionaryRef dict = NULL;
      if (IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0) == KERN_SUCCESS) {
        CFNumberRef obj = CFDictionaryGetValue(dict, CFSTR("HIDIdleTime"));
        if (obj) {
          int64_t nanoseconds = 0;
          if (CFNumberGetValue(obj, kCFNumberSInt64Type, &nanoseconds)) {
            idlesecs = (nanoseconds >> 30); // Divide by 10^9 to convert from nanoseconds to seconds.
          }
        }
        CFRelease(dict);
      }
      IOObjectRelease(entry);
    }
    IOObjectRelease(iter);
  }
  return idlesecs;
}
