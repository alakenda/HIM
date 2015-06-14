/*============================================================================*
 * (C) 2001-2011 G.Ishiwata, All Rights Reserved.
 *
 *	Project		: IP Messenger for Mac OS X
 *	File		: LogManager.m
 *	Module		: ログ管理クラス
 *============================================================================*/

#import <Foundation/Foundation.h>
#import "LogManager.h"
#import "UserInfo.h"
#import "Config.h"
#import "RecvMessage.h"
#import "SendMessage.h"
#import "DebugLog.h"
#import "Constants.h"

// 定数定義
static NSString* _HEAD_START	= @"=====================================\n";
static NSString* _HEAD_END		= @"-------------------------------------\n";

@interface LogManager()
- (void)writeLog:(NSString*)msg logfile:(NSString*) logfile;
@end

// クラス実装
@implementation LogManager

@synthesize filePath	= _filePath;

/*============================================================================*
 * ファクトリ
 *============================================================================*/

// 標準ログ
+ (LogManager*)standardLog
{
	static LogManager* standardLog = nil;
	if (!standardLog) {
		standardLog = [[LogManager alloc] initWithPath:[Config sharedConfig].standardLogFile];
	}
	return standardLog;
}

// 重要ログ
+ (LogManager*)alternateLog
{
	static LogManager* alternateLog	= nil;
	if (!alternateLog) {
		alternateLog = [[LogManager alloc] initWithPath:[Config sharedConfig].alternateLogFile];
	}
	return alternateLog;
}

/*============================================================================*
 * 初期化／解放
 *============================================================================*/

// 初期化
- (id)initWithPath:(NSString*)path
{
	self = [super init];
	if (self) {
		if (!path) {
			ERR(@"Param Error(path is null)");
			[self release];
			return nil;
		}
		_fileManager		= [[NSFileManager alloc] init];
		self.filePath		= [path stringByExpandingTildeInPath];
		_sTypeBroadcast		= NSLocalizedString(@"Log.Type.Broadcast", nil);
		_sTypeMulticast		= NSLocalizedString(@"Log.Type.Multicast", nil);
		_sTypeAutoReturn	= NSLocalizedString(@"Log.Type.AutoRet", nil);
		_sTypeLocked		= NSLocalizedString(@"Log.Type.Locked", nil);
		_sTypeSealed		= NSLocalizedString(@"Log.Type.Sealed", nil);
		_sTypeAttached		= NSLocalizedString(@"Log.Type.Attachment", nil);
		_dateFormat			= [[NSDateFormatter alloc] init];
		[_dateFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
		[_dateFormat setDateStyle:NSDateFormatterFullStyle];
		[_dateFormat setTimeStyle:NSDateFormatterMediumStyle];
	}
	return self;
}

// 解放
- (void)dealloc
{
	[_fileManager release];
	[_filePath release];
	[_dateFormat release];
	[super dealloc];
}

/*============================================================================*
 * ログ出力
 *============================================================================*/

// 受信ログ出力
- (void)writeRecvLog:(RecvMessage*)info
{
	[self writeRecvLog:info withRange:NSMakeRange(0, 0)];
}

// 受信ログ出力
- (void)writeRecvLog:(RecvMessage*)info withRange:(NSRange)range
{
	// メッセージ編集
	NSMutableString* msg = [NSMutableString string];
	//[msg appendString:_HEAD_START];
	//[msg appendString:@" From: "];
	//[msg appendString:[[info fromUser] summaryString]];
	//[msg appendString:@"\n  at "];
	//[msg appendString:[_dateFormat stringFromDate:info.receiveDate]];
    [msg appendFormat:@"%@(%@)\n ",[[info fromUser] userName],[info.receiveDate descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" timeZone:nil locale:nil]];

	if ([info broadcast]) {
		[msg appendString:_sTypeBroadcast];
	}
	if ([info absence]) {
		[msg appendString:_sTypeAutoReturn];
	}
	if ([info multicast]) {
		[msg appendString:_sTypeMulticast];
	}
	if ([info locked]) {
		[msg appendString:_sTypeLocked];
	} else if ([info sealed]) {
		[msg appendString:_sTypeSealed];
	}
	//[msg appendString:@"\n"];
	//[msg appendString:_HEAD_END];
	if (range.length > 0) {
		[msg appendString:[[info appendix] substringWithRange:range]];
	} else {
		[msg appendString:[info appendix]];
	}
	[msg appendString:@"\n\n"];

	// ログ出力
    NSString * logFileName = [NSString stringWithFormat:@"%@/%@.log",[DIR_LOG stringByExpandingTildeInPath],[[info fromUser] hostName]];
	[self writeLog:msg logfile:logFileName];
}

// 送信ログ出力
- (void)writeSendLog:(SendMessage*)info to:(NSArray*)to
{
	// メッセージ編集
	NSMutableString* msg = [NSMutableString string];
	//[msg appendString:_HEAD_START];
	//for (UserInfo* user in to) {
	//	[msg appendString:@" To: "];
	//	[msg appendString:[user summaryString]];
	//	[msg appendString:@"\n"];
	//}
	//[msg appendString:@"  at "];
	//[msg appendString:[_dateFormat stringFromDate:[NSCalendarDate date]]];
    [msg appendFormat:@"%@(%@)\n ",MY_NICKNAME,[[NSCalendarDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" timeZone:nil locale:nil]];
	if ([to count] > 1) {
		[msg appendString:_sTypeMulticast];
	}
	if (info.locked) {
		[msg appendString:_sTypeLocked];
	} else if (info.sealed) {
		[msg appendString:_sTypeSealed];
	}
	if ([info.attachments count] > 0) {
		[msg appendString:_sTypeAttached];
	}
	//[msg appendString:@"\n"];
	//[msg appendString:_HEAD_END];
	[msg appendString:info.message];
	[msg appendString:@"\n\n"];

    for (UserInfo* user in to) {
        NSString * logFileName = [NSString stringWithFormat:@"%@/%@.log",[DIR_LOG stringByExpandingTildeInPath],[user hostName]];
        // ログ出力
        [self writeLog:msg logfile:logFileName];
    }
    

}

// メッセージ出力（内部用）
- (void)writeLog:(NSString*)msg logfile:(NSString*) logfile
{
	if (!msg) {
		return;
	}
	if ([msg length] <= 0) {
		return;
	}
    //去掉~,生成绝对路径
    logfile = [logfile stringByExpandingTildeInPath];
    
	if (![_fileManager fileExistsAtPath:logfile]) {
		const Byte	dat[]	= { 0xEF, 0xBB, 0xBF };
		NSData*		bom		= [NSData dataWithBytes:dat length:sizeof(dat)];
		if (![_fileManager createFileAtPath:logfile contents:bom attributes:nil]) {
			ERR(@"LogFile Create Error.(%@)", logfile);
			return;
		}
	}
	if (![_fileManager isWritableFileAtPath:logfile]) {
		ERR(@"LogFile not writable.(%@)", logfile);
		return;
	}
	NSFileHandle* file = [NSFileHandle fileHandleForWritingAtPath:logfile];
	if (!file) {
		ERR(@"LogFile open Error.(%@)", logfile);
		return;
	}
	[file seekToEndOfFile];
	[file writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
	[file closeFile];
}

@end
