#import <Foundation/Foundation.h>
#import "Project.h"

@interface ItemTableRowViewController : NSObject

@property (nonatomic, retain) id item;
@property (nonatomic, readonly) NSString *summary;
@property (nonatomic, readonly) NSImage *icon;
@property (nonatomic, readonly) NSDate *start;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) Project *project;
@property (nonatomic, readonly) NSString *title;

- (id)initWithItem:(id)item;
- (NSString *)viewIdentifierForTableColumn:(NSTableColumn *)tableColumn;

@end
