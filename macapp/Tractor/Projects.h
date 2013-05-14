#import "ManagedObjectCollection.h"
#import "Project.h"

@interface Projects : ManagedObjectCollection

- (Project *)addProject;
- (Project *)findOrAddProjectWithName:(NSString *)name;
- (NSArray *)all;

@end
