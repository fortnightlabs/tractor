#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSString * app;
@property (nonatomic, retain) NSData * info;

- (BOOL)matchesApp:(NSString *)app andInfoData:(NSData *)infoData;
- (NSDictionary *)JSONDictionary;

+ (Item *)insertOrUpdateWithApp:(NSString *)app
                        andInfo:(NSDictionary *)info
        andManagedObjectContext:(NSManagedObjectContext *)context;
+ (Item *)latestFromManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)dumpJSONfromManagedObjectContext:(NSManagedObjectContext *)context;


@end
