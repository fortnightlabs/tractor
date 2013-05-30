#import "ItemViewController.h"
#import "ItemsOutlineRowViewController.h"

@interface AppGroupViewController : ItemsOutlineRowViewController {
  NSMutableArray *_children;
}

@property (nonatomic, readonly) NSImage *icon;

@end
