#import "TractorAppDelegate.h"
#import "ManagedObjectContext.h"

@interface TractorAppDelegate (PRIVATE)

- (void)createStatusItem;
- (NSManagedObjectContext *)managedObjectContext;

@end

@implementation TractorAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [self createStatusItem];
  items = [[Items alloc] initWithManagedObjectContext:[self managedObjectContext]];
  controller = [[TractorController alloc] initWithItems:items];
}

- (IBAction)dumpItems:(id)sender
{
  NSSavePanel *panel = [NSSavePanel savePanel];
  if ([panel runModal] == NSFileHandlingPanelOKButton) {
    [items dumpJSONToFileURL:[panel URL]];    
  }
}

- (IBAction)uploadItems:(id)sender
{
  NSURL *url = [NSURL URLWithString:@"http://localhost:8000/items"]; // hardcoded for now
  [items uploadJSONToURL:url];
}

- (void)createStatusItem
{
  statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
  [statusItem setImage:[NSImage imageNamed:@"tractor.tiff"]];
  [statusItem setAlternateImage:[NSImage imageNamed:@"tractor-white.tiff"]];
  [statusItem setMenu:statusMenu];
  [statusItem setHighlightMode:YES];
}

- (NSManagedObjectContext *)managedObjectContext
{
  return [ManagedObjectContext context];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (![self managedObjectContext]) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void)dealloc
{
  [controller release];
  [items release];
  [super dealloc];
}

@end
