#import "CurrentApplicationInformer.h"
#import "Item.h"

@interface CurrentApplicationInformer (PRIVATE)

- (void)checkAgainInOneSecond;

- (NSMutableDictionary *)axInfoForProcessIdentifier:(NSNumber *)processIdentifier;

- (NSDictionary *)sbInfoForBundleIdentifier:(NSString *)bundleIdentifier;

NSString *gmailInputValueJavascriptForPart(NSString *part);
- (NSDictionary *)sbInfoForChrome:(ChromeApplication *)chrome;
- (NSDictionary *)sbInfoForSafari:(SafariApplication *)safari;
- (NSDictionary *)sbInfoForMail:(MailApplication *)mail;
- (NSDictionary *)sbInfoForSkype:(SkypeApplication *)skype;
- (NSDictionary *)sbInfoForOther:(SBApplication *)application;

- (NSString *)windowNameForSBApplication:(SBApplication *)application;
- (BOOL)isScriptableBundleIdentifier:(NSString *)bundleIdentifier;

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
    [[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Couldn't Get Details for %@", name]
                     defaultButton:nil
                   alternateButton:nil
                       otherButton:nil
         informativeTextWithFormat:@"%@", e] runModal];
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
    } else if([@"com.skype.skype" isEqual:bundleIdentifier]) {
      ret = [self sbInfoForSkype:(SkypeApplication *) application];
    } else {
      // NSLog(@"BundleIdentifier: %@", bundleIdentifier);
      ret = [self sbInfoForOther:application];
    }
  }

  return ret;
}

NSString *gmailInputValueJavascriptForPart(NSString *part)
{
  return [NSString stringWithFormat:@"window.frames['canvas_frame'].contentDocument.forms[1].elements.%@.value", part];
}

- (NSDictionary *)sbInfoForChrome:(ChromeApplication *)chrome
{
  ChromeTab *tab = [[[chrome windows] objectAtIndex:0] activeTab];

  // TODO DRY this with the safari bits below
  NSString *title = [tab title];
  NSString *url = [tab URL];
  NSString *to = nil, *subject = nil, *cc = nil, *bcc = nil;  
  if ([url hasPrefix:@"https://mail.google.com"] && [title hasPrefix:@"Compose Mail"]) {
    to = [tab executeJavascript:gmailInputValueJavascriptForPart(@"to")];
    subject = [tab executeJavascript:gmailInputValueJavascriptForPart(@"subject")];
    cc = [tab executeJavascript:gmailInputValueJavascriptForPart(@"cc")];
    bcc = [tab executeJavascript:gmailInputValueJavascriptForPart(@"bcc")];
  }

  return [NSDictionary dictionaryWithObjectsAndKeys:
      title, @"title",
      url, @"url",
      to, @"to",
      subject, @"subject",
      cc, @"cc",
      bcc, @"bcc",
      nil];
}

- (NSDictionary *)sbInfoForSafari:(SafariApplication *)safari
{
  SafariTab *tab = [[[safari windows] objectAtIndex:0] currentTab];

  // TODO DRY this with the chrome bits above
  NSString *title = [tab name];
  NSString *url = [tab URL];
  NSString *to = nil, *subject = nil, *cc = nil, *bcc = nil;  
  if ([url hasPrefix:@"https://mail.google.com"] && [title hasPrefix:@"Compose Mail"]) {
    to = [safari doJavaScript:gmailInputValueJavascriptForPart(@"to") in:tab];
    subject = [safari doJavaScript:gmailInputValueJavascriptForPart(@"subject") in:tab];
    cc = [safari doJavaScript:gmailInputValueJavascriptForPart(@"cc") in:tab];
    bcc = [safari doJavaScript:gmailInputValueJavascriptForPart(@"bcc") in:tab];
  }
  
  return [NSDictionary dictionaryWithObjectsAndKeys:
          title, @"title",
          url, @"url",
          to, @"to",
          subject, @"subject",
          cc, @"cc",
          bcc, @"bcc",
          nil];
}

- (NSDictionary *)sbInfoForMail:(MailApplication *)mail
{
  MailMessageViewer *messageViewer = [[mail messageViewers] objectAtIndex:0];
  MailMessage *message = [[messageViewer selectedMessages] objectAtIndex:0];
  NSString *sender = [message sender];
  NSString *subject = [message subject];
  NSArray *recipients = [[message recipients] arrayByApplyingSelector:@selector(address)];

  return [NSDictionary dictionaryWithObjectsAndKeys:
      sender, @"sender",
      subject, @"title",
      recipients, @"recipients",
      nil];
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

  // strip leading duration ("01:23 | ") from Skype conference calls
  NSError *err = nil;
  NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\d{2}:)+\\d{2} \\| "
                                                                          options:0
                                                                            error:&err];
  if (!err && name) {
    NSRange range = { .location = 0, .length = [name length] };
    name = [regexp stringByReplacingMatchesInString:name
                                            options:0
                                              range:range
                                       withTemplate:@""];
  }

  [ret setValue:name forKey:@"title"];
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

- (void)dealloc
{
  [scriptabilityOfBundleIdentifiers release];
  [super dealloc];
}
@end
