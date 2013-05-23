#import "DurationFormatter.h"
#import "NSTimeIntervalDescription.h"

@implementation DurationFormatter

-(NSString *)stringForObjectValue:(id)obj
{
  NSString *ret = nil;

  if ([obj isKindOfClass:[NSNumber class]]) {
    NSNumber *number = (NSNumber *)obj;
    NSTimeInterval duration = [number floatValue];

    ret = NSTimeIntervalDescription(duration);
  } else {
    ret = [super stringForObjectValue:obj];
  }

  return ret;
}

@end
