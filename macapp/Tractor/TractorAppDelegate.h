#import <Cocoa/Cocoa.h>
#import "TractorController.h"
#import "AssignTimeWindowController.h"
#import "PreferencesWindowController.h"

@interface TractorAppDelegate : NSObject <NSApplicationDelegate> {
  NSStatusItem *statusItem;
  IBOutlet NSMenu *statusMenu;

  TractorController *controller;
  AssignTimeWindowController *assignTimeWindowController;
  PreferencesWindowController *preferencesWindowController;
}

- (IBAction)dumpItems:(id)sender;
- (IBAction)uploadItems:(id)sender;
- (IBAction)assignTime:(id)sender;
- (IBAction)showPreferences:(id)sender;

@end
