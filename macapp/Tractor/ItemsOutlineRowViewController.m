#import "ItemsOutlineRowViewController.h"

@implementation ItemsOutlineRowViewController

- (id)initWithItem:(id)item
{
  if ([super init]) {
    [self setItem:item];
  }
  return self;
}

- (void)dealloc
{
  [self setItem:nil];
  [super dealloc];
}

- (NSString *)viewIdentifierForTableColumn:(NSTableColumn *)tableColumn
{
  return [tableColumn identifier];
}

+ (NSSet *)keyPathsForValuesAffectingProject {
  return [NSSet setWithObjects:@"item.project", nil];
}

@end
