//
//  AssignTimeWindowController.h
//  Tractor
#import <Cocoa/Cocoa.h>
#import "Items.h"

@interface AssignTimeWindowController : NSWindowController {
  IBOutlet NSTextFieldCell *textField;
  IBOutlet NSTableView *itemsTable;
  IBOutlet NSDatePickerCell *datePicker;
  
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
