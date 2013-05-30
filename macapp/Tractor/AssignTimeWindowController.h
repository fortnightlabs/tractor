#import <Cocoa/Cocoa.h>
#import "ManagedObjectContext.h"
#import "AddProjectSheetController.h"

@interface AssignTimeWindowController : NSWindowController<NSDatePickerCellDelegate, NSOutlineViewDelegate, NSWindowDelegate, AddProjectSheetControllerDelegate> {
  IBOutlet NSDatePickerCell *datePicker;
  IBOutlet NSOutlineView *itemsOutlineView;

  IBOutlet NSMenu *projectsMenu;
  IBOutlet NSMenuItem *titleMenuItem;
  IBOutlet NSMenuItem *newProjectMenuItem;
  IBOutlet NSMenuItem *separatorMenuItem;
  IBOutlet NSMenuItem *noProjectMenuItem;

  AddProjectSheetController *addProjectSheetController;
}

@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) ManagedObjectContext *context;
@property (nonatomic, retain) NSArray *items;

- (IBAction)showNewProjectSheet:(id)sender;

@end
