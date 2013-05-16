#import <Cocoa/Cocoa.h>
#import "Projects.h"
#import "AddProjectSheetController.h"

@interface ProjectPreferencesViewController : NSViewController {
  IBOutlet NSArrayController *projectsArrayController;
  IBOutlet NSTableView *projectsTable;

  AddProjectSheetController *addProjectSheetController;
}

@property (nonatomic, retain) Projects *projects;

- (IBAction)addProject:(id)sender;
- (IBAction)removeProject:(id)sender;

@end
