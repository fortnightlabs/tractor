#import "CurrentApplicationInformer.h"
#import "Item.h"

@interface CurrentApplicationInformer (PRIVATE)

- (void)checkAgainInOneSecond;

- (NSMutableDictionary *)axInfoForProcessIdentifier:(NSNumber *)processIdentifier;

- (NSDictionary *)sbInfoForBundleIdentifier:(NSString *)bundleIdentifier;
- (NSDictionary *)sbInfoForChrome:(ChromeApplication *)chrome;
- (NSDictionary *)sbInfoForMail:(MailApplication *)mail;
- (NSDictionary *)sbInfoForMessages:(MessagesApplication *)messages;
- (NSDictionary *)sbInfoForSafari:(SafariApplication *)safari;
- (NSDictionary *)sbInfoForSkype:(SkypeApplication *)skype;
- (NSDictionary *)sbInfoForOther:(SBApplication *)application;

- (NSString *)windowNameForSBApplication:(SBApplication *)application;
- (BOOL)isScriptableBundleIdentifier:(NSString *)bundleIdentifier;

- (void)notifyUser:(NSException *)exception name:(NSString *)name;

@end

@implementation CurrentApplicationInfo

@synthesize name;
@synthesize info;

@end

@implementation CurrentApplicationInformer

- (id)init
{
  if (self = [super init]) {
    scriptabilityOfBundleIdentifiers = [[NSMutableDictionary alloc] init];
    notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    sqlite3_open("/Users/visnup/Library/Application Support/Skype/visnup/main.db", &skypeDatabase);
  }
  return self;
}

- (CurrentApplicationInfo *)currentApplicationInfo
{
  NSDictionary *activeApplication = [[NSWorkspace sharedWorkspace] activeApplication];
  NSString *bundleIdentifier = [activeApplication objectForKey:@"NSApplicationBundleIdentifier"];
  CurrentApplicationInfo *app = [[[CurrentApplicationInfo alloc] init] autorelease];
  NSString *name = [activeApplication objectForKey:@"NSApplicationName"];

  NSMutableDictionary *info = [NSMutableDictionary dictionary];

  [app setName:name];
  @try {
    // try to get info from the accessibilty api
    if (AXAPIEnabled()) {
      NSDictionary *axInfo = [self axInfoForProcessIdentifier:[activeApplication objectForKey:@"NSApplicationProcessIdentifier"]];
      [info addEntriesFromDictionary:axInfo];
    }

    // try to get info from the scripting bridge
    if (bundleIdentifier && [self isScriptableBundleIdentifier:bundleIdentifier]) {
      NSDictionary *sbInfo = [self sbInfoForBundleIdentifier:bundleIdentifier];
      [info addEntriesFromDictionary:sbInfo];
    }

    [app setInfo:info];
  }
  @catch (NSException *e) {
    [self notifyUser:e name:name];
  }

  return app;
}

// http://stackoverflow.com/questions/2107657/mac-cocoa-getting-a-list-of-windows-using-accessibility-api
// http://stackoverflow.com/questions/853833/how-can-my-app-detect-a-change-to-another-apps-window
// http://cocoatutorial.grapewave.com/tag/axuielementcopyattributevalue/
- (NSMutableDictionary *)axInfoForProcessIdentifier:(NSNumber *)processIdentifier
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:2];
  pid_t pid = (pid_t) [processIdentifier integerValue];
  AXUIElementRef app = AXUIElementCreateApplication(pid);
  AXUIElementRef frontWindow = nil;
  NSString *title = nil;
  NSString *path = nil;
  AXError err;

  // get the focused window for the application
  err = AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute,
                                      (CFTypeRef *) &frontWindow);
  if (err == kAXErrorSuccess) {
    // get the title for the window
    err = AXUIElementCopyAttributeValue(frontWindow, kAXTitleAttribute, (CFTypeRef *) &title);
    if (err == kAXErrorSuccess) {
      [ret setObject:title forKey:@"title"];
      [title autorelease];
    }
    
    // get the document path for the window
    err = AXUIElementCopyAttributeValue(frontWindow, kAXDocumentAttribute, (CFTypeRef *) &path);
    if (err == kAXErrorSuccess) {
      [ret setObject:path forKey:@"path"];
      [path autorelease];
    }

    CFRelease(frontWindow);
  }

  CFRelease(app);

  return ret;
}

- (NSDictionary *)sbInfoForBundleIdentifier:(NSString *)bundleIdentifier;
{
  SBApplication *application = [SBApplication applicationWithBundleIdentifier:bundleIdentifier];
  NSDictionary *ret = nil;

  if ([application isRunning]) {
    if ([@"com.google.Chrome" isEqual:bundleIdentifier]) {
      ret = [self sbInfoForChrome:(ChromeApplication *) application];
    } else if ([@"com.apple.mail" isEqual:bundleIdentifier]) {
      ret = [self sbInfoForMail:(MailApplication *) application];
    } else if ([@"com.apple.Safari" isEqual:bundleIdentifier] ||
               [@"org.webkit.nightly.WebKit" isEqual:bundleIdentifier]) {
      ret = [self sbInfoForSafari:(SafariApplication *) application];
    } else if ([@"com.apple.iChat" isEqual:bundleIdentifier]) {
      ret = [self sbInfoForMessages:(MessagesApplication *) application];
    } else if ([@"com.skype.skype" isEqual:bundleIdentifier]) {
      ret = [self sbInfoForSkype:(SkypeApplication *) application];
    } else {
      // NSLog(@"BundleIdentifier: %@", bundleIdentifier);
      ret = [self sbInfoForOther:application];
    }
  }

  return ret;
}

