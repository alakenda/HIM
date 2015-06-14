//
//  TalkTextView.m
//  IPMessenger
//
//  Created by 何谦 on 14-5-25.
//
//

#import "TalkTextView.h"
#import "Config.h"
#import "Constants.h"

@implementation TalkTextView


- (void)insertTalk:(id)aString talker:(NSString*) talkername
{
    [self setEditable:YES];
    oriLen = [[self textStorage] length];

    if ([aString isKindOfClass:[NSString class]]) {
        
        //用正则式把字体信息等控制信息去掉转义符为双斜杠
        NSMutableString* txt = [[NSMutableString alloc] initWithString:aString];
        NSUInteger result = [txt replaceOccurrencesOfString:@"\\{/font.*;\\}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0,[aString length])];
        
        //添加对话人名
        [self appendContentWithTalkerName:txt talker:talkername];
        
        //设置字体
        //NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:txt];
        //[attrstr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:14] range:NSMakeRange(0, [attrstr length])];
        //添加到最后
        //[[self textStorage] appendAttributedString:attrstr];
        //设置对话颜色
        //[self changeTextFont:txt talker:talkername];
        //[self attributeURL:txt];
        //将表情替换成图片
        //[self changeEmotionStrToImg:txt];
        [self scrollRangeToVisible:NSMakeRange([[self string] length], 0)];
    }
    else//如果是NSAttributedString
        [[self textStorage] appendAttributedString:aString];
    [self setEditable:NO];
}


- (void)insertImg:(NSImage*)img talker:(NSString*) talkername
{
    [self setEditable:YES];
    NSString* str = [self appendContentWithTalkerName:@"" talker:talkername];
    
    NSFileWrapper *imageFileWrapper = [[NSFileWrapper alloc] init];
    //setIcon才会动,否则不会动
    [imageFileWrapper setIcon:img];
    
    NSMutableAttributedString*	attrStr	= [self textStorage];
    NSTextAttachment *imageAttachment = [[[NSTextAttachment alloc] initWithFileWrapper:imageFileWrapper] autorelease];
    NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    
    [attrStr insertAttributedString:imageAttributedString atIndex:[attrStr length]];
    [super insertText:@"\r"];
    [super insertText:@"\r"];
    [self scrollRangeToVisible:NSMakeRange([[self string] length], 0)];
    [self setEditable:NO];
    
}

//添加对话发起人
- (void *)appendContentWithTalkerName:(id)aString talker:(NSString*) talkername
{
    [self setEditable:YES];
    NSMutableString *resultTxt = [[NSMutableString alloc] init];
    if ([aString isKindOfClass:[NSString class]])
    {
        [resultTxt appendFormat:@"\r%@  %@\r    %@\r",talkername,[[NSDate date] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil],aString];
        
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        if ([talkername isEqualToString:MY_NICKNAME])
        {
            //[dic setObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
            [dic setObject:[NSColor colorWithSRGBRed:96/255.0 green:123/255.0 blue:139/255.0 alpha:1] forKey:NSForegroundColorAttributeName];
        }
        else
        {
//            [dic setObject:[NSColor colorWithSRGBRed:85/255.0 green:26/255.0 blue:139/255.0 alpha:1] forKey:NSForegroundColorAttributeName];
            [dic setObject:[NSColor colorWithSRGBRed:139/255.0 green:34/255.0 blue:82/255.0 alpha:1] forKey:NSForegroundColorAttributeName];            
        }
        [dic setObject:[NSFont systemFontOfSize:14] forKey:NSFontAttributeName];
        NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:resultTxt attributes:dic];
        [self changeEmotionStrToImg:attrStr];
        
        [[self textStorage] appendAttributedString:attrStr];
    }
    else
    {
        
    }
    [self setEditable:NO];
}

