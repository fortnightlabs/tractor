#import "AddRuleSheetController.h"
#import "Rules.h"
#import "Projects.h"

@implementation AddRuleSheetController

@synthesize context;

#pragma mark - Lifecycle

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    context = nil;
  }
    
  return self;
}

- (void)dealloc
{
  [context release], context = nil;
  [super dealloc];
}

- (void)windowDidLoad
{
  [super windowDidLoad];

  [[self window] setDefaultButtonCell:[addRuleButton cell]];

  [self loadProjectsPopup];
  [self loadPredicateEditor];
}

- (void)endSheet
{
  [NSApp endSheet:[self window]];
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
  [self endSheet];
}

- (IBAction)addRule:(id)sender
{
  Rules *rules = [context rules];
  Rule *rule = [rules addRule];

  [rule setPredicate:[self predicate]];
  [rule setProject:[self selectedProject]];
  if (![rule name]) {
    [rule setName:[[rule project] name]];
  }

  if (![[rule order] longValue]) {
    NSInteger order = [[[rules last] order] longValue] + 1;
    [rule setOrder:[NSNumber numberWithLong:order]];
  }

  [self endSheet];
}

#pragma mark - PredicateEditor methods

- (void)loadPredicateEditor
{
  Projects *projects = [context projects];
  NSString *projectName = [[projects first] name];
  if (!projectName) { projectName = @""; }

  NSPredicate *defaultPredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS %@", @"anything", projectName];
  [predicateEditor setObjectValue:defaultPredicate];
}

- (NSPredicate *)predicate
{
  NSPredicate *predicate = [predicateEditor objectValue];

  if ([predicate isKindOfClass:[NSCompoundPredicate class]]) {
    NSCompoundPredicate *compoundPredicate = (NSCompoundPredicate *)predicate;

    if ([[[anyAllButton selectedItem] title] isEqualToString:@"all"]) {
      // AND
      predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[compoundPredicate subpredicates]];
    } else {
      // OR
      predicate = [NSCompoundPredicate orPredicateWithSubpredicates:[compoundPredicate subpredicates]];
    }    
  }

  return predicate;
}

#pragma mark - ProjectsPopup methods

- (void)loadProjectsPopup
{
  if (![projectsArrayController managedObjectContext]) {
    [projectsArrayController setManagedObjectContext:[context context]];

    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [projectsArrayController setSortDescriptors:@[sortByName]];
    NSError *error;
    [projectsArrayController fetchWithRequest:nil merge:YES error:&error];
  }
}

- (Project *)selectedProject
{
  return [[projectsArrayController selectedObjects] objectAtIndex:0];
}

@end
