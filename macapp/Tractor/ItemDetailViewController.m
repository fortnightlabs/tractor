//
//  ItemDetailViewController.m
//  Tractor
//
//  Created by Gerad Suyderhoud on 4/26/13.
//
//

#import "ItemDetailViewController.h"

@interface ItemDetailViewController ()

@end

@implementation ItemDetailViewController

@synthesize currentItem;

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - Accessors

- (void)setCurrentItem:(Item *)item
{
  [currentItem autorelease];
  currentItem = [item retain];

  if (item) {
    NSString *label = nil;
    
    // time
    label = [NSString stringWithFormat:@"%@ - %@\n", [item startString], [item durationDescription]];
    [timeLabel setStringValue:label];
    
    // app name
    if ([item app] && ([[item app] length] > 0)) {
      label = [item app];
    } else {
      label = @"Away";
    }
    [nameLabel setStringValue:label];
  } else {
    [timeLabel setStringValue:@""];
    [nameLabel setStringValue:@""];
  }
  
  // files
  [fileTable reloadData];
}

#pragma mark - fileTable

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return [currentItem fileName] ? 1 : 0;
}

- (id)              tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
                          row:(NSInteger)row
{
  return [currentItem fileName];
}



@end
