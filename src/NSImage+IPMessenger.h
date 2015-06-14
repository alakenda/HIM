//
//  NSImage+IPMessenger.h
//  IPMessenger
//
//  Created by 何谦 on 14-5-29.
//
//

#import <Cocoa/Cocoa.h>

@interface NSImage (IPMessenger)
+ (NSImage *)standardGradientImageWithHeight:(CGFloat)height;
+ (NSImage *)highlightedGradientImageWithHeight:(CGFloat)height;
@end
