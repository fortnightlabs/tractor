#import <Foundation/Foundation.h>
#import "Project.h"

@interface ItemsOutlineRowViewController : NSObject

@property (nonatomic, retain) id item;
@property (nonatomic, readonly) NSArray *children;
@property (nonatomic, readonly) NSUInteger childCount;
@property (nonatomic, readonly) BOOL isLeaf;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) Project *project;
@property (nonatomic, readonly) NSDate *start;
@property (nonatomic, readonly) NSTimeInterval duration;

- (id)initWithItem:(id)item;
- (NSString *)viewIdentifierForNameColumn;

// can't be called `setProject` due to bindings issues (sigh)
- (void)changeProjectTo:(Project *)project;

@end
