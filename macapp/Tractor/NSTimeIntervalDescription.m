//
//  NSTimeIntervalDescription.c
//  Tractor
//
//  Created by Gerad Suyderhoud on 4/30/13.
//
//

#import "NSTimeIntervalDescription.h"

NSString *NSTimeIntervalDescription(NSTimeInterval interval)
{
  NSString *desc = nil;

  if (interval < 0) {
    desc = @"0s";
  } else if (interval < 60) {
    desc = [NSString stringWithFormat:@"%.0fs", interval];
  } else if (interval < 3600) {
    desc = [NSString stringWithFormat:@"%.0fm", interval / 60];
  } else {
    desc = [NSString stringWithFormat:@"%.1fh", interval / 3600];
  }

  return desc; 
}
