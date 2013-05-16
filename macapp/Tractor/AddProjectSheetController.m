#import "AddProjectSheetController.h"

@implementation AddProjectSheetController

@synthesize currentProject;
@synthesize projects;

#pragma mark - Lifecycle

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    currentProject = nil;
    projects = nil;
  }
  
  return self;
}

- (void)dealloc {
  [currentProject release], currentProject = nil;
  [projects release], projects = nil;
  [super dealloc];
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  [[self window] setDefaultButtonCell:[addButton cell]];
  [projectName selectText:self];
}

- (void)endSheet
{
  [NSApp endSheet:[self window]];
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
  [self setCurrentProject:nil];
  [self endSheet];
}

- (IBAction)addProject:(id)sender
{
  NSString *name = [projectName stringValue];
  [self setCurrentProject:[self projectWithName:name]];
  [self endSheet];
}

#pragma mark - Methods

- (Project *)projectWithName:(NSString *)name
{
  return [projects findOrAddProjectWithName:name];
}

@end
