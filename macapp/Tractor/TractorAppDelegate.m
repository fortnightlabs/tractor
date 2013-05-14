#import "TractorAppDelegate.h"
#import "ManagedObjectContext.h"
#import "AssignTimeWindowController.h"

@implementation TractorAppDelegate

#pragma mark - Lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [self createStatusItem];
  controller = [[TractorController alloc] initWithManagedObjectContext:[self managedObjectContext]];
  
  assignTimeWindowController = [[[AssignTimeWindowController alloc] initWithWindowNibName:@"AssignTimeWindow"] retain];
  [assignTimeWindowController setContext:[self managedObjectContext]];
}

- (void)dealloc
{
  [controller release];
  [assignTimeWindowController release];
  [super dealloc];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
  // Save changes in the application's managed object context before the application terminates.
  [[self managedObjectContext] save];
  return NSTerminateNow;
}

#pragma mark - IBActions

- (IBAction)dumpItems:(id)sender
{
  NSSavePanel *panel = [NSSavePanel savePanel];
  if ([panel runModal] == NSFileHandlingPanelOKButton) {
    [[self items] dumpJSONToFileURL:[panel URL]];
  }
}

- (IBAction)uploadItems:(id)sender
{
  NSURL *url = [NSURL URLWithString:@"http://localhost:8000/items"]; // hardcoded for now
  [[self items] uploadJSONToURL:url];
}

- (IBAction)assignTime:(id)sender
{
  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [[assignTimeWindowController window] makeKeyAndOrderFront:sender];
}

#pragma mark - Methods

- (void)createStatusItem
{
  statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
  [statusItem setImage:[NSImage imageNamed:@"tractor.tiff"]];
  [statusItem setAlternateImage:[NSImage imageNamed:@"tractor-white.tiff"]];
  [statusItem setMenu:statusMenu];
  [statusItem setHighlightMode:YES];
}

- (ManagedObjectContext *)managedObjectContext
{
  return [ManagedObjectContext context];
}

- (Items *)items
{
  return [[self managedObjectContext] items];
}

@end
