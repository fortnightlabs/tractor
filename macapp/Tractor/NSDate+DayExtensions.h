//
//  NSDate+DayExtensions.h
//  Tractor
//
//  Created by Gerad Suyderhoud on 4/25/13.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (DayExtensions)

- (NSDate *)beginningOfDay; // returns the first moment of the day
- (NSDate *)endOfDay; // returns the last moment of the day

@end
