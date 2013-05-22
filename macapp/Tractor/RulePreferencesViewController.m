#import "RulePreferencesViewController.h"

static NSString *RulesTableDropType = @"RulesTableDropType";

@implementation RulePreferencesViewController

@synthesize context;

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    addRuleSheetController = nil;
    context = nil;
  }

  return self;
}

- (void)dealloc
{
  [addRuleSheetController release], addRuleSheetController = nil;
  [context release], context = nil;

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self];

  [super dealloc];
}

- (void)awakeFromNib
{
  [self loadRulesTable];
}

#pragma mark - Rules Table

- (void)loadRulesTable
{
  [rulesArrayController setManagedObjectContext:[context context]];
  NSError *error;
  [rulesArrayController fetchWithRequest:nil merge:YES error:&error];

  NSSortDescriptor *sortByOrder = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
  [rulesArrayController setSortDescriptors:@[sortByOrder]];

  [rulesTableView setDataSource:self];
  [rulesTableView registerForDraggedTypes:@[RulesTableDropType]];
}

#pragma mark - Rules Table Drag & Drop

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pasteboard
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	[pasteboard declareTypes:[NSArray arrayWithObject:RulesTableDropType] owner:self];
	[pasteboard setData:data forType:RulesTableDropType];
	return YES;
}


- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
  NSDragOperation ret = NSDragOperationNone;

	if ([info draggingSource] == rulesTableView) {

		if (operation == NSTableViewDropOn) {
			[tv setDropRow:row dropOperation:NSTableViewDropAbove];
    }

		ret = NSDragOperationMove;
	}

  return ret;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)dropRow dropOperation:(NSTableViewDropOperation)dropOperation
{
  NSPasteboard *pasteboard = [info draggingPasteboard];
  NSData *data = [pasteboard dataForType:RulesTableDropType];
  NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];

  NSUInteger oldRow = 0, newRow;
  NSUInteger beforeDropRow = 0, inDropRow = dropRow, afterDropRow = dropRow + [rowIndexes count];
  for (Rule *rule in [rulesArrayController arrangedObjects]) {
    if ([rowIndexes containsIndex:oldRow]) {
      newRow = inDropRow;
      inDropRow++;
    } else if (oldRow < dropRow) {
      newRow = beforeDropRow;
      beforeDropRow++;
    } else if (oldRow >= dropRow) {
      newRow = afterDropRow;
      afterDropRow++;
    }

    [rule setOrder:[NSNumber numberWithLong:newRow + 1]];
    oldRow++;
  }

  [rulesArrayController rearrangeObjects];
  [context save];

  return YES;
}

#pragma mark - Remove Rule

- (IBAction)removeSelectedRules:(id)sender
{
  [[context rules] removeRules:[rulesArrayController selectedObjects]];
  [context save];
}

#pragma mark - Rule Sheet

- (IBAction)showAddRuleSheet:(id)sender
{
  [self showAddRuleSheet];
}

- (AddRuleSheetController *)addRuleSheetController
{
  if (!addRuleSheetController) {
    addRuleSheetController = [[AddRuleSheetController alloc] initWithWindowNibName:@"AddRuleSheet"];
    [addRuleSheetController setContext:context];
  }

  return addRuleSheetController;
}

- (void)showAddRuleSheet
{
  NSWindow *currentWindow = [[self view] window];
  NSWindow *sheet = [[self addRuleSheetController] window];

  [NSApp beginSheet:sheet
     modalForWindow:currentWindow
      modalDelegate:self
     didEndSelector:@selector(addRuleSheetDidEnd:returnCode:contextInfo:)
        contextInfo:nil];
}

- (void)addRuleSheetDidEnd:(NSWindow *)sheet
                returnCode:(NSInteger)returnCode
               contextInfo:(void *)contextInfo
{
  [sheet orderOut:self];
}


@end
