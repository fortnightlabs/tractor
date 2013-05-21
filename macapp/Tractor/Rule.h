#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project;

@interface Rule : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSData * predicateData;
@property (nonatomic, retain) Project *project;

- (NSPredicate *)predicate;
- (void)setPredicate:(NSPredicate *)predicate;

- (NSPredicate *)expandedPredicate:(NSArray *)keyPaths;

@end
