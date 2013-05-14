#import "Projects.h"

@implementation Projects

#pragma mark - abstract method implementation

- (NSString *)entityName
{
  return @"Project";
}

#pragma mark - project methods

- (Project *)addProject
{
  return [self insertNewObject];
}

- (Project *)findOrAddProjectWithName:(NSString *)name
{
  Project *ret = nil;
  
  FetchRequest *request = [self request];
  [request filter:@"name = %@", name];
  ret = [request first];
  
  if (!ret) {
    ret = [self addProject];
    [ret setName:name];
  }

  return ret;
}

- (NSArray *)all
{
  FetchRequest *request = [self request];
  [request sortBy:@"name" ascending:YES];
  return [request all];
}

@end
