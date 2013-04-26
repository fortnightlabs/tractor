#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSString * app;
@property (nonatomic, retain) NSData * info;
@property (nonatomic, retain) NSNumber * uploaded;

- (BOOL)matchesApp:(NSString *)app andInfoData:(NSData *)infoData;
- (NSDictionary *)JSONDictionary;
- (NSTimeInterval)duration;
- (NSString *)durationDescription;
- (NSString *)summary;
- (NSString *)startString;

@end
