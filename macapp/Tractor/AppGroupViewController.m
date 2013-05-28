#import "AppGroupViewController.h"
#import "AppGroup.h"

@implementation AppGroupViewController

- (NSString *)viewIdentifierForTableColumn:(NSTableColumn *)tableColumn
{
  NSString *identifier = [super viewIdentifierForTableColumn:tableColumn];

  if ([identifier isEqualToString:@"Name"]) {
    AppGroup *appGroup = [self item];
    if ([appGroup untracked]) {
      identifier = @"ItalicCell";
    } else {
      identifier = @"ApplicationCell";
    }
  }

  return identifier;
}

- (NSString *)name
{
  AppGroup *appGroup = [self item];
  return [appGroup untracked] ? @"Away" : [appGroup app];
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

- (void)setProject:(Project *)project
{
  AppGroup *appGroup = [self item];
  [appGroup setProject:project];
}


@end
