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
  
  ret = [self findProjectWithName:name];
  if (!ret) {
    ret = [self addProject];
    [ret setName:name];
  }

  return ret;
}

- (Project *)findProjectWithName:(NSString *)name
{
  FetchRequest *request = [self request];
  [request filter:@"name = %@", name];
  return [request first];
}

- (void)removeProjectWithName:(NSString *)name
{
  Project *project = [self findProjectWithName:name];
  if (project) {
    [context deleteObject:project];
  }
}

- (NSArray *)all
{
  FetchRequest *request = [self request];
  [request sortBy:@"name" ascending:YES];
  return [request all];
}

@end
