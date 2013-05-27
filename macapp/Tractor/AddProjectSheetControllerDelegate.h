#import <Foundation/Foundation.h>
#import "Project.h"

@protocol AddProjectSheetControllerDelegate <NSObject>

@optional

- (void)projectWasAdded:(Project *)project;

@end
