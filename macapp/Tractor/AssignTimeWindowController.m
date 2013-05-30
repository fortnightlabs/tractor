#import "AssignTimeWindowController.h"
#import "AppGroup.h"
#import "ItemsOutlineRowViewController.h"
#import "ItemViewController.h"
#import "AppGroupViewController.h"

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
    ItemsOutlineRowViewController *controller = [item representedObject];
    [controller changeProjectTo:project];
  }];
}

- (void)populateProjectPicker
{
  [titleMenuItem retain];
  [noProjectMenuItem retain];
  [separatorMenuItem retain];
  [newProjectMenuItem retain];

  NSString *unassignTitle = [noProjectMenuItem title];
  NSFont *italicFont = [NSFont fontWithName:@"Helvetica Oblique" size:9.0];
  NSAttributedString *italicUnassignTitle = [[[NSMutableAttributedString alloc] initWithString: unassignTitle attributes:@{NSFontAttributeName: italicFont }] autorelease];
  [noProjectMenuItem setAttributedTitle:italicUnassignTitle];

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

#pragma mark - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  NSString *identifier = [tableColumn identifier];

  if ([identifier isEqualToString:@"Name"]) {
    ItemsOutlineRowViewController *rowViewController = [item representedObject];
    identifier = [rowViewController viewIdentifierForNameColumn];
  }

  return [outlineView makeViewWithIdentifier:identifier owner:self];
}

#pragma mark - itemsTreeController

- (void)updateItemsTreeControllerContent
{
  NSArray *appGroups = [[context items] appGroupsForDay:[self currentDate]];

  NSMutableArray *controllers = [NSMutableArray arrayWithCapacity:[appGroups count]];
  for (AppGroup *appGroup in appGroups) {
    AppGroupViewController *controller = [[AppGroupViewController alloc] initWithItem:appGroup];
    [controllers addObject:controller];
    [controller release];
  }

  [self setItems:controllers];
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
