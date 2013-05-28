#import "ProjectTextFieldCell.h"

@implementation ProjectTextFieldCell

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
  NSColor *textColor = (backgroundStyle == NSBackgroundStyleDark) ? [NSColor windowBackgroundColor] : [NSColor controlShadowColor];
  [self setTextColor:textColor];
  [super setBackgroundStyle:backgroundStyle];
}

@end
