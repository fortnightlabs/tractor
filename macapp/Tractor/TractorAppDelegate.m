#import "TractorAppDelegate.h"
#import "ManagedObjectContext.h"
#import "AssignTimeWindowController.h"
#import "AddRuleSheetController.h"

@implementation TractorAppDelegate

#pragma mark - Lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [self createStatusItem];
  controller = [[TractorController alloc] initWithManagedObjectContext:[self managedObjectContext]];

  assignTimeWindowController = [[[AssignTimeWindowController alloc] initWithWindowNibName:@"AssignTimeWindow"] retain];
  [assignTimeWindowController setContext:[self managedObjectContext]];

  preferencesWindowController = [[[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"] retain];
  [preferencesWindowController setContext:[self managedObjectContext]];

  NSTimeInterval oneMinute = 60 * 1;
  autosaveTimer = [[NSTimer scheduledTimerWithTimeInterval:oneMinute target:self selector:@selector(autosave) userInfo:nil repeats:YES] retain];
}

- (void)dealloc
{
  [autosaveTimer invalidate], [autosaveTimer release], autosaveTimer = nil;
  [controller release];
  [assignTimeWindowController release];
  [preferencesWindowController release];
  [super dealloc];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
  // Save changes in the application's managed object context before the application terminates.
  [[self managedObjectContext] save];
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
  [assignTimeWindowController updateItemsTreeControllerContent];
}

- (IBAction)showPreferences:(id)sender
{
  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [[preferencesWindowController window] makeKeyAndOrderFront:sender];
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

- (void)autosave
{
  NSResponder *responder = [[NSApp keyWindow] firstResponder];
  if (!responder) {
    [[self managedObjectContext] save];
  }
}

@end
