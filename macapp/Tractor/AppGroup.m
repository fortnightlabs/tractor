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
  [self setProject:nil];

  for (Item *item in [self items]) {
    [item removeObserver:self forKeyPath:@"project"];
  }

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

- (void)setItemsProject:(Project *)project
{
  _settingItemsProject = YES;
  for (Item *item in [self items]) {
    [item setProject:project];
  }
  _settingItemsProject = NO;
  [self setProject:project];
}

#pragma mark - Item methods

- (void)addItem:(Item *)item
{
  [_items addObject:item];

  [self updateDuration:[item duration]];
  [self updateStart:[item start]];
  [self updateProject:[item project]];
  [self observeProjectChangeForItem:item];
}

- (void)updateDuration:(NSTimeInterval)duration;
{
  _duration += duration;
}

- (void)updateStart:(NSDate *)start
{
  if (!_start || ([start compare:_start] == NSOrderedAscending)) {
    [_start release];
    _start = [start retain];
  }
}

- (void)updateProject:(Project *)project
{
  if ([[self items] count] == 1) {
    [self setProject:project];
  } else if (project != [self project]) {
    [self setProject:nil];
  }
}

- (void)recaclulateProject
{
  Project *project = [[[self items] objectAtIndex:0] project];

  for (Item *item in [self items]) {
    if ([item project] != project) {
      project = nil;
      break;
    }
  }

  [self setProject:project];
}

- (void)observeProjectChangeForItem:(Item *)item
{
  [item addObserver:self
         forKeyPath:@"project"
            options:(NSKeyValueObservingOptionNew |
                        NSKeyValueObservingOptionOld)
            context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqual:@"project"]) {
    if (!_settingItemsProject) {
      [self recaclulateProject];
    }
  }
}

@end