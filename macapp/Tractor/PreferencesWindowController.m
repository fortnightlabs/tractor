#import "PreferencesWindowController.h"

@implementation PreferencesWindowController

#pragma mark - Properties

@synthesize context;

#pragma mark - Lifecycle

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    projectPreferencesViewController = nil;
  }

  return self;
}

- (void)windowDidLoad
{
  [toolbar setSelectedItemIdentifier:@"Projects"];
  [self showProjectPreferences:self];
  [super windowDidLoad];
}

- (void)dealloc
{
  [projectPreferencesViewController release], projectPreferencesViewController = nil;
  [super dealloc];
}

#pragma mark - Actions

- (ProjectPreferencesViewController *)projectPreferencesViewController
{
  if (!projectPreferencesViewController) {
    projectPreferencesViewController = [[ProjectPreferencesViewController alloc] initWithNibName:@"ProjectPreferencesView" bundle:nil];
    [projectPreferencesViewController setProjects:[context projects]];
  }

  return projectPreferencesViewController;
}

- (IBAction)showProjectPreferences:(id)sender
{
  NSView *projectView = [[self projectPreferencesViewController] view];
  [[self window] setContentView:projectView];
}

@end