//将表情替换成图片
-(void) changeEmotionStrToImg :(NSMutableAttributedString*)attrStr
{
    NSScanner*					scanner;
    NSCharacterSet*				charSet;
    NSArray*					schemes;
    scanner	= [NSScanner scannerWithString:[attrStr mutableString]];
    charSet	= [NSCharacterSet characterSetWithCharactersInString:NSLocalizedString(@"RecvDlg.Emotion.Delimiter", nil)];
    schemes = [[Config sharedConfig].emotionImgDic allKeys];
    int count = 0;
    while (![scanner isAtEnd]) {
        NSString*	sentence;
        NSRange		range;
        [scanner scanUpToCharactersFromSet:charSet intoString:&sentence];
        for (int i = 0; i < [schemes count]; i++) {
            //比较的时候,要把/去掉,因为scanUpToCharactersFromSet生成的sentence不包含charSet中的字符
            range = [sentence rangeOfString:[[schemes objectAtIndex:i] substringFromIndex:1]];
            if (range.location != NSNotFound) {
                if (range.location > 0) {
                    sentence	= [sentence substringFromIndex:range.location];
                }
                range.length	= [[schemes objectAtIndex:i] length];
                range.location	= [scanner scanLocation] - [sentence length] - count - 1;
                
                NSString *imageName = [NSString stringWithFormat:@"%@.gif",[[Config sharedConfig].emotionImgDic objectForKey:[schemes objectAtIndex:i]]];
                NSFileWrapper *imageFileWrapper = [[NSFileWrapper alloc] init];
                //setIcon才会动,否则不会动
                [imageFileWrapper setIcon:[NSImage imageNamed:imageName]];
                
                NSTextAttachment *imageAttachment = [[[NSTextAttachment alloc] initWithFileWrapper:imageFileWrapper] autorelease];
                NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
                //删除表情字符串
                [[attrStr mutableString] deleteCharactersInRange:range];
                //添加表情图片
                [attrStr insertAttributedString:imageAttributedString atIndex:range.location];

                //NSLog(@"total:%ld,location:%ld",[[self textStorage] length],range.location);
                //-1是为了预留新增表情图片位置
                count = count + range.length -1 ;
                break;//应该是break
            }
        }
        [scanner scanString:NSLocalizedString(@"RecvDlg.Emotion.Delimiter", nil) intoString:nil];
    }
    
    
}
    
/*
- (NSMutableString *)appendTalkerName:(id)aString talker:(NSString*) talkername
{
    NSMutableString *resultTxt = [[NSMutableString alloc] init];
    if ([talkername isEqualToString:@"你"]) {
        [resultTxt appendFormat:@"\r你  %@\r    %@\r",[[NSDate date] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil],aString];
    }
    else
    {
        [resultTxt appendFormat:@"\r%@  %@\r    %@\r",talkername,[[NSDate date] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil],aString];
    }
    //[attrtxt addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:28.0] range:NSMakeRange(0, [attrtxt length])];
    return resultTxt;
}*/

//修改字体颜色
-(void)changeTextFont:(NSString*)aString talker:(NSString*) talkername
{
    NSMutableAttributedString*	attrStr;
    attrStr	= [self textStorage];
    if ([talkername isEqualToString:MY_NICKNAME]) {
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[NSColor blueColor]
                        range:NSMakeRange(oriLen, [attrStr length] - oriLen)];
    }
    else
    {
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[NSColor darkGrayColor]
                        range:NSMakeRange(oriLen, [attrStr length] - oriLen)];
    }
    
}



