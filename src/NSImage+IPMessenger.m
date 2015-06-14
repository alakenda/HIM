//
//  NSImage+IPMessenger.m
//  IPMessenger
//
//  Created by 何谦 on 14-5-29.
//
//

#import "NSImage+IPMessenger.h"

@implementation NSImage (IPMessenger)
+ (void)drawBackgroundInRect:(CGRect)dstRect highlighted:(BOOL)highlighted {
	CGRect b = dstRect;
	CGFloat top = highlighted ? .80 : 0.81;
	CGFloat bottom = highlighted ? .70 : 0.87;
	NSGradient *gradient = [[NSGradient alloc] initWithColors: @[[NSColor colorWithCalibratedRed:top green:top blue:top alpha:1],
                                                                 [NSColor colorWithCalibratedRed:bottom green:bottom blue:bottom alpha:1]]];
	[gradient drawInRect:b angle:90];
	
	[[[NSColor whiteColor] colorWithAlphaComponent:0.6] setFill];
	NSRectFillUsingOperation(CGRectMake(0, b.size.height-1, b.size.width, 1), NSCompositeSourceOver);
	
	[[[NSColor blackColor] colorWithAlphaComponent:0.08] setFill];
	NSRectFillUsingOperation(CGRectMake(0, 0, b.size.width, 1), NSCompositeSourceOver);
}

+ (NSImage *)standardGradientImageWithHeight:(CGFloat)height {
	return [NSImage imageWithSize:CGSizeMake(1, height) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
		[self drawBackgroundInRect:dstRect highlighted:NO];
		return YES;
	}];
}

+ (NSImage *)highlightedGradientImageWithHeight:(CGFloat)height {
	return [NSImage imageWithSize:CGSizeMake(1, height) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
		[self drawBackgroundInRect:dstRect highlighted:YES];
		return YES;
	}];
}

@end
