#import "Items.h"

@implementation Items

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
  self = [super init];
  if (self) {
    context = [managedObjectContext retain];
  }

  return self;
}

- (void)save
{
  NSError *error = nil;
  if (![context save:&error]) {
    NSLog(@"Couldn't save: %@", [error localizedDescription]);
  }
}

- (Item *)addItem
{
  return [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                       inManagedObjectContext:context];
}

- (Item *)latestItem
{
  ItemsRequest *request = [self request];
   
  // handle cases where things were added to the db in the future
  // because of manually changing the system clock around
  [request filter:@"start <= %@", [NSDate date]];
  [request sortBy:@"start" ascending:NO];
  return [request first];
}

- (ItemsRequest *)request
{
  return [[[ItemsRequest alloc] initWithManagedObjectContext:context] autorelease];
}

- (void)dumpJSONToFileURL:(NSURL *)url
{
  ItemsRequest *request = [self request];
  
  // filter out items in the future (which can be created from
  // system clock changes)
  [request filter:@"start <= %@", [NSDate date]];
  [request sortBy:@"start" ascending:YES];

  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[request JSONArray] options:0 error:&error];
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

  ItemsRequest *itemsRequest = [self request];
  [itemsRequest sortBy:@"start" ascending:YES];
  // exclude the last item (it's still in progress), and anything already uploaded
  [itemsRequest filter:@"start < %@ AND uploaded = nil", [[self latestItem] start]];
  items = [itemsRequest all];

  NSArray *jsonArray = [ItemsRequest JSONArray:items];
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

- (void)dealloc
{
  [context release];
  [super dealloc];
}

@end
