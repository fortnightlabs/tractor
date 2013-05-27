#import "AppGroup.h"
#import "NSTimeIntervalDescription.h"

@implementation AppGroup

+ (NSArray *)appGroupsFromItems:(NSArray *)items
{
  NSMutableDictionary *appGroups = [NSMutableDictionary dictionary];
  AppGroup *group = nil, *untracked = nil;

  for (Item *item in items) {
    NSString *appName = [item app];

    if (appName) {
      if (!appGroups[appName]) {
        appGroups[appName] = [[[AppGroup alloc] initWithAppName:appName] autorelease];
      }
      group = appGroups[appName];
    } else {
      if (!untracked) {
        untracked = [[AppGroup alloc] init];
        [untracked setUntracked:YES];
      }
      group = untracked;
    }

    [group addItem:item];
  }

  NSArray *ret;
  if (untracked) {
    ret = [[appGroups allValues] arrayByAddingObject:untracked];
    [untracked release];
  } else {
    ret = [appGroups allValues];
  }

  NSSortDescriptor *descendingDuration = [NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO];
  return [ret sortedArrayUsingDescriptors:@[descendingDuration]];
}

#pragma mark - Lifecycle

- (id)init
{
  self = [super init];
  if (self) {
    _items = [[NSMutableArray alloc] init];
  }
  return self;
}

- (id)initWithAppName:(NSString *)app
{
  [self init];
  [self setApp:app];
  return self;
}

- (void)dealloc
{
  [self setApp:nil];
  [_items release], _items = nil;
  [super dealloc];
}

#pragma mark - Accessors

- (NSString *)title
{
  return [NSString stringWithFormat:@"%lu items", [_items count]];
}

- (NSString *)start
{
  return nil;
}

- (void)setProject:(Project *)project
{
  for (Item *item in [self items]) {
    [item setProject:project];
  }
}

- (Project *)project
{
  return nil;
}

#pragma mark - Item methods

- (void)addItem:(Item *)item
{
  [_items addObject:item];

  // update duration
  _duration += [item duration];

  // update start
  NSDate *itemStart = [item start];
  if (!_start || ([itemStart compare:_start] == NSOrderedAscending)) {
    [_start release];
    _start = [itemStart retain];
  }
}

@end