//
//  GridCell.m
//  IPMessenger
//
//  Created by 何谦 on 14-5-29.
//
//

#import "GridCell.h"
#import "NSImage+IPMessenger.h"
#import "DemoImageCache.h"
#import <Constants.h>

@implementation GridCell

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}
/*--为什么去掉这个才能显示???
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}*/



- (void)setImage:(NSImage *)image {
	_image = image;
	self.backgroundImage = image;
}

- (void)layout {
	[super layout];
	
	CGRect labelRect = self.bounds;
	//if (!CGRectEqualToRect(labelRect, self.label.frame)) {
		//self.label.frame = labelRect;
	//}
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	//[self updateBackgroundImage];
}

- (void)updateBackgroundImage {
	NSImage *image = nil;
	
	if (self.selected) {
		NSString *identifier = [NSString stringWithFormat:@"%@%x", NSStringFromClass(self.class), self.selected];
		CGSize size = CGSizeMake(1, CGRectGetHeight(self.bounds));
		image = [DemoImageCache.sharedCache cachedImageWithIdentifier:identifier size:size withCreationBlock:^NSImage * (CGSize size) {
			return [NSImage highlightedGradientImageWithHeight:size.height];
		}];
	} else {
		image = self.image;
	}
	
	if (self.backgroundImage != image) {
		self.backgroundImage = image;
	}
}

- (void)mouseUp:(NSEvent *)event
{
    NSPoint p = [event locationInWindow];
    NSMutableDictionary* userinfo = [[NSMutableDictionary alloc] init];
    [userinfo setObject:self.recvCtrl forKey:NOTICEDIC_DEST];
    [userinfo setObject:self.emotionStr forKey:NOTICEDIC_EMOTIONSTR];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_INSERT_EMOTIONSTR object:self userInfo:userinfo];

    [self setNeedsDisplay:YES];
}

@end
