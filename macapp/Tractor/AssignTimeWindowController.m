#import "AssignTimeWindowController.h"
#import "AppGroup.h"
#import "ItemTableRowViewController.h"

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
  [self setItems:nil];
  [self setCurrentDate:nil];
  [addProjectSheetController release];
  [super dealloc];
}

#pragma mark - NSPopupButton

- (IBAction)showNewProjectSheet:(id)sender
{
  [[self addProjectSheetController] showSheetForWindow:[self window]];
}

- (IBAction)assignItemsToProject:(NSMenuItem *)menuItem
{
  Project *project = [[[self context] projects] findOrAddProjectWithName:[menuItem title]];
  NSIndexSet *selectedRowIndexes = [itemsOutlineView selectedRowIndexes];

  [selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger row, BOOL *stop) {
    id item = [itemsOutlineView itemAtRow:row];
    [item setProject:project];
  }];
}

- (void)populateProjectPicker
{
  [titleMenuItem retain];
  [noProjectMenuItem retain];
  [separatorMenuItem retain];
  [newProjectMenuItem retain];

  [projectsMenu removeAllItems];

  [projectsMenu addItem:titleMenuItem];
  [projectsMenu addItem:noProjectMenuItem];

  NSArray *projects = [[[self context] projects] all];
  if ([projects count] > 0) {
    for (Project *project in projects) {
      [projectsMenu addItemWithTitle:[project name]
                              action:@selector(assignItemsToProject:)
                       keyEquivalent:@""];
    }
  } else {
    [separatorMenuItem setHidden:YES];
  }
  [projectsMenu addItem:separatorMenuItem];
  [projectsMenu addItem:newProjectMenuItem];

  [titleMenuItem release];
  [noProjectMenuItem release];
  [separatorMenuItem release];
  [newProjectMenuItem release];
}

#pragma mark - NSWindowDelegate

- (void)windowDidBecomeMain:(NSNotification *)notification
{
  [self populateProjectPicker];

  if (![self currentDate]) {
    [self setCurrentDate:[NSDate date]];
    [datePicker setDateValue:[self currentDate]];
    // [self updateItemsTreeControllerContent]; <- automatically called when the datePicker changes
  } else {
    [self updateItemsTreeControllerContent];
  }
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

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  NSArray *items = item ? [item items] : [self items];
  return [items count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  return [[item items] count] > 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
  NSArray *items = item ? [item items] : [self items];
  return items[index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  return [self rowViewControllerForItem:item];
}

- (ItemTableRowViewController *)rowViewControllerForItem:(id)item
{
  return [[[ItemTableRowViewController alloc] initWithItem:item] autorelease];
}

#pragma mark - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  ItemTableRowViewController *rowViewController = [self rowViewControllerForItem:item];
  NSString *identifier = [rowViewController viewIdentifierForTableColumn:tableColumn];
  return [outlineView makeViewWithIdentifier:identifier owner:self];
}

#pragma mark - itemsTreeController

- (void)updateItemsTreeControllerContent
{
  [self setItems:[[context items] appGroupsForDay:[self currentDate]]];
  [itemsOutlineView reloadData];
}

#pragma mark - addProjectSheetController

- (AddProjectSheetController *)addProjectSheetController
{
  if (!addProjectSheetController) {
    addProjectSheetController = [[AddProjectSheetController alloc] initWithWindowNibName:@"AddProjectSheet"];
    [addProjectSheetController setProjects:[[self context] projects]];
    [addProjectSheetController setDelegate:self];
  }

  return addProjectSheetController;
}

- (void)projectWasAdded:(Project *)project
{
  [context save];
  [self populateProjectPicker];
}


@end
