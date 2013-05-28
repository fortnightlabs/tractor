#import "ItemViewController.h"
#import "Item.h"

@implementation ItemViewController

- (NSString *)viewIdentifierForTableColumn:(NSTableColumn *)tableColumn
{
  NSString *identifier = [super viewIdentifierForTableColumn:tableColumn];

  if ([identifier isEqualToString:@"Name"]) {
    if ([self isUntitled]) {
      identifier = @"ItalicCell";
    } else {
      identifier = @"NormalCell";
    }
  }

  return identifier;
}

- (NSString *)name
{
  NSString *name = nil;
  Item *item = [self item];

  if ([self isAway]) {
    name = [self awayName];
  } else if ([self isUntitled]) {
    name = @"Untitled";
  } else {
    name = [item title];
  }

  return name;
}

- (NSString *)awayName
{
  Item *item = [self item];

  NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc] init] autorelease];
  [timeFormatter setDateStyle:NSDateFormatterNoStyle];
  [timeFormatter setTimeStyle:NSDateFormatterShortStyle];

  NSString *startString = [timeFormatter stringFromDate:[item start]];
  NSString *endString = [timeFormatter stringFromDate:[item end]];

  return [NSString stringWithFormat:@"Away from %@ to %@", startString, endString];
}

- (NSTimeInterval)duration
{
  Item *item = [self item];
  return [item duration];
}

- (NSDate *)start
{
  Item *item = [self item];
  return [item start];
}

- (Project *)project
{
  Item *item = [self item];
  return [item project];
}

- (void)setProject:(Project *)project
{
  Item *item = [self item];
  [item setProject:project];
}

- (BOOL)isUntitled
{
  Item *item = [self item];
  return [[item title] length] == 0;
}

- (BOOL)isAway
{
  Item *item = [self item];
  return ![item app];
}

@end
