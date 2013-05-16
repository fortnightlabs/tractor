//
//  AddProjectSheetController.h
//  Tractor
//
//  Created by Gerad Suyderhoud on 5/1/13.
//
//

#import <Cocoa/Cocoa.h>
#import "Projects.h"

@interface AddProjectSheetController : NSWindowController {
  IBOutlet NSButton *addButton;
  IBOutlet NSButton *cancelButton;
  IBOutlet NSTextField *projectName;
}

@property (nonatomic, retain) Project *currentProject;
@property (nonatomic, retain) Projects *projects;

- (IBAction)cancel:(id)sender;
- (IBAction)addProject:(id)sender;


@end
