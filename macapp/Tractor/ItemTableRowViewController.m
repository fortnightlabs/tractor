#import "ItemTableRowViewController.h"
#import "AppGroup.h"
#import "Item.h"

@implementation ItemTableRowViewController

- (id)initWithItem:(id)item
{
  if ([super init]) {
    [self setItem:item];
  }
  return self;
}

- (NSString *)viewIdentifierForTableColumn:(NSTableColumn *)tableColumn
{
  NSString *identifier = [tableColumn identifier];

//  if ([item respondsToSelector:@selector(untracked)] && [item untracked] && [identifier isEqualToString:@"Name"]) {
//    view = [outlineView makeViewWithIdentifier:@"AwayCell" owner:self];
//  } else if (![item project] && [identifier isEqualToString:@"Name"]) {
//    view = [outlineView makeViewWithIdentifier:@"NoProjectCell" owner:self];
//  } else {
//    view = [outlineView makeViewWithIdentifier:identifier owner:self];
//  }

  return identifier;
}

- (NSString *)summary
{
  NSString *summary = nil;

  if ([[self item] isKindOfClass:[AppGroup class]]) {
    AppGroup *appGroup = [self item];
    if ([appGroup untracked]) {
      summary = @"Away";
    } else {
      summary = [appGroup app];
    }
  } else {
    summary = [[self item] app];
  }

  return summary;
}

- (NSImage *)icon
{
  NSImage *icon = nil;
  NSString *app = [[self item] app];

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
  return [[self item] duration];
}

- (NSDate *)start
{
  Item *item = [self item];
  return [item start];
}

- (Project *)project
{
  return [[self item] project];
}

@end
