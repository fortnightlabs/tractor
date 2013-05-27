#import "AddProjectSheetController.h"

@implementation AddProjectSheetController

#pragma mark - Lifecycle

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    // initialization code goes here
  }
  
  return self;
}

- (void)dealloc {
  [self setCurrentProject:nil];
  [self setProjects:nil];
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
  Project *project = [self projectWithName:name];
  [self setCurrentProject:project];

  if ([[self delegate] respondsToSelector:@selector(projectWasAdded:)]) {
    [[self delegate] projectWasAdded:project];
  }

  [self endSheet];
}

#pragma mark - Methods

- (void)showSheetForWindow:(NSWindow *)currentWindow
{
  NSWindow *sheet = [self window];

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

- (Project *)projectWithName:(NSString *)name
{
  return [[self projects] findOrAddProjectWithName:name];
}

@end
