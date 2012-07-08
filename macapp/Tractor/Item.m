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
@dynamic uploaded;

- (BOOL)matchesApp:(NSString *)app andInfoData:(NSData *)infoData;
{
  // matches if both or nil or they are actually equal
  return ((!app && ![self app]) || [[self app] isEqualToString:app])
      && ((!infoData && ![self info]) || [[self info] isEqualToData:infoData]);
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

-(NSString *)description
{
  return [NSString stringWithFormat:@"%@ (%@ - %@)", [self app], [self start], [self end]];
}

@end

NSString *JSONDate(NSDate *date) {
  if (!date) { return nil; }
  NSTimeInterval interval = [date timeIntervalSince1970]; // double
  time_t secs = (time_t) interval; // double to long
  long ms = lround((interval - secs) * 1000); // fractional part to milliseconds
  struct tm t;
  gmtime_r(&secs, &t);

  return [NSString stringWithFormat:@"%04d-%02d-%02dT%02d:%02d:%02d.%04ldZ",
          t.tm_year + 1900, t.tm_mon + 1, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec, ms];
}
