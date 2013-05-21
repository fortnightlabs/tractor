#import "PreferencesWindowController.h"

@implementation PreferencesWindowController

#pragma mark - Properties

@synthesize context;

#pragma mark - Lifecycle

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    context = nil;
    projectPreferencesViewController = nil;
    rulePreferencesViewController = nil;
  }

  return self;
}

- (void)windowDidLoad
{
  [self showProjects:self];
  [toolbar setSelectedItemIdentifier:@"Projects"];
  [super windowDidLoad];
}

- (void)dealloc
{
  [context release], context = nil;
  [projectPreferencesViewController release], projectPreferencesViewController = nil;
  [rulePreferencesViewController release], rulePreferencesViewController = nil;
  [super dealloc];
}

#pragma mark - ProjectPreferencesViewController actions

- (ProjectPreferencesViewController *)projectPreferencesViewController
{
  if (!projectPreferencesViewController) {
    projectPreferencesViewController = [[ProjectPreferencesViewController alloc] initWithNibName:@"ProjectPreferencesView" bundle:nil];
    [projectPreferencesViewController setProjects:[context projects]];
  }

  return projectPreferencesViewController;
}

- (IBAction)showProjects:(id)sender
{
  NSView *projectView = [[self projectPreferencesViewController] view];
  [[self window] setContentView:projectView];
}

#pragma mark - RulePreferencesViewController actions

- (RulePreferencesViewController *)rulePreferencesViewController
{
  if (!rulePreferencesViewController) {
    rulePreferencesViewController = [[RulePreferencesViewController alloc] initWithNibName:@"RulePreferencesView" bundle:nil];
    [rulePreferencesViewController setContext:context];
  }

  return rulePreferencesViewController;
}

- (IBAction)showRules:(id)sender
{
  NSView *ruleView = [[self rulePreferencesViewController] view];
  [[self window] setContentView:ruleView];
}


@end
