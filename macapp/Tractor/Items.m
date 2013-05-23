#import "Items.h"
#import "AppGroup.h"
#import "Item.h"
#import "NSDate+DayExtensions.h"

@implementation Items

#pragma mark - abstract method implementation

- (NSString *)entityName
{
  return @"Item";
}

#pragma mark - item methods

- (Item *)addItem
{
  return [self insertNewObject];
}

- (Item *)latestItem
{
  FetchRequest *request = [self request];
   
  // handle cases where things were added to the db in the future
  // because of manually changing the system clock around
  [request filter:@"start <= %@", [NSDate date]];
  [request sortBy:@"start" ascending:NO];
  return [request first];
}

- (NSArray *)itemsForDay:(NSDate *)date
{
  
  NSDate *start = [date beginningOfDay];
  NSDate *end = [date endOfDay];

  FetchRequest *request = [self request];
  [request filter:@"start > %@ AND start <= %@", start, end];
  [request sortBy:@"start" ascending:NO];
  return [request all];
}

- (NSArray *)appGroupsForDay:(NSDate *)date
{
  NSArray *items = [self itemsForDay:date];
  return [AppGroup appGroupsFromItems:items];
}


# pragma mark - JSON methods

- (void)dumpJSONToFileURL:(NSURL *)url
{
  FetchRequest *request = [self request];
  
  // filter out items in the future (which can be created from
  // system clock changes)
  [request filter:@"start <= %@", [NSDate date]];
  [request sortBy:@"start" ascending:YES];
  
  NSArray *items = [request all];

  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self JSONArray:items] options:0 error:&error];
  if (!error) {
    [jsonData writeToURL:url atomically:NO];
  }
  if (error) {
    NSLog(@"Couldn't save: %@", [error localizedDescription]);
  }
}

- (void)uploadJSONToURL:(NSURL *)url
{
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  NSHTTPURLResponse *response = nil;
  NSError *error = nil;
  NSArray *items = nil;

  FetchRequest *itemsRequest = [self request];
  [itemsRequest sortBy:@"start" ascending:YES];
  // exclude the last item (it's still in progress), and anything already uploaded
  [itemsRequest filter:@"start < %@ AND uploaded = nil", [[self latestItem] start]];
  items = [itemsRequest all];

  NSArray *jsonArray = [self JSONArray:items];
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:&error];
  if (error) {
    NSLog(@"Could not serialize JSON data %@", error);
    return;
  }
  
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:jsonData];
  [request setHTTPMethod:@"POST"];

  NSData *data = [NSURLConnection sendSynchronousRequest:request
                                       returningResponse:&response
                                                   error:&error];
  NSString *body = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

  if (error) {
    NSLog(@"Couldn't upload: %@", [error localizedDescription]);
  }
  
  if ([response statusCode] != 200) {
    NSLog(@"Couldn't upload: %@", body);
  } else {
    for (Item *item in items) {
      [item setUploaded:[NSNumber numberWithBool:YES]];
    }
  }
}

- (NSArray *)JSONArray:(NSArray *)array
{
  NSMutableArray *json = [NSMutableArray arrayWithCapacity:[array count]];
  for (Item *item in array) {
    [json addObject:[item JSONDictionary]];
  }
  return json;
}

- (void)dealloc
{
  [context release];
  [super dealloc];
}

@end
