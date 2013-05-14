#import <Cocoa/Cocoa.h>
#import "ItemGroup.h"
#import "AddProjectSheetController.h"
#import "ManagedObjectContext.h"
#import "Project.h"

@interface ItemDetailViewController : NSViewController {
  IBOutlet NSTextField *timeLabel;
  IBOutlet NSTextField *nameLabel;
  IBOutlet NSTableView *fileTable;
  IBOutlet NSPopUpButton *projectPicker;
  IBOutlet NSMenuItem *noneProjectMenuItem;
  IBOutlet NSMenuItem *otherProjectMenuItem;

  AddProjectSheetController *addProjectSheetController;
}

@property (nonatomic, retain) ItemGroup *currentItem;
@property (nonatomic, retain) ManagedObjectContext *context;

#pragma mark - filesTable
- (NSUInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)              tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
                          row:(NSInteger)row;
- (void)addProjectSheetDidEnd:(NSWindow *)sheet
                   returnCode:(NSInteger)returnCode
                  contextInfo:(void *)contextInfo;

@end
