#import "Item.h"
#import "JSONKit.h"

#import <time.h>
#import <xlocale.h>
#import <math.h>
static NSString *JSONDate(NSDate *date);

@implementation Item
@dynamic start;
@dynamic end;
@dynamic app;
@dynamic info;

- (BOOL)matchesApp:(NSString *)app andInfoData:(NSData *)infoData;
{
  // matches if both or nil or they are actually equal
  return ((!app && ![self app]) || [[self app] isEqualToString:app])
      && ((!infoData && ![self info]) || [[self info] isEqualToData:infoData]);
}

+ (Item *)insertOrUpdateWithApp:(NSString *)app
                      andInfo:(NSDictionary *)info
      andManagedObjectContext:(NSManagedObjectContext *)context
{
  NSDate *now = [NSDate date];
  Item *latest = [[self class] latestFromManagedObjectContext:context];
  NSData *infoData = [info JSONData];

  if ([latest matchesApp:app andInfoData:infoData]) {
    [latest setEnd:now]; // update the end time
  } else {
    [latest setEnd:now]; // update the previous item's end time

    // insert a new item
    latest = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                           inManagedObjectContext:context];
    [latest setStart:now];
    [latest setEnd:now];
    if (app) { [latest setApp:app]; }
    if (info) { [latest setInfo:infoData]; }
  }

  NSError *error = nil;
  if (![context save:&error]) {
    NSLog(@"Couldn't save: %@", [error localizedDescription]);
  }

  return latest;
}

+ (void)dumpJSONfromManagedObjectContext:(NSManagedObjectContext *)context
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

+ (Item *)latestFromManagedObjectContext:(NSManagedObjectContext *)context
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

  return (Item *)([items count] == 0 ? nil : [items objectAtIndex:0]);
}

- (NSDictionary *)JSONDictionary
{
  NSString *app = [self app];
  NSString *startStr = JSONDate([self start]);
  NSString *endStr = JSONDate([self end]);
  id info = [[self info] objectFromJSONData];

  #define NULLNIL(__x__) ((__x__) ? (__x__) : [NSNull null])
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
    NULLNIL(startStr), @"start",
    NULLNIL(endStr), @"end",
    NULLNIL(app), @"app",
    NULLNIL(info), @"info",
    nil];
  return dict;
}

@end

NSString *JSONDate(NSDate *date) {
  if (!date) { return nil; }
  NSTimeInterval interval = [date timeIntervalSince1970]; // double
  time_t secs = (time_t) interval; // double to long
  long ms = lround((interval - secs) * 1000); // fractional part to milliseconds
  struct tm t;
  gmtime_r(&secs, &t);

  return [NSString stringWithFormat:@"%04d-%02d-%02dT%02d:%02d:%02d.%04dZ",
          t.tm_year + 1900, t.tm_mon + 1, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec, ms];
}
