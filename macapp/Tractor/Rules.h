#import "ManagedObjectCollection.h"
#import "Rule.h"

@interface Rules : ManagedObjectCollection

- (Rule *)addRule;
- (Rule *)last;
- (NSArray *)all;
- (void)removeRules:(NSArray *)rules;

@end
