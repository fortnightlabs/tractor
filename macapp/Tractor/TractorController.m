#import "TractorController.h"
#import "JSONKit.h"

#include <IOKit/IOKitLib.h>
static int64_t SystemIdleSeconds(void);

@interface TractorController (PRIVATE)

- (void)checkCurrentState:(NSTimer *)timer;
- (void)checkStateAgainInOneSecond;

- (void)insertOrUpdateItemWithName:(NSString *)name
                           andInfo:(NSDictionary *)info
                           atStart:(NSDate *)start;

- (NSDate *)idleAt;
- (NSDate *)delayedAt;

- (void)receiveWillSleepNotification:(NSNotification*)notification;
- (void)observeWillSleepNotification;

- (void)updateLatestItemFromDataStore;

@end

@implementation TractorController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
  self = [super init];
  if (self) {
    context = [managedObjectContext retain];
    informer = [[CurrentApplicationInformer alloc] init];

    [self observeWillSleepNotification];
    
    [self updateLatestItemFromDataStore];
    [self checkCurrentState:nil];
  }
  
  return self;
}

- (void)checkCurrentState:(NSTimer *)timer
{
  NSDate *start = nil;
  NSDate *idleAt;
  NSDate *delayedAt;
  NSString *name = nil;
  NSDictionary *info = nil;

  if ((idleAt = [self idleAt])) {
    start = idleAt;
  } else if ((delayedAt = [self delayedAt])) {
    start = delayedAt;
  } else {
    CurrentApplicationInfo *app = [informer currentApplicationInfo];
    name = [app name];
    info = [app info];
    start = [NSDate date];
  }
  [self insertOrUpdateItemWithName:name
                           andInfo:info
                           atStart:start];
  
  [self checkStateAgainInOneSecond];
}

- (void)insertOrUpdateItemWithName:(NSString *)name
                           andInfo:(NSDictionary *)info
                           atStart:(NSDate *)start;
{
  NSDate *now = [NSDate date];
  NSData *infoData = [info JSONData];

  // TODO handle when now is before start (can happen due to idle time)

  if ([latestItem matchesApp:name andInfoData:infoData]) {
    [latestItem setEnd:now]; // update the end time
  } else {
    [latestItem setEnd:start]; // update the previous item's end time
    
    // insert a new item
    [latestItem release];
    latestItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                           inManagedObjectContext:context];
    [latestItem retain];

    [latestItem setStart:start];
    [latestItem setEnd:now];

    if (name) { [latestItem setApp:name]; }
    if (info) { [latestItem setInfo:infoData]; }
  }

  NSError *error = nil;
  if (![context save:&error]) {
    NSLog(@"Couldn't save: %@", [error localizedDescription]);
  }
}

// returns the time when the computer became idle, nil if not idle
- (NSDate *)idleAt
{
  NSDate *ret = nil;
  int64_t idleSeconds = SystemIdleSeconds();
  
  // you only become "idle" if you haven't done anything for 5 minutes
  // and once you become idle, we backdate the time it happens
  if (idleSeconds > 5 * 60) { // hardcoded for now
    ret = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)idleSeconds];
  }
  
  return ret;
}

// if an update hasn't occurred in a while, for whatever reason, note it
- (NSDate *)delayedAt
{
  NSDate *ret = nil;
  NSDate *lastEnd = [latestItem end];
  NSTimeInterval secondsSinceLastUpdate = -[lastEnd timeIntervalSinceDate:[NSDate date]];

  // if no updates have happened in the last 60 seconds, assume it
  // became delated at the last update time
  if (secondsSinceLastUpdate > 60) {
    ret = lastEnd;
  }
  
  return ret;
}

// http://stackoverflow.com/questions/6089096/knowing-when-the-system-has-gone-to-sleep-in-a-menu-extra
- (void)receiveWillSleepNotification:(NSNotification*)notification
{
  // record that the computer is going to sleep
  [self insertOrUpdateItemWithName:nil
                           andInfo:nil
                           atStart:[NSDate date]];
}

- (void)observeWillSleepNotification
{
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                         selector:@selector(receiveWillSleepNotification:)
                                                             name:NSWorkspaceWillSleepNotification
                                                           object:nil];
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

- (void)dumpJSONToURL:(NSURL *)url
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
  
  [[json JSONString] writeToURL:url atomically:NO encoding:NSUTF8StringEncoding error:&error];
  if (error) {
    NSLog(@"Couldn't save: %@", [error localizedDescription]);
  }
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
