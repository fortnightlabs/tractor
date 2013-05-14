//
//  AssignTimeWindowController.m
//  Tractor
//
//  Created by Gerad Suyderhoud on 4/24/13.
//
//

#import "AssignTimeWindowController.h"
#import "ItemGroup.h"

@implementation AssignTimeWindowController

@synthesize context;

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

- (void)dealloc
{
  [tableItems release], tableItems = nil;
  [currentDate release], currentDate = nil;
  [super dealloc];
}

- (void)windowDidLoad
{
  [self setCurrentItem:nil];
  [datePicker setDateValue:currentDate];
  [super windowDidLoad];
  [itemDetailViewController setContext:[self context]];
}

#pragma mark - Properties

- (void)setContext:(ManagedObjectContext *)newContext
{
  [context autorelease];
  context = [newContext retain];
  [itemDetailViewController setContext:context];
}

#pragma mark - datePicker

-      (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell
  validateProposedDateValue:(NSDate **)proposedDateValue
               timeInterval:(NSTimeInterval *)proposedTimeInterval
{
  if (*proposedDateValue) {
    [currentDate autorelease];
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
    tableItems = [[[context items] itemGroupsForDay:currentDate] retain];
  }
  return tableItems;
}

#pragma mark - textField

- (void)setCurrentItem:(ItemGroup *)item
{
  [itemDetailViewController setCurrentItem:item];
}

#pragma mark - itemsTable

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
  NSInteger row = [itemsTable selectedRow];
  ItemGroup *item = nil;

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
  ItemGroup *item = [[self tableItems] objectAtIndex:row];
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

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
  return NO;
}


@end
