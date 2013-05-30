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

- (NSString *)viewIdentifierForNameColumn
{
  return @"Name";
}

- (void)changeProjectTo:(Project *)project;
{
  // subclasses should implement this
}

+ (NSSet *)keyPathsForValuesAffectingProject
{
  return [NSSet setWithObject:@"item.project"];
}

@end
