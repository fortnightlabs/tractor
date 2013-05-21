#import <Cocoa/Cocoa.h>
#import "AddRuleSheetController.h"
#import "ManagedObjectContext.h"

@interface RulePreferencesViewController : NSViewController<NSTableViewDataSource> {
  IBOutlet NSArrayController *rulesArrayController;
  IBOutlet NSTableView *rulesTableView;

  AddRuleSheetController *addRuleSheetController;
}

@property (nonatomic, retain) ManagedObjectContext *context;

- (IBAction)showAddRuleSheet:(id)sender;
- (IBAction)removeSelectedRules:(id)sender;

@end
