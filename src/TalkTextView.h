//
//  TalkTextView.h
//  IPMessenger
//
//  Created by 何谦 on 14-5-25.
//
//

#import <Cocoa/Cocoa.h>

@interface TalkTextView : NSTextView
{
    //在插入新的文本之前,当前TalkTextView已经存在的String的长度
    NSUInteger oriLen;
}
- (void)insertTalk:(id)aString talker:(NSString*) talkername;
- (void)insertImg:(NSImage*)img talker:(NSString*) talkername;
@end
