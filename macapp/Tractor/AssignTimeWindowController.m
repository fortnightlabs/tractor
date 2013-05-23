//
//  AssignTimeWindowController.m
//  Tractor
//
//  Created by Gerad Suyderhoud on 4/24/13.
//
//

#import "AssignTimeWindowController.h"
#import "AppGroup.h"

@implementation AssignTimeWindowController

@synthesize context;

#pragma mark - Lifecycle

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    // initializers
  }

  return self;
}

- (void)dealloc
{
  [self setCurrentDate:nil];
  [super dealloc];
}

- (void)awakeFromNib
{
  [self setCurrentDate:[NSDate date]];
  [datePicker setDateValue:[self currentDate]];
  [self updateItemsTreeControllerContent];
}

#pragma mark - NSDatePickerCellDelegate

-      (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell
  validateProposedDateValue:(NSDate **)proposedDateValue
               timeInterval:(NSTimeInterval *)proposedTimeInterval
{
  if (*proposedDateValue) {
    [self setCurrentDate:*proposedDateValue];
    [self updateItemsTreeControllerContent];
  } else {
    *proposedDateValue = [self currentDate];
  }
}

#pragma mark - NSOutlineViewDelegate

//- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
//{
//  NSString *viewIdentifier = [NSString stringWithFormat:@"%@Cell", [tableColumn identifier]];
//  NSView *view = [outlineView makeViewWithIdentifier:viewIdentifier owner:self];
//  NSLog(@"%@: %@", viewIdentifier, view);
//  return view;
//}

#pragma mark - itemsTreeController

- (void)updateItemsTreeControllerContent
{
  NSArray *items = [[context items] appGroupsForDay:[self currentDate]];
  [itemsTreeController setContent:items];
}

@end
