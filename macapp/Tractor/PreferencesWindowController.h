#import <Cocoa/Cocoa.h>
#import "ManagedObjectContext.h"
#import "ProjectPreferencesViewController.h"

@interface PreferencesWindowController : NSWindowController {
  IBOutlet NSToolbar *toolbar;

  ProjectPreferencesViewController *projectPreferencesViewController;
}

@property (nonatomic, retain) ManagedObjectContext *context;

- (IBAction)showProjectPreferences:(id)sender;
- (ProjectPreferencesViewController *)projectPreferencesViewController;


@end
