//
//  ItemGroup.h
//  Tractor
//
//  Created by Gerad Suyderhoud on 4/30/13.
//
//

#import <Foundation/Foundation.h>

@interface ItemGroup : NSObject {
  NSArray *items;
}

#pragma mark - Lifecycle
- (id)initWithItems:(NSArray *)items;

#pragma mark - Accessors

- (NSArray *)items;
- (NSString *)app;
- (NSString *)startString;
- (NSString *)durationDescription;

@end
