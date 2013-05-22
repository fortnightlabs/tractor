#import "TractorController.h"
#include <IOKit/IOKitLib.h>
#include "Rule.h"

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

#pragma mark - Lifecycle

- (id)initWithManagedObjectContext:(ManagedObjectContext *)managedObjectContext;
{
  self = [super init];
  if (self) {
    context = [managedObjectContext retain];
    informer = [[CurrentApplicationInformer alloc] init];
    latestItem = [[context items] latestItem];

    [self observeWillSleepNotification];
    
    [self checkCurrentState:nil];
  }
  
  return self;
}

- (void)dealloc
{
  [context release], context = nil;
  [informer release], informer = nil;
  [latestItem release], latestItem = nil;
  [super dealloc];
}

#pragma mark - Methods

- (void)checkCurrentState:(NSTimer *)timer
{
  NSDate *start = nil;
  NSDate *idleAt;
  NSDate *delayedAt;
  NSString *name = nil;
  NSDictionary *info = nil;

  if ((idleAt = [self idleAt])) {
    // NSLog(@"Idle at: %@", idleAt);
    start = idleAt;
  } else if ((delayedAt = [self delayedAt])) {
    // NSLog(@"Delayed at: %@", delayedAt);
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
  NSError *error;
  NSData *infoData = nil;
  
  if (info) {
    infoData = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
    if (error) {
//      NSLog(@"Error serializing info: %@", error);
    }
  }

  // TODO handle when now is before start (can happen due to idle time)

  if ([latestItem matchesApp:name andInfoData:infoData]) {
    [latestItem setEnd:now]; // update the end time
    // NSLog(@"Updated %@", latestItem);
  } else {
    [latestItem setEnd:start]; // update the previous item's end time
    // NSLog(@"Finished %@", latestItem);
    
    // insert a new item
    [latestItem release];
    latestItem = [[context items] addItem];
    [latestItem retain];

    [latestItem setStart:start];
    [latestItem setEnd:now];

    if (name) { [latestItem setApp:name]; }
    if (info) { [latestItem setInfo:infoData]; }
    // NSLog(@"Started %@", latestItem);

    [latestItem applyRules:[[context rules] all]];
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

- (void)checkStateAgainInOneSecond
{
  NSTimer *timer = [NSTimer timerWithTimeInterval:1
                                           target:self
                                         selector:@selector(checkCurrentState:)
                                         userInfo:nil
                                          repeats:NO];
  
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
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
