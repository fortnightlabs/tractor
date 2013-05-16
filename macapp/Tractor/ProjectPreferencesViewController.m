#import "ProjectPreferencesViewController.h"

@implementation ProjectPreferencesViewController

#pragma mark - Properties

@synthesize projects;

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    projects = nil;
    addProjectSheetController = nil;
  }

  return self;
}

- (void)dealloc
{
  [projects release], projects = nil;
  [addProjectSheetController release], addProjectSheetController = nil;
  [super dealloc];
}

- (void)loadView
{
  [super loadView];
  [self viewDidLoad];
}

- (void)viewDidLoad
{
  [self loadProjectsTable];
}

#pragma mark - Actions

- (IBAction)addProject:(id)sender
{
  [self showAddProjectSheet];
}

- (IBAction)removeProject:(id)sender
{
  NSInteger selectedIndex = [projectsTable selectedRow];
  if (selectedIndex >= 0) {
    [projectsArrayController removeObjectAtArrangedObjectIndex:selectedIndex];
  }
}

#pragma mark - Projects Table Methods

- (void)loadProjectsTable
{
  if (![projectsArrayController managedObjectContext]) {
    [projectsArrayController setManagedObjectContext:[projects context]];

    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [projectsArrayController setSortDescriptors:@[sortByName]];
    NSError *error;
    [projectsArrayController fetchWithRequest:nil merge:YES error:&error];
  }
}

#pragma mark - Add Project Sheet Methods

- (AddProjectSheetController *)addProjectSheetController
{
  if (!addProjectSheetController) {
    addProjectSheetController = [[AddProjectSheetController alloc] initWithWindowNibName:@"AddProjectSheet"];
    [addProjectSheetController setProjects:projects];
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
  [sheet orderOut:self];
}



@end
