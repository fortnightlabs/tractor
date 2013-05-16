#import "ManagedObjectCollection.h"
#import "Project.h"

@interface Projects : ManagedObjectCollection

- (Project *)addProject;
- (Project *)findOrAddProjectWithName:(NSString *)name;
- (void)removeProjectWithName:(NSString *)name;
- (NSArray *)all;

@end
