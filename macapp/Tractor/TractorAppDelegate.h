#import <Cocoa/Cocoa.h>

@interface TractorAppDelegate : NSObject <NSApplicationDelegate> {
  NSStatusItem *statusItem;
  IBOutlet NSMenu *statusMenu;
  NSWindow *window;
  NSPersistentStoreCoordinator *__persistentStoreCoordinator;
  NSManagedObjectModel *__managedObjectModel;
  NSManagedObjectContext *__managedObjectContext;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
