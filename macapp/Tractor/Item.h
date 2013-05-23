#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project;

@interface Item : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSString * app;
@property (nonatomic, retain) NSData * info;
@property (nonatomic, retain) NSNumber * uploaded;
@property (nonatomic, retain) Project *project;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSString *title;

- (BOOL)matchesApp:(NSString *)app andInfoData:(NSData *)infoData;
- (NSDictionary *)JSONDictionary;
- (NSString *)durationDescription;
- (NSString *)summary;
- (NSString *)startString;
- (NSString *)fileName;

- (void)applyRules:(NSArray *)rules;

@end
