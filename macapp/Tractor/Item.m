#import "Item.h"
#import "NSTimeIntervalDescription.h"
#import <time.h>
#import <xlocale.h>
#import <math.h>
#import "Rule.h"

static NSString *JSONDate(NSDate *date);

@interface Item (PRIVATE)

- (NSDictionary *)infoDictionary;

@end

@implementation Item
@dynamic start;
@dynamic end;
@dynamic app;
@dynamic info;
@dynamic uploaded;
@dynamic project;

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
  NSDictionary *info = [self infoDictionary];

  #define NULLNIL(__x__) ((__x__) ? (__x__) : [NSNull null])
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
    NULLNIL(startStr), @"start",
    NULLNIL(endStr), @"end",
    NULLNIL(app), @"app",
    NULLNIL(info), @"info",
    nil];
  return dict;
}

- (void)applyRules:(NSArray *)rules
{
  Project *ruleProject = nil;
  NSDictionary *matchDictionary = [NSMutableDictionary dictionaryWithDictionary:[self infoDictionary]];
  [matchDictionary setValue:NULLNIL([self app]) forKey:@"app"];
  NSArray *keyPaths = [matchDictionary allKeys];

  for (Rule *rule in rules) {
    NSPredicate *predicate = [rule expandedPredicate:keyPaths]; //[NSPredicate predicateWithFormat:@"app CONTAINS %@", @"o"];
    if ([predicate evaluateWithObject:matchDictionary]) {
      ruleProject = [rule project];
      break;
    }
  }

  if (ruleProject) {
    [self setProject:ruleProject];
  }
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ (%@ - %@)", [self app], [self start], [self end]];
}

- (NSTimeInterval)duration
{
  return [[self end] timeIntervalSinceDate:[self start]];
}

- (NSString *)durationDescription
{
  return NSTimeIntervalDescription([self duration]);
}

- (NSString *)startString
{
  return [NSDateFormatter localizedStringFromDate:[self start]
                                        dateStyle:NSDateFormatterNoStyle
                                        timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)summary
{
  NSString *summary = @"";
  NSString *val = nil;
  
  NSDictionary *info = [self infoDictionary];
  
  // start / duration
  summary = [summary stringByAppendingFormat:@"%@ - %@\n", [self startString], [self durationDescription]];

  // name
  if ((val = [self app]) && ([val length] > 0)) {
    summary = [summary stringByAppendingFormat:@"%@\n", val];
  } else {
    summary = [summary stringByAppendingString:@"Away"];
  }
  
  // title
  if (info && (val = [info objectForKey:@"title"]) && ([val length] > 0)) {
    summary = [summary stringByAppendingFormat:@"\nTitle: %@", val];
  }

  // path
  if (info && (val = [info objectForKey:@"path"]) && ([val length] > 0)) {
    summary = [summary stringByAppendingFormat:@"\nFile: %@", val];
  }

  // url
  if (info && (val = [info objectForKey:@"url"]) && ([val length] > 0)) {
    summary = [summary stringByAppendingFormat:@"\nURL: %@", val];
  }
  
  return summary;
}

- (NSString *)fileName
{
  NSDictionary *info = [self infoDictionary];
  NSString *val = nil;
  NSString *fileName = nil;

  // path
  if (info && (val = [info objectForKey:@"path"]) && ([val length] > 0)) {
    fileName = [val lastPathComponent];
  }

  // title
  if (!fileName && info && (val = [info objectForKey:@"title"]) && ([val length] > 0)) {
    fileName = val;
  }

  // url
  if (info && (val = [info objectForKey:@"url"]) && ([val length] > 0)) {
    NSURL *url = [NSURL URLWithString:val];
    if (!fileName) {
      fileName = [url lastPathComponent];
    }

    fileName = [fileName stringByAppendingFormat:@" | %@", [url host]];
  }

  return fileName;
}

- (NSDictionary *)infoDictionary
{
  NSError *error = nil;
  NSDictionary *info = nil;

  if ([self info]) {
    info = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[self info] options:0 error:&error];
    if (error) {
      NSLog(@"Error deserializing item json: %@", error);
      info = nil;
    }
  }

  return info;
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
