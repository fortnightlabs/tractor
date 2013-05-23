//
//  AssignTimeWindowController.h
//  Tractor
#import <Cocoa/Cocoa.h>
#import "ManagedObjectContext.h"

@interface AssignTimeWindowController : NSWindowController<NSDatePickerCellDelegate, NSOutlineViewDelegate> {
  IBOutlet NSDatePickerCell *datePicker;
  IBOutlet NSTreeController *itemsTreeController;
}

@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) ManagedObjectContext *context;

- (void)updateItemsTreeControllerContent;

@end
