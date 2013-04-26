//
//  ItemDetailViewController.h
//  Tractor
//
//  Created by Gerad Suyderhoud on 4/26/13.
//
//

#import <Cocoa/Cocoa.h>
#import "Item.h"

@interface ItemDetailViewController : NSViewController {
  IBOutlet NSTextField *timeLabel;
  IBOutlet NSTextField *nameLabel;
  IBOutlet NSTableView *fileTable;
}

@property (nonatomic, retain) Item *currentItem;


#pragma mark - filesTable
- (NSUInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)              tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
                          row:(NSInteger)row;

@end
