//
//  ItemGroup.m
//  Tractor
//
//  Created by Gerad Suyderhoud on 4/30/13.
//
//

#import "ItemGroup.h"
#import "Item.h"
#import "NSTimeIntervalDescription.h"

@implementation ItemGroup

#pragma mark - Lifecycle

- (id)init
{
  NSArray *empty = [NSArray array];
  return [self initWithItems:empty];
}

- (id)initWithItems:(NSArray *)items_
{
  self = [super init];
  if (self) {
    items = [items_ retain];
  }
  return self;
}

- (void)dealloc
{
  [items release];
  items = nil;
  
  [super dealloc];
}

#pragma mark - Accessors

- (NSArray *)items
{
  return items;
}

- (NSTimeInterval)duration
{
  NSTimeInterval duration = 0;

  for (Item *item in items) {
    duration += [item duration];
  }
  
  return duration;
}

- (NSString *)durationDescription
{
  return NSTimeIntervalDescription([self duration]);
}

- (NSDate *)start
{
  NSDate *start = nil;
  NSDate *itemStart = nil;
  
  for (Item *item in items) {
    itemStart = [item start];
    if (!start || ([itemStart compare:start] == NSOrderedAscending)) {
      start = itemStart;
    }
  }
  
  return start;
}

- (NSString *)startString
{
  return [NSDateFormatter localizedStringFromDate:[self start]
                                        dateStyle:NSDateFormatterNoStyle
                                        timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)app
{
  Item *firstItem = [items objectAtIndex:0];
  return [firstItem app];
}

@end