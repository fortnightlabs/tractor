//
//  AssignTimeWindowController.m
//  Tractor
//
//  Created by Gerad Suyderhoud on 4/24/13.
//
//

#import "AssignTimeWindowController.h"
#import "Item.h"

@interface AssignTimeWindowController (PRIVATE)

- (void)setCurrentItem:(Item *)item;

@end

@implementation AssignTimeWindowController

@synthesize items;

#pragma mark - Lifecycle

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    tableItems = nil;
    currentDate = [[NSDate date] retain];
  }
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  [self setCurrentItem:nil];
  [datePicker setDateValue:[NSDate date]];
}

- (void)dealloc
{
  [tableItems release];
  tableItems = nil;
  [currentDate release];
  currentDate = nil;
  [super dealloc];
}

#pragma mark - datePicker

-      (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell
  validateProposedDateValue:(NSDate **)proposedDateValue
               timeInterval:(NSTimeInterval *)proposedTimeInterval
{
  if (*proposedDateValue) {
    [currentDate release];
    currentDate = [*proposedDateValue retain];
    [tableItems release];
    tableItems = nil;
    [itemsTable reloadData];
  } else {
    *proposedDateValue = currentDate;
  }
}

#pragma mark - tableItems

- (NSArray *)tableItems
{
  if (!tableItems) {
    tableItems = [[items itemsForDay:currentDate] retain];
  }
  return tableItems;
}

#pragma mark - textField

- (void)setCurrentItem:(Item *)item
{
  if (item) {
    [textField setStringValue:[item summary]];
  } else {
    [textField setStringValue:@""];
  }
}

#pragma mark - itemsTable

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
  NSInteger row = [itemsTable selectedRow];
  Item *item = nil;

  if (row >= 0) {
    item = [[self tableItems] objectAtIndex:row];
  }

  [self setCurrentItem:item];
}

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return [[self tableItems] count];
}

- (id)              tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
                          row:(NSInteger)row
{
  Item *item = [[self tableItems] objectAtIndex:row];
  NSString *columnId = [tableColumn identifier];
  NSString *value = @"";
  
  if ([columnId isEqualToString:@"time"]) {
    value = [item startString];

  } else if ([columnId isEqualToString:@"app"]) {
    value = [item app];
  } else if ([columnId isEqualToString:@"duration"]) {
    value = [item durationDescription];
  }

  return value;
}

@end
