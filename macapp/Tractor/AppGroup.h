#import <Foundation/Foundation.h>
#import "Item.h"
#import "Project.h"

@interface AppGroup : NSObject {
  NSMutableArray *_items;
  NSTimeInterval _duration;
  NSDate *_start;
}

@property (nonatomic, retain) NSString *app;
@property (nonatomic, assign) Project *project;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSDate *start;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, assign) BOOL untracked;

+ (NSArray *)appGroupsFromItems:(NSArray *)items;

- (id)initWithAppName:(NSString *)app;
- (void)addItem:(Item *)item;

@end
