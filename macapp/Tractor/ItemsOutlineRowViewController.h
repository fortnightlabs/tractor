#import <Foundation/Foundation.h>
#import "Project.h"

@interface ItemsOutlineRowViewController : NSObject

@property (nonatomic, retain) id item;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, assign) Project *project;
@property (nonatomic, readonly) NSDate *start;
@property (nonatomic, readonly) NSTimeInterval duration;

- (id)initWithItem:(id)item;
- (NSString *)viewIdentifierForTableColumn:(NSTableColumn *)tableColumn;

@end
