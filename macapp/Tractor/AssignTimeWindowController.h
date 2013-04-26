//
//  AssignTimeWindowController.h
//  Tractor
#import <Cocoa/Cocoa.h>
#import "Items.h"
#import "ItemDetailViewController.h"

@interface AssignTimeWindowController : NSWindowController {
  IBOutlet NSTableView *itemsTable;
  IBOutlet NSDatePickerCell *datePicker;
  IBOutlet ItemDetailViewController *itemDetailViewController;
  
  NSArray *tableItems;
  NSDate *currentDate;
}

@property (nonatomic, retain) Items *items;

#pragma mark - datePicker

-      (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell
  validateProposedDateValue:(NSDate **)proposedDateValue
               timeInterval:(NSTimeInterval *)proposedTimeInterval;

#pragma mark - itemsTable
- (void)tableViewSelectionDidChange:(NSNotification *)notification;

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)              tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
                          row:(NSInteger)row;

@end
