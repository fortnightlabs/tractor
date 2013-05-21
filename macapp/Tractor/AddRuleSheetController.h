#import <Cocoa/Cocoa.h>
#import "ManagedObjectContext.h"

@interface AddRuleSheetController : NSWindowController {
  IBOutlet NSPredicateEditor *predicateEditor;
  IBOutlet NSPopUpButton *anyAllButton;
  IBOutlet NSButton *addRuleButton;

  IBOutlet NSArrayController *projectsArrayController;
}

@property (nonatomic, retain) ManagedObjectContext *context;

- (IBAction)cancel:(id)sender;
- (IBAction)addRule:(id)sender;

- (NSPredicate *)predicate;

@end
