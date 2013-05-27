#import <Cocoa/Cocoa.h>
#import "Projects.h"
#import "AddProjectSheetControllerDelegate.h"

@interface AddProjectSheetController : NSWindowController {
  IBOutlet NSButton *addButton;
  IBOutlet NSButton *cancelButton;
  IBOutlet NSTextField *projectName;
}

@property (nonatomic, retain) Project *currentProject;
@property (nonatomic, retain) Projects *projects;
@property (nonatomic, assign) id<AddProjectSheetControllerDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)addProject:(id)sender;

- (void)showSheetForWindow:(NSWindow *)window;

@end
