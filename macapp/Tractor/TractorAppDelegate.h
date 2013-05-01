#import <Cocoa/Cocoa.h>
#import "TractorController.h"
#import "AssignTimeWindowController.h"

@interface TractorAppDelegate : NSObject <NSApplicationDelegate> {
  NSStatusItem *statusItem;
  IBOutlet NSMenu *statusMenu;

  Items *items;
  TractorController *controller;
  AssignTimeWindowController *assignTimeWindowController;
}

- (IBAction)dumpItems:(id)sender;
- (IBAction)uploadItems:(id)sender;
- (IBAction)assignTime:(id)sender;

@end
