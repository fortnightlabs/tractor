#import <Foundation/Foundation.h>
#import "Item.h"
#import "Project.h"

@interface AppGroup : NSObject {
  NSMutableArray *_items;
  NSTimeInterval _duration;
  NSDate *_start;
  BOOL _settingItemsProject;
}

@property (nonatomic, retain) NSString *app;
@property (nonatomic, retain) Project *project;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSDate *start;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, assign) BOOL untracked;

+ (NSArray *)appGroupsFromItems:(NSArray *)items;

- (id)initWithAppName:(NSString *)app;
- (void)addItem:(Item *)item;
- (void)setItemsProject:(Project *)project;

@end
