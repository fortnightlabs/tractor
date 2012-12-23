#import <Cocoa/Cocoa.h>
#import "TractorController.h"

@interface TractorAppDelegate : NSObject <NSApplicationDelegate> {
  NSStatusItem *statusItem;
  IBOutlet NSMenu *statusMenu;

  Items *items;
  TractorController *controller;

}

- (IBAction)dumpItems:(id)sender;
- (IBAction)uploadItems:(id)sender;

@end
