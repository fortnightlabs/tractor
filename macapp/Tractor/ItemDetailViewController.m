//
//  ItemDetailViewController.m
//  Tractor
//
//  Created by Gerad Suyderhoud on 4/26/13.
//
//

#import "ItemDetailViewController.h"
#import "Item.h"

@interface ItemDetailViewController ()

@end

@implementation ItemDetailViewController

@synthesize currentItem;

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      currentItem = nil;
    }
    
    return self;
}

- (void)dealloc
{

  [currentItem release];
  currentItem = nil;
  [super dealloc];
}

#pragma mark - Accessors

- (void)setCurrentItem:(ItemGroup *)item
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
  return [[currentItem items] count];
}

- (id)              tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
                          row:(NSInteger)row
{
  NSString *columnId = [tableColumn identifier];
  NSString *value = @"";
  
  NSArray *reversedItems = [[[currentItem items] reverseObjectEnumerator] allObjects];
  
  Item *item = [reversedItems objectAtIndex:row];
  if ([columnId isEqualToString:@"time"]) {
    value = [item startString];
  } else if ([columnId isEqualToString:@"file"]) {
    value = [item fileName];
  } else if ([columnId isEqualToString:@"duration"]) {
    value = [item durationDescription];
  }

  return value;
}



@end
