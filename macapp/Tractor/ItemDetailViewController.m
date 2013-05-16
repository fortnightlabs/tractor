//
//  ItemDetailViewController.m
//  Tractor
//
//  Created by Gerad Suyderhoud on 4/26/13.
//
//

#import "ItemDetailViewController.h"
#import "Item.h"

@interface ItemDetailViewController ()

@end

@implementation ItemDetailViewController

@synthesize currentItem;
@synthesize context;

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      currentItem = nil;
      addProjectSheetController = nil;
    }
    
    return self;
}

- (void)dealloc
{

  [currentItem release], currentItem = nil;
  [addProjectSheetController release], addProjectSheetController = nil;

  [super dealloc];
}

#pragma mark - Accessors

- (void)setCurrentItem:(ItemGroup *)item
{
  [currentItem autorelease];
  currentItem = [item retain];

  if (item) {
    NSString *label = nil;
    
    // time
    label = [NSString stringWithFormat:@"%@ - %@\n", [item startString], [item durationDescription]];
    [timeLabel setStringValue:label];
    
    // app name
    if ([item app] && ([[item app] length] > 0)) {
      label = [item app];
    } else {
      label = @"Away";
    }
    [nameLabel setStringValue:label];
    
    Project *currentProject = [self currentProject];
    NSString *pickerTitle = currentProject ? [currentProject name] : @"Project…";
    [projectPicker setTitle:pickerTitle];
    [projectPicker setHidden:NO];
  } else {
    [timeLabel setStringValue:@""];
    [nameLabel setStringValue:@""];
    [projectPicker setHidden:YES];
  }
  
  // files
  [fileTable reloadData];
}

- (Project *)currentProject
{
  return [[[currentItem items] objectAtIndex:0] project];
}

- (void)setCurrentProject:(Project *)project
{
  for (Item *item in [currentItem items]) {
    [item setProject:project];
  }
}

#pragma mark - fileTable

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return [[currentItem items] count];
}

- (id)              tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
                          row:(NSInteger)row
{
  NSString *columnId = [tableColumn identifier];
  NSString *value = @"";
  
  NSArray *reversedItems = [[[currentItem items] reverseObjectEnumerator] allObjects];
  
  Item *item = [reversedItems objectAtIndex:row];
  if ([columnId isEqualToString:@"time"]) {
    value = [item startString];
  } else if ([columnId isEqualToString:@"file"]) {
    value = [item fileName];
  } else if ([columnId isEqualToString:@"duration"]) {
    value = [item durationDescription];
  }

  return value;
}

#pragma mark - projectPicker

- (void)menuNeedsUpdate:(NSMenu *)menu
{  
  [menu removeAllItems];

  [noneProjectMenuItem setTitle:@""];
  [menu addItem:noneProjectMenuItem];
  [noneProjectMenuItem setState:NSOffState];

  Projects *projects = [context projects];
  Project *currentProject = [self currentProject];
  for (Project *project in [projects all]) {
    NSMenuItem *projectItem = [menu addItemWithTitle:[project name] action:nil keyEquivalent:@""];
    NSCellStateValue projectState = (project == currentProject ? NSOnState : NSOffState);
    [projectItem setState:projectState];
  }

  [menu addItem:otherProjectMenuItem];
  [otherProjectMenuItem setState:NSOffState];
}

- (void)menuDidClose:(NSMenu *)menu
{
  NSMenuItem *highlightedItem = [menu highlightedItem];
  if ([otherProjectMenuItem isEqualTo:highlightedItem]) {
    [self showAddProjectSheet];
  } else if (![otherProjectMenuItem isEqualTo:highlightedItem]) {
    NSString *projectName = [highlightedItem title];
    Project *pickedProject = [[[self context] projects] findOrAddProjectWithName:projectName];
    [self setCurrentProject:pickedProject];
  }

  [noneProjectMenuItem setTitle:@"Project…"];
}

- (AddProjectSheetController *)addProjectSheetController
{
  if (!addProjectSheetController) {
    addProjectSheetController = [[AddProjectSheetController alloc] initWithWindowNibName:@"AddProjectSheet"];
    [addProjectSheetController setProjects:[[self context] projects]];
  }
  
  return addProjectSheetController;
}

- (void)showAddProjectSheet
{

  NSWindow *currentWindow = [[self view] window];
  NSWindow *sheet = [[self addProjectSheetController] window];

  [NSApp beginSheet:sheet
     modalForWindow:currentWindow
      modalDelegate:self
     didEndSelector:@selector(addProjectSheetDidEnd:returnCode:contextInfo:)
        contextInfo:nil];
}

- (void)addProjectSheetDidEnd:(NSWindow *)sheet
                   returnCode:(NSInteger)returnCode
                  contextInfo:(void *)contextInfo
{
  Project *addedProject = [[self addProjectSheetController] currentProject];
  if(addedProject) {
    NSString *projectName = [addedProject name];

    // make the added project the last item before the "Other…" index at the end
    NSUInteger addIndex = [[projectPicker itemArray] count] - 1;

    [projectPicker insertItemWithTitle:projectName atIndex:addIndex];
    [projectPicker selectItemAtIndex:addIndex];
    
    [self setCurrentProject:addedProject];
  } else {
    [projectPicker selectItemAtIndex:0];
  }

  [sheet orderOut:self];
}

@end
