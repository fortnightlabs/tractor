#import <Foundation/Foundation.h>
#import "Item.h"
#import "Project.h"

@interface AppGroup : NSObject {
  NSMutableArray *_items;
  NSTimeInterval _duration;
  NSDate *_start;
}

- (id)initWithAppName:(NSString *)app;
+ (NSArray *)appGroupsFromItems:(NSArray *)items;

@property (nonatomic, retain) NSString *app;
@property (nonatomic, readonly) Project *project;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSDate *start;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, assign) BOOL untracked;

- (void)addItem:(Item *)item;

@end
