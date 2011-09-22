#import "CurrentApplicationChecker.h"
#import "Item.h"

@interface CurrentApplicationChecker (PRIVATE)

- (void)checkCurrentApplication:(NSTimer *)timer;
- (void)checkAgainInOneSecond;

- (NSDictionary *)infoForBundleIdentifier:(NSString *)bundleIdentifier;
- (NSDictionary *)infoForChrome:(ChromeApplication *)chrome;
- (NSDictionary *)infoForSafari:(SafariApplication *)safari;
- (NSDictionary *)infoForMail:(MailApplication *)mail;
- (NSDictionary *)infoForOther:(SBApplication *)application;

- (NSString *)windowNameForApplication:(SBApplication *)application;

@end

@implementation CurrentApplicationChecker

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
  self = [super init];
  if (self) {
    managedObjectContext = context;
    [self checkCurrentApplication:nil];
  }

  return self;
}

- (void)checkCurrentApplication:(NSTimer *)timer
{
  NSDictionary *activeApplication = [[NSWorkspace sharedWorkspace] activeApplication];
  NSString *appName = [activeApplication objectForKey:@"NSApplicationName"];
  NSString *bundleIdentifier = [activeApplication objectForKey:@"NSApplicationBundleIdentifier"];
  NSDictionary *appInfo = [self infoForBundleIdentifier:bundleIdentifier];

  [Item insertOrUpdateWithApp:appName
                      andInfo:appInfo
      andManagedObjectContext:managedObjectContext];

  [self checkAgainInOneSecond];
}

- (void)checkAgainInOneSecond
{
  NSTimer *timer = [NSTimer timerWithTimeInterval:1 * 10 // 10 seconds for now
                                           target:self
                                         selector:@selector(checkCurrentApplication:)
                                         userInfo:nil
                                          repeats:NO];

  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (NSDictionary *)infoForBundleIdentifier:(NSString *)bundleIdentifier
{
  // NSLog(@"BundleIdentifier: %@", bundleIdentifier);
  SBApplication *application = [SBApplication applicationWithBundleIdentifier:bundleIdentifier];
  NSDictionary *ret = nil;

  // TODO handle more applications
  if ([@"com.google.Chrome" isEqual:bundleIdentifier]) {
    ret = [self infoForChrome:(ChromeApplication *) application];
  } else if ([@"com.apple.mail" isEqual:bundleIdentifier]) {
    ret = [self infoForMail:(MailApplication *) application];
  } else if ([@"com.apple.Safari" isEqual:bundleIdentifier] ||
             [@"org.webkit.nightly.WebKit" isEqual:bundleIdentifier]) {
    ret = [self infoForSafari:(SafariApplication *) application];
  } else {
    ret = [self infoForOther:application];
  }

  return ret;
}

- (NSDictionary *)infoForChrome:(ChromeApplication *)chrome
{
  ChromeTab *tab = [[[chrome windows] objectAtIndex:0] activeTab];

  return [NSDictionary dictionaryWithObjectsAndKeys:
      [tab title], @"title",
      [tab URL], @"url",
      nil];
}

- (NSDictionary *)infoForSafari:(SafariApplication *)safari
{
  SafariTab *tab = [[[safari windows] objectAtIndex:0] currentTab];

  return [NSDictionary dictionaryWithObjectsAndKeys:
      [tab name], @"title",
      [tab URL], @"url",
      nil];
}

- (NSDictionary *)infoForMail:(MailApplication *)mail
{
  MailMessageViewer *messageViewer = [[mail messageViewers] objectAtIndex:0];
  MailMessage *message = [[messageViewer selectedMessages] objectAtIndex:0];
  NSString *sender = [message sender];
  NSString *subject = [message subject];
  NSArray *recipients = [[message recipients] arrayByApplyingSelector:@selector(address)];

  return [NSDictionary dictionaryWithObjectsAndKeys:
      sender, @"sender",
      subject, @"subject",
      recipients, @"recipients",
      nil];
}

- (NSDictionary *)infoForOther:(SBApplication *)application
{
  NSString *windowName = [self windowNameForApplication:application];
  NSDictionary *ret = nil;

  if (windowName) {
    ret = [NSDictionary dictionaryWithObjectsAndKeys:
        windowName, @"title",
        nil];
  }

  return ret;
}

- (NSString *)windowNameForApplication:(SBApplication *)application
{
  NSString *name = nil;
  SEL windowsSelector = @selector(windows);
  SEL nameSelector = @selector(name);
  SBElementArray *windows;
  NSObject *window;

  if ([application respondsToSelector:windowsSelector]) {
    windows = [application performSelector:windowsSelector];
    if ([windows count] > 0) {
      window = [windows objectAtIndex:0];
      if ([window respondsToSelector:nameSelector]) {
        name = [window performSelector:nameSelector];
      }
    }
  }

  return name;
}

@end
