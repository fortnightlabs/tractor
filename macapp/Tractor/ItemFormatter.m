#import "ItemFormatter.h"

@implementation ItemFormatter

- (NSString *)stringForObjectValue:(id)obj
{
  return [[obj class] description];
}

@end
