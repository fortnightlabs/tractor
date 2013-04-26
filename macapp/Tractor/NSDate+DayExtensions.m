#import "NSDate+DayExtensions.h"

@implementation NSDate (DayExtensions)

- (NSDate *)beginningOfDay
{
  NSCalendar *cal = [NSCalendar currentCalendar];
  
  NSUInteger components = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
  NSDateComponents *comps = [cal components:components fromDate:self];

  return [cal dateFromComponents:comps];
}

- (NSDate *)endOfDay
{
  NSTimeInterval oneDay = 24 * 60 * 60;
  return [[self beginningOfDay] dateByAddingTimeInterval:oneDay];
}

@end
