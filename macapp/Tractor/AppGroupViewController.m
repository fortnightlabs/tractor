#import "AppGroupViewController.h"
#import "AppGroup.h"
#import "ItemViewController.h"

@implementation AppGroupViewController

- (NSString *)viewIdentifierForNameColumn
{
  return [self isUntracked] ? @"ItalicCell" : @"ApplicationCell";
}

- (void)dealloc
{
  [_children release];
  [super dealloc];
}

- (NSString *)name
{
  AppGroup *appGroup = [self item];
  return [self isUntracked] ? @"Away" : [appGroup app];
}

- (NSArray *)children
{
  if (!_children) {
    AppGroup *appGroup = [self item];
    NSArray *items = [appGroup items];

    _children = [[NSMutableArray alloc] initWithCapacity:[items count]];
    for (Item *item in items) {
      ItemViewController *controller = [[ItemViewController alloc] initWithItem:item];
      [_children addObject:controller];
      [controller release];
    }

  }
  return _children;
}

- (NSUInteger)childCount
{
  AppGroup *appGroup = [self item];
  return [[appGroup items] count];
}

- (NSImage *)icon
{
  AppGroup *appGroup = [self item];
  NSImage *icon = nil;
  NSString *app = [appGroup app];

  if (app) {
    NSString *path = [NSString stringWithFormat:@"/Applications/%@.app", [[self item] app]];
    icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
  }

  if (!icon) {
    icon = [NSImage imageNamed:@"NSDefaultApplicationIcon"];
  }

  return icon;
}

- (NSTimeInterval)duration
{
  AppGroup *appGroup = [self item];
  return [appGroup duration];
}

- (Project *)project
{
  AppGroup *appGroup = [self item];
  return [appGroup project];
}

- (void)changeProjectTo:(Project *)project
{
  AppGroup *appGroup = [self item];
  [appGroup setItemsProject:project];
}

- (BOOL)isUntracked
{
  AppGroup *appGroup = [self item];
  return [appGroup untracked];
}


@end
