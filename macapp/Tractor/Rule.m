#import "Rule.h"
#import "Project.h"


@implementation Rule

@dynamic name;
@dynamic order;
@dynamic predicateData;
@dynamic project;

- (NSPredicate *)predicate
{
  return [NSKeyedUnarchiver unarchiveObjectWithData:[self predicateData]];
}

- (void)setPredicate:(NSPredicate *)predicate
{
  [self setPredicateData:[NSKeyedArchiver archivedDataWithRootObject:predicate]];
}


// expands the "anything" part of the predicate to include all the passed keyPaths
// also, works around a lame xcode bug: http://stackoverflow.com/questions/5642681/nspredicateeditor-in-xcode-4/5643941
- (NSPredicate *)expandedPredicate:(NSArray *)keyPaths
{
  NSPredicate *predicate = [self predicate];

  predicate = [self expandPredicate:predicate withKeyPaths:keyPaths];

  return predicate;
}

- (NSPredicate *)expandPredicate:(NSPredicate *)predicate withKeyPaths:(NSArray *)keyPaths
{
  if ([predicate isKindOfClass:[NSComparisonPredicate class]]) {
    predicate = [self expandComparisonPredicate:(NSComparisonPredicate *)predicate withKeyPaths:keyPaths];
  } else if ([predicate isKindOfClass:[NSCompoundPredicate class]]) {
    predicate = [self expandCompoundPredicate:(NSCompoundPredicate *)predicate withKeyPaths:keyPaths];
  }
  return predicate;
}

- (NSPredicate *)expandComparisonPredicate:(NSComparisonPredicate *)predicate withKeyPaths:(NSArray *)keyPaths
{
  NSPredicate *ret = nil;
  NSExpression *leftExpression = [predicate leftExpression];
  NSString *leftValue = nil;

  if ([leftExpression expressionType] == NSConstantValueExpressionType) {
    leftValue = [leftExpression constantValue];
  } else {
    leftValue = [[predicate leftExpression] keyPath];
  }

  if ([leftValue isEqualToString:@"anything"]) {
    NSMutableArray *subpredicates = [NSMutableArray arrayWithCapacity:[keyPaths count]];
    for (NSString *keyPath in keyPaths) {
      NSPredicate *subpredicate = [self predicateFromComparisonPredicate:predicate withLeftExpressionKeyPath:keyPath];
      [subpredicates addObject:subpredicate];
    }

    ret = [NSCompoundPredicate orPredicateWithSubpredicates:subpredicates];
  } else {
    ret = [self predicateFromComparisonPredicate:predicate withLeftExpressionKeyPath:leftValue];
  }

  return ret;
}

- (NSPredicate *)predicateFromComparisonPredicate:(NSComparisonPredicate *)predicate withLeftExpressionKeyPath:keyPath
{
  NSExpression *leftExpression = [NSExpression expressionForKeyPath:keyPath];

  return [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                            rightExpression:[predicate rightExpression]
                                                   modifier:[predicate comparisonPredicateModifier]
                                                       type:[predicate predicateOperatorType]
                                                    options:[predicate options]];
}

- (NSPredicate *)expandCompoundPredicate:(NSCompoundPredicate *)predicate withKeyPaths:(NSArray *)keyPaths
{
  NSArray *subpredicates = [predicate subpredicates];
  NSMutableArray *expandedSubpredicates = [NSMutableArray arrayWithCapacity:[subpredicates count]];

  for (NSPredicate *predicate in subpredicates) {
    [expandedSubpredicates addObject:[self expandPredicate:predicate withKeyPaths:keyPaths]];
  }

  NSCompoundPredicateType predicateType = [predicate compoundPredicateType];
  predicate = [[[NSCompoundPredicate alloc] initWithType:predicateType subpredicates:expandedSubpredicates] autorelease];

  return predicate;
}


@end
