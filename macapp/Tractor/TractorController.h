#import <Foundation/Foundation.h>
#import "CurrentApplicationInformer.h"
#import "Items.h"
#import "Item.h"

@interface TractorController : NSObject {
  CurrentApplicationInformer *informer;
  Items *items;
  Item *latestItem;
}

- (id)initWithItems:(Items *)items_;

@end
