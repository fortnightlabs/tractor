#import <Cocoa/Cocoa.h>
#import "ManagedObjectContext.h"
#import "ProjectPreferencesViewController.h"
#import "RulePreferencesViewController.h"

@interface PreferencesWindowController : NSWindowController {
  IBOutlet NSToolbar *toolbar;

  ProjectPreferencesViewController *projectPreferencesViewController;
  RulePreferencesViewController *rulePreferencesViewController;
}

@property (nonatomic, retain) ManagedObjectContext *context;

- (IBAction)showProjects:(id)sender;
- (IBAction)showRules:(id)sender;

@end
