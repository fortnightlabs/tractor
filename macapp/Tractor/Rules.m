#import "Rules.h"

@implementation Rules

#pragma mark - Abstract method implementation

- (NSString *)entityName
{
  return @"Rule";
}

#pragma mark - Rule methods

- (Rule *)addRule
{
  return [self insertNewObject];
}

- (NSArray *)all
{
  FetchRequest *request = [self request];
  [request sortBy:@"order" ascending:YES];
  return [request all];
}

- (Rule *)last
{
  FetchRequest *request = [self request];
  [request sortBy:@"order" ascending:NO];
  return [request first];
}

- (void)removeRules:(NSArray *)rules
{
  for (Rule *rule in rules) {
    [context deleteObject:rule];
  }
}


@end