-(NSString*)attributeURL:(id)aString
{
    // クリッカブルURL設定
    if ([Config sharedConfig].useClickableURL) {
		NSMutableAttributedString*	attrStr;
		NSScanner*					scanner;
		NSCharacterSet*				charSet;
		NSArray*					schemes;
		attrStr	= [self textStorage];
		scanner	= [NSScanner scannerWithString:aString];
		charSet	= [NSCharacterSet characterSetWithCharactersInString:NSLocalizedString(@"RecvDlg.URL.Delimiter", nil)];
		schemes = [NSArray arrayWithObjects:@"http://", @"https://", @"ftp://", @"file://", @"rtsp://", @"afp://", @"mailto:", nil];
		while (![scanner isAtEnd]) {
			NSString*	sentence;
			NSRange		range;
			unsigned	i;
			if (![scanner scanUpToCharactersFromSet:charSet intoString:&sentence]) {
				continue;
			}
			for (i = 0; i < [schemes count]; i++) {
				range = [sentence rangeOfString:[schemes objectAtIndex:i]];
				if (range.location != NSNotFound) {
					if (range.location > 0) {
						sentence	= [sentence substringFromIndex:range.location];
					}
					range.length	= [sentence length];
					range.location	= [scanner scanLocation] - [sentence length] + oriLen;
					[attrStr addAttribute:NSLinkAttributeName value:sentence range:range];
					[attrStr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
					[attrStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:range];
					break;
				}
			}
			if (i < [schemes count]) {
				continue;
			}
			range = [sentence rangeOfString:@"://"];
			if (range.location != NSNotFound) {
				range.location	= [scanner scanLocation] - [sentence length];
				range.length	= [sentence length];
				[attrStr addAttribute:NSLinkAttributeName value:sentence range:range];
				[attrStr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
				[attrStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:range];
				continue;
			}
		}
	}

}


//将表情符号替换成图片
/*
-(void) changeEmotionStrToImg :(id)aString
{
    NSMutableAttributedString*	attrStr;
    NSScanner*					scanner;
    NSCharacterSet*				charSet;
    NSArray*					schemes;
    attrStr	= [self textStorage];
    scanner	= [NSScanner scannerWithString:aString];
    charSet	= [NSCharacterSet characterSetWithCharactersInString:NSLocalizedString(@"RecvDlg.Emotion.Delimiter", nil)];
    schemes = [[Config sharedConfig].emotionImgDic allKeys];
    int count = 0;
    while (![scanner isAtEnd]) {
        NSString*	sentence;
        NSRange		range;
        [scanner scanUpToCharactersFromSet:charSet intoString:&sentence];
        for (int i = 0; i < [schemes count]; i++) {
            //比较的时候,要把/去掉
            range = [sentence rangeOfString:[[schemes objectAtIndex:i] substringFromIndex:1]];
            if (range.location != NSNotFound) {
                if (range.location > 0) {
                    sentence	= [sentence substringFromIndex:range.location];
                }
                range.length	= [sentence length];
                range.location	= [scanner scanLocation] - [sentence length] + oriLen + count - 1;

                NSString *imageName = [NSString stringWithFormat:@"%@.gif",[[Config sharedConfig].emotionImgDic objectForKey:[schemes objectAtIndex:i]]];
                NSFileWrapper *imageFileWrapper = [[NSFileWrapper alloc] init];
                //setIcon才会动,否则不会动
                [imageFileWrapper setIcon:[NSImage imageNamed:imageName]];
                
                NSTextAttachment *imageAttachment = [[[NSTextAttachment alloc] initWithFileWrapper:imageFileWrapper] autorelease];
                NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
                [attrStr insertAttributedString:imageAttributedString atIndex:range.location];
                //NSLog(@"total:%ld,location:%ld",[[self textStorage] length],range.location);
                count ++ ;
                break;//应该是break
            }
        }
        [scanner scanString:NSLocalizedString(@"RecvDlg.Emotion.Delimiter", nil) intoString:nil];
    }
    
    
}
*/
/*

-(BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

- (NSString *)changeEmojiToStr:(NSString *)string{
    
    __block NSString *trueString = @"";
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if([emojiArr containsObject:substring]){
            NSInteger location = [emojiArr indexOfObject:substring];
            trueString = [NSString stringWithFormat:@"%@[%@]",trueString,[changeEmojiArr objectAtIndex:location]];
        }else{
            trueString = [NSString stringWithFormat:@"%@%@",trueString,substring];
        }
    }];
    return trueString;
}

- (NSString *)initials;
{
    NSMutableString *result = [NSMutableString string];
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                             options:NSStringEnumerationByWords | NSStringEnumerationLocalized
                          usingBlock:^(NSString *word, NSRange wordRange, NSRange enclosingWordRange, BOOL *stop1) {
                              __block NSString *firstLetter = nil;
                              [self enumerateSubstringsInRange:NSMakeRange(0, word.length)
                                                       options:NSStringEnumerationByComposedCharacterSequences
                                                    usingBlock:^(NSString *letter, NSRange letterRange, NSRange enclosingLetterRange, BOOL *stop2) {
                                                        firstLetter = letter;
                                                        *stop2 = YES;
                                                    }];
                              if (letter != nil) {
                                  [result appendString:letter];
                              };
                          }];
    return result;
}
 */
@end