- (NSDictionary *)sbInfoForChrome:(ChromeApplication *)chrome
{
  ChromeTab *tab = [[[chrome windows] objectAtIndex:0] activeTab];

  return [NSDictionary dictionaryWithObjectsAndKeys:
      [tab title], @"title",
      [tab URL], @"url",
      nil];
}

- (NSDictionary *)sbInfoForSafari:(SafariApplication *)safari
{
  SafariTab *tab = [[[safari windows] objectAtIndex:0] currentTab];

  return [NSDictionary dictionaryWithObjectsAndKeys:
      [tab name], @"title",
      [tab URL], @"url",
      nil];
}

- (NSDictionary *)sbInfoForMail:(MailApplication *)mail
{
  MailMessageViewer *messageViewer = [[mail messageViewers] objectAtIndex:0];

  NSArray *selectedMessages = [messageViewer selectedMessages];
  MailMessage *mostRecentMessage = [selectedMessages objectAtIndex:0];

  // get the most recent message in the selected set
  for (MailMessage *message in selectedMessages) {
    if ([[message dateReceived] compare:[mostRecentMessage dateReceived]] == NSOrderedDescending) {
      mostRecentMessage = message;
    }
  }

  NSString *sender = [mostRecentMessage sender];
  NSString *subject = [mostRecentMessage subject];
  NSArray *recipients = [[mostRecentMessage recipients] arrayByApplyingSelector:@selector(address)];

  return [NSDictionary dictionaryWithObjectsAndKeys:
      sender, @"sender",
      subject, @"title",
      recipients, @"recipients",
      nil];
}

- (NSDictionary *)sbInfoForMessages:(MessagesApplication *)messages
{
  MessagesChat *activeChat = [[messages chats] lastObject];
  NSArray *recipients = [[activeChat participants] valueForKey:@"name"];

  return [NSDictionary dictionaryWithObjectsAndKeys:
      recipients, @"recipients",
      nil];
}

int skypeTranslateSQLResultToDictionary(void *ret, int argc, char **argv, char **column)
{
  if (argc) {
    // 0 - time, 1 - subject, 2 - recipients
    NSMutableDictionary *dict = (NSMutableDictionary *)ret;
    [dict setValue:[NSString stringWithUTF8String:argv[1]] forKey:@"subject"];
    [dict setValue:[NSString stringWithUTF8String:argv[2]] forKey:@"recipients"];
  }
  
  return 0;
}

- (NSDictionary *)sbInfoForSkype:(SkypeApplication *)skype
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:1];
  NSPredicate *notHidden = [NSPredicate predicateWithFormat:@"visible == TRUE"];
  NSArray *names = [[[skype windows] filteredArrayUsingPredicate:notHidden] valueForKey:@"name"];
  NSString *name = nil;

  for (name in names) {
    if (![name hasPrefix:@"Skype"] && ![name hasSuffix:@"Overlay"]) {
      break;
    }
  }
  
  if (name == nil) name = [names lastObject];

  // strip leading duration ("01:23 | ") from Skype conference calls
  NSError *err = nil;
  NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\d{2}:)+\\d{2} \\| "
                                                                          options:0
                                                                            error:&err];
  if (!err) {
    NSRange range = { .location = 0, .length = [name length] };
    name = [regexp stringByReplacingMatchesInString:name
                                            options:0
                                              range:range
                                       withTemplate:@""];
  }

  [ret setValue:name forKey:@"title"];

  if (skypeDatabase) {
    sqlite3_exec(skypeDatabase, "select begin_timestamp as time, friendlyname as subject, participants as recipients from calls inner join conversations on calls.conv_dbid = conversations.id inner join chats on conversations.chat_dbid = chats.id union select activity_timestamp as time, friendlyname as subject, participants as recipients from chats order by time desc limit 1;", skypeTranslateSQLResultToDictionary, ret, nil);
  }

  return ret;
}

- (NSDictionary *)sbInfoForOther:(SBApplication *)application
{
  NSString *windowName = [self windowNameForSBApplication:application];
  NSDictionary *ret = nil;

  if (windowName) {
    ret = [NSDictionary dictionaryWithObjectsAndKeys:
        windowName, @"title",
        nil];
  }

  return ret;
}

- (NSString *)windowNameForSBApplication:(SBApplication *)application
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

- (BOOL)isScriptableBundleIdentifier:(NSString *)bundleIdentifier
{
  BOOL ret;
  NSNumber *scriptability = [scriptabilityOfBundleIdentifiers objectForKey:bundleIdentifier];

  if (scriptability) {
    ret = [scriptability boolValue];
  } else {
    SBApplication *application = [SBApplication applicationWithBundleIdentifier:bundleIdentifier];

    // it is scriptable if it is a subclass of SBApplication
    ret = ([application isKindOfClass:[SBApplication class]] &&
           ![application isMemberOfClass:[SBApplication class]]);

    // cache the lookup in the dictionary
    [scriptabilityOfBundleIdentifiers setValue:[NSNumber numberWithBool:ret]
                                        forKey:bundleIdentifier];
  }

  return ret;
}

- (void)notifyUser:(NSException *)exception name:(NSString *)name
{
  NSUserNotification *notification = [[NSUserNotification alloc] init];
  [notification setTitle:[NSString stringWithFormat:@"Couldn't Get Details for %@", name]];
  [notification setInformativeText:[NSString stringWithFormat:@"%@", exception]];

  if (![[notificationCenter deliveredNotifications] containsObject:notification]) {
    [notificationCenter deliverNotification:notification];
    NSLog(@"%@", [exception callStackSymbols]);
  }

  [notification release];
}

- (void)dealloc
{
  [scriptabilityOfBundleIdentifiers release];
  if (skypeDatabase) sqlite3_close(skypeDatabase);
  [super dealloc];
}
@end
