/*============================================================================*
 * (C) 2001-2011 G.Ishiwata, All Rights Reserved.
 *
 *	Project		: IP Messenger for Mac OS X
 *	File		: ReceiveControl.m
 *	Module		: 受信メッセージウィンドウコントローラ
 *============================================================================*/

#import <Cocoa/Cocoa.h>
#import "ReceiveControl.h"
#import "Config.h"
#import "UserInfo.h"
#import "LogManager.h"
#import "MessageCenter.h"
#import "WindowManager.h"
#import "RecvMessage.h"
#import "SendMessage.h"
#import "SendControl.h"
#import "AttachmentFile.h"
#import "Attachment.h"
#import "DebugLog.h"
#import "AttachmentServer.h"
#import "AttachSendCompPushObj.h"
#import "JNWCollectionView/JNWCollectionView.h"
#import "JNWCollectionView/JNWCollectionViewGridLayout.h"
#import "GridCell.h"

#include <unistd.h>

/*============================================================================*
 * クラス実装
 *============================================================================*/

static NSString * const identifier = @"CELL";
@implementation ReceiveControl

/*----------------------------------------------------------------------------*
 * 初期化／解放
 *----------------------------------------------------------------------------*/

// 初期化
- (id)initWithRecvMessage:(UserInfo*)userinfo {
	Config*		config = [Config sharedConfig];
    
    self = [super init];

    
	if (userinfo == nil || userinfo.hostName == nil) {
		[self autorelease];
		return nil;
	}

    _talkingUser = userinfo;
    
	if (![NSBundle loadNibNamed:@"ReceiveWindow.nib" owner:self]) {
		[self autorelease];
		return nil;
	}

    sendAttachments			= [[NSMutableArray alloc] init];
	sendAttachmentsDic		= [[NSMutableDictionary alloc] init];

    
    [window makeFirstResponder:sendMessageArea];
    [messageArea setFont:[NSFont systemFontOfSize:14.0]];
    [sendMessageArea setFont:[NSFont systemFontOfSize:14.0]];
    
    [[WindowManager sharedManager] setReceiveWindow:self forKey:[userinfo hostName]];
    
    if([self respondsToSelector:@selector(attachSendCompleted:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(attachSendCompleted:)
                                                     name:NOTICE_ATTACH_SEND_COMPLETED
                                                   object:nil];
    }
    if([self respondsToSelector:@selector(insertEmotionStr:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(insertEmotionStr:)
                                                     name:NOTICE_INSERT_EMOTIONSTR
                                                   object:nil];
    }

    if([self respondsToSelector:@selector(insertScreenShotBMP:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(insertScreenShotBMP:)
                                                     name:NOTICE_INSERT_SCREENSHOTBMP
                                                   object:nil];
    }
    
    [dateLabel setObjectValue:[NSDate date]];
	[userNameLabel setStringValue:_talkingUser.summaryString];
    
    self.curRcvAttachs = [[NSMutableArray alloc] init];
    [self setAttachHeader];
	[attachTable reloadData];
	[attachTable selectAll:self];
    
    
	downloader = nil;
	pleaseCloseMe = NO;
	attachSheetRefreshTimer = nil;
    
	return self;
}

- (void)updateRecvMessage:(RecvMessage*)msg {
    Config*		config = [Config sharedConfig];
    
	// ログ出力
	if (config.standardLogEnabled) {
		if (![msg locked] || !config.logChainedWhenOpen) {
			[[LogManager standardLog] writeRecvLog:msg];
			[msg setNeedLog:NO];
		}
	}
    
	// 表示内容の設定
	[dateLabel setObjectValue:msg.receiveDate];
	//[userNameLabel setStringValue:[[msg fromUser] summaryString]];

	[messageArea insertTalk:[msg appendix] talker:[msg fromUser].userName];

    
	if ([msg multicast]) {
		[infoBox setTitle:NSLocalizedString(@"RecvDlg.BoxTitleMulti", nil)];
	} else if ([msg broadcast]) {
		[infoBox setTitle:NSLocalizedString(@"RecvDlg.BoxTitleBroad", nil)];
	} else if ([msg absence]) {
		[infoBox setTitle:NSLocalizedString(@"RecvDlg.BoxTitleAbsence", nil)];
	}
	if (![msg sealed]) {
		//[sealButton removeFromSuperview];
		//[window makeFirstResponder:messageArea];
	} else {
		//[replyButton setEnabled:NO];
		//[quotCheck setEnabled:NO];
		//[window makeFirstResponder:replyButton];
	}
	if ([msg locked]) {
		[sealButton setTitle:NSLocalizedString(@"RecvDlg.LockBtnStr", nil)];
	}
    
	recvMsg = [msg retain];
    //暂时按用户名区分
	//[[WindowManager sharedManager] setReceiveWindow:self forKey:msg.fromUser.userName];
    
    if (config.alternateLogEnabled) {
        [altLogButton setEnabled:config.alternateLogEnabled];
    } else {
        [altLogButton setHidden:YES];
    }
    
    // 添付ボタンの有効／無効
    if ([[recvMsg attachments] count] > 0) {
        self.curRcvAttachs = [recvMsg attachments];
        
        [attachButton setEnabled:YES];
        [attachDrawer open];
	}
    
	//[self setAttachHeader];
	[attachTable reloadData];
	[attachTable selectAll:self];
    
	//downloader = nil;
	//pleaseCloseMe = NO;
	//attachSheetRefreshTimer = nil;
}
    
    
// 解放処理
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[recvMsg release];
	[downloader release];
	[super dealloc];
}

/*----------------------------------------------------------------------------*
 * ウィンドウ表示
 *----------------------------------------------------------------------------*/

- (void)showWindow {
	/*
     NSWindow* orgKeyWin = [NSApp keyWindow];
    
	if (orgKeyWin) {
		if ([[orgKeyWin delegate] isKindOfClass:[SendControl class]]) {
			[window orderFront:self];
			[orgKeyWin orderFront:self];
		} else {
			[window makeKeyAndOrderFront:self];
		}
	} else {
		[window makeKeyAndOrderFront:self];
	}*/
    
    if(window)
    {
		[window makeKeyAndOrderFront:self];
    }
    
    //NSLog(@"attachDrawer state:%ld",[attachDrawer state]);
	if ([self.curRcvAttachs count] > 0) {
        if ([attachDrawer state] == NSDrawerOpenState ||  [attachDrawer state] == NSDrawerOpeningState) {
            [attachDrawer close];//要多关闭一次,否则不会正常弹出
        }
		[attachDrawer open];
	}
}

/*----------------------------------------------------------------------------*
 * ボタン
 *----------------------------------------------------------------------------*/

- (IBAction)buttonPressed:(id)sender {
	if (sender == attachSaveButton) {
		NSOpenPanel* op = [NSOpenPanel openPanel];
		[attachSaveButton setEnabled:NO];
		[op setCanChooseFiles:NO];
		[op setCanChooseDirectories:YES];
		[op setPrompt:NSLocalizedString(@"RecvDlg.Attach.SelectBtn", nil)];
		[op beginSheetForDirectory:nil
							  file:nil
					modalForWindow:window
					 modalDelegate:self
					didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
					   contextInfo:sender];
	} else if (sender == attachSheetCancelButton) {
		[downloader stopDownload];
	} 	else if (sender == sendAttachAddButton) {
		NSOpenPanel* op = [NSOpenPanel openPanel];;
		// 添付追加／削除ボタンを押せなくする
		[sendAttachAddButton setEnabled:NO];
		[sendAttachDelButton setEnabled:NO];
		// シート表示
		[op setCanChooseDirectories:YES];
		[op beginSheetForDirectory:nil
							  file:nil
					modalForWindow:window
					 modalDelegate:self
					didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
					   contextInfo:sender];
	}
	// 添付削除ボタン
	else if (sender == sendAttachDelButton) {
		int selIdx = [sendAttachTable selectedRow];
		if (selIdx >= 0) {
			Attachment* info = [sendAttachments objectAtIndex:selIdx];
			[sendAttachmentsDic removeObjectForKey:[info file].path];
			[sendAttachments removeObjectAtIndex:selIdx];
			[sendAttachTable reloadData];
			[self setAttachHeader];
		}
	}
    else {
		DBG(@"Unknown button pressed(%@)", sender);
	}
}

//拒收远端发送过来的附件
- (IBAction)rcvAttachDelButton:(id)sender {
    NSIndexSet*		indexes		= [attachTable selectedRowIndexes];
    NSUInteger		index;
    
    index = [indexes lastIndex];
    while (index != NSNotFound) {
    
        [self.curRcvAttachs removeObjectAtIndex:index];
        
        index = [indexes indexLessThanIndex:index];
    }
    [attachTable reloadData];
    
}

- (void)attachTableDoubleClicked:(id)sender {
	if (sender == attachTable) {
		[self buttonPressed:attachSaveButton];
	}
}

// シート終了処理
- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)code contextInfo:(void*)info {
	if (info == attachSaveButton) {
		if (code == NSOKButton) {
			NSFileManager*	fileManager	= [NSFileManager defaultManager];
			NSString*		directory	= [(NSOpenPanel*)sheet directory];
			NSIndexSet*		indexes		= [attachTable selectedRowIndexes];
			NSUInteger		index;
			[downloader release];
			downloader = [[AttachmentClient alloc] initWithRecvMessage:recvMsg saveTo:directory];
			index = [indexes firstIndex];
			while (index != NSNotFound) {
				NSString*	path;
				Attachment*	attach;
				attach = [self.curRcvAttachs objectAtIndex:index];
				if (!attach) {
					index = [indexes indexGreaterThanIndex:index];
					continue;
				}
				path = [directory stringByAppendingPathComponent:[[attach file] name]];
				// ファイル存在チェック
				if ([fileManager fileExistsAtPath:path]) {
					// 上書き確認
					int result;
					WRN(@"file exists(%@)", path);
					if ([[attach file] isDirectory]) {
						result = NSRunAlertPanel(	NSLocalizedString(@"RecvDlg.AttachDirOverwrite.Title", nil),
													NSLocalizedString(@"RecvDlg.AttachDirOverwrite.Msg", nil),
													NSLocalizedString(@"RecvDlg.AttachDirOverwrite.OK", nil),
													NSLocalizedString(@"RecvDlg.AttachDirOverwrite.Cancel", nil),
													nil,
													[[attach file] name]);
					} else {
						result = NSRunAlertPanel(	NSLocalizedString(@"RecvDlg.AttachFileOverwrite.Title", nil),
													NSLocalizedString(@"RecvDlg.AttachFileOverwrite.Msg", nil),
													NSLocalizedString(@"RecvDlg.AttachFileOverwrite.OK", nil),
													NSLocalizedString(@"RecvDlg.AttachFileOverwrite.Cancel", nil),
													nil,
													[[attach file] name]);
					}
					switch (result) {
					case NSAlertDefaultReturn:
						DBG(@"overwrite ok.");
						break;
					case NSAlertAlternateReturn:
						DBG(@"overwrite canceled.");
						[attachTable deselectRow:index];	// 選択解除
						index = [indexes indexGreaterThanIndex:index];
						continue;
					default:
						ERR(@"inernal error.");
						break;
					}
				}
				[downloader addTarget:attach];
				index = [indexes indexGreaterThanIndex:index];
			}
			[sheet orderOut:self];
			if ([downloader numberOfTargets] == 0) {
				WRN(@"downloader has no targets");
				[downloader release];
				downloader = nil;
				return;
			}
			// ダウンロード準備（UI）
			[attachSaveButton setEnabled:NO];
			[attachTable setEnabled:NO];
			[attachSheetProgress setIndeterminate:NO];
			[attachSheetProgress setMaxValue:[downloader totalSize]];
			[attachSheetProgress setDoubleValue:0];
			// シート表示
			[NSApp beginSheet:attachSheet
			   modalForWindow:window
				modalDelegate:self
			   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
				  contextInfo:nil];
			// ダウンロード（スレッド）開始
			attachSheetRefreshTitle			= NO;
			attachSheetRefreshFileName		= NO;
			attachSheetRefreshPercentage	= NO;
			attachSheetRefreshFileNum		= NO;
			attachSheetRefreshDirNum		= NO;
			attachSheetRefreshSize			= NO;
			[downloader startDownload:self];
			attachSheetRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
																	   target:self
																	 selector:@selector(downloadSheetRefresh:)
																	 userInfo:nil
																	  repeats:YES];
		} else {
			[attachSaveButton setEnabled:([attachTable numberOfSelectedRows] > 0)];
            [attachDelButton setEnabled:([attachTable numberOfSelectedRows] > 0)];
		}
	} else if (info == sendAttachAddButton) {
		if (code == NSOKButton) {
			NSOpenPanel*	op = (NSOpenPanel*)sheet;
			NSString*		fn = [op filename];
			[self appendAttachmentByPath:fn];
		}
		[sheet orderOut:self];
		[sendAttachAddButton setEnabled:YES];
		[sendAttachDelButton setEnabled:([attachTable numberOfSelectedRows] > 0)];
	}
    else if (sheet == attachSheet) {
		[attachSheetRefreshTimer invalidate];
		attachSheetRefreshTimer = nil;
		[recvMsg removeDownloadedAttachments];
        [self removeDownloadedAttachments];
		[sheet orderOut:self];
		[attachSaveButton setEnabled:([attachTable numberOfSelectedRows] > 0)];
        [attachDelButton setEnabled:([attachTable numberOfSelectedRows] > 0)];
		[attachTable reloadData];
		[self setAttachHeader];
		[attachTable setEnabled:YES];
		if ([self.curRcvAttachs count] <= 0) {
//			[attachDrawer performSelectorOnMainThread:@selector(close:) withObject:self waitUntilDone:YES];
			[attachDrawer close];
			[attachButton setEnabled:NO];
		}
		[downloader autorelease];
		downloader = nil;
	}
	else if (info == recvMsg) {
		[sheet orderOut:self];
		if (code == NSOKButton) {
			pleaseCloseMe = YES;
			[window performClose:self];
		}
	}
}

- (void)removeDownloadedAttachments
{
	int index;
	for (index = [self.curRcvAttachs count] - 1; index >= 0; index--) {
		Attachment* attach = [self.curRcvAttachs objectAtIndex:index];
		if (attach.isDownloaded) {
			[self.curRcvAttachs removeObjectAtIndex:index];
		}
	}
}

/*----------------------------------------------------------------------------*
 * 返信処理
 *----------------------------------------------------------------------------*/

- (BOOL)validateMenuItem:(NSMenuItem*)item {
	// 封書開封前はメニューとキーボードショートカットで返信できてしまわないようにする
	// （メニューアイテムの判定方法が暫定）
	if ([[item keyEquivalent] isEqualToString:@"r"] && ([item keyEquivalentModifierMask] & NSCommandKeyMask)) {
		return [replyButton isEnabled];
	}
	return YES;
}

// 返信ボタン押下時処理
- (IBAction)replyMessage:(id)sender {
    /*
	Config*		config	= [Config sharedConfig];
	NSString*	quotMsg	= nil;
	id			sendCtl	= [[WindowManager sharedManager] replyWindowForKey:recvMsg];
	if (sendCtl) {
		[[sendCtl window] makeKeyAndOrderFront:self];
		return;
	}
	if ([quotCheck state]) {
		NSString* quote = config.quoteString;

		// 選択範囲があれば選択範囲を引用、なければ全文引用
		NSRange	range = [messageArea selectedRange];
		if (range.length <= 0) {
			quotMsg = [messageArea string];
		} else {
			quotMsg = [[messageArea string] substringWithRange:range];
		}
		if (([quotMsg length] > 0) && ([quote length] > 0)) {
			// 引用文字を入れる
			NSArray*			array;
			NSMutableString*	strBuf;
			int					lines;
			int					iCount;
			array	= [quotMsg componentsSeparatedByString:@"\n"];
			lines	= [array count];
			strBuf	= [NSMutableString stringWithCapacity:
							[quotMsg length] + ([quote length] + 1) * lines];
			for (iCount = 0; iCount < lines; iCount++) {
				[strBuf appendString:quote];
				[strBuf appendString:[array objectAtIndex:iCount]];
				[strBuf appendString:@"\n"];
			}
			quotMsg = strBuf;
		}
	}
	// 送信ダイアログ作成
	sendCtl = [[SendControl alloc] initWithSendMessage:quotMsg recvMessage:recvMsg];
    */
    
    //edit by heqian
    SendMessage*	info;
	NSMutableArray*	to;
	NSString*		msg;
	BOOL			sealed;
	BOOL			locked;
	NSIndexSet*		userSet;
	Config*			config = [Config sharedConfig];
	NSUInteger		index;
    
    if ([[sendMessageArea string] length] == 0 && [sendAttachments count] == 0) {
        return;
    }
    
	if (config.inAbsence) {
		// 不在モードを解除して送信するか確認
		NSBeginAlertSheet(	NSLocalizedString(@"SendDlg.AbsenceOff.Title", nil),
                          NSLocalizedString(@"SendDlg.AbsenceOff.OK", nil),
                          NSLocalizedString(@"SendDlg.AbsenceOff.Cancel", nil),
                          nil,
                          window,
                          self,
                          @selector(sheetDidEnd:returnCode:contextInfo:),
                          nil,
                          sender,
                          NSLocalizedString(@"SendDlg.AbsenceOff.Msg", nil),
                          [config absenceTitleAtIndex:config.absenceIndex]);
		return;
	}
    
	// 送信情報整理
	msg		= [sendMessageArea string];
	sealed	= NO;
	locked	= NO;
	to		= [[[NSMutableArray alloc] init] autorelease];
    [to addObject:_talkingUser];
	// 送信情報構築
	info = [SendMessage messageWithMessage:msg
							   attachments:sendAttachments
									  seal:sealed
									  lock:locked];
	// メッセージ送信
	[[MessageCenter sharedCenter] sendMessage:info to:to];
	// ログ出力
	[[LogManager standardLog] writeSendLog:info to:to];

    UserInfo * touser = [to objectAtIndex:0];


    //[messageArea insertTalk:info.message talker:@"你"];
    [messageArea insertTalk:[sendMessageArea string] talker:MY_NICKNAME];

    //关闭附件对话框
    
    [sendAttachments removeAllObjects];
    [sendAttachmentsDic removeAllObjects];
    [sendAttachTable reloadData];
    [sendAttachDrawer close];
    
    [sendMessageArea setString:@""];

}

-(void) sendImgMessage:(NSImage *) img
{
    SendMessage*	info;
	NSMutableArray*	to;
	NSString*		msg;
	BOOL			sealed;
	BOOL			locked;
	NSUInteger		index;
    
    
	// 送信情報整理
	msg		= [sendMessageArea string];
	sealed	= NO;
	locked	= NO;
	to		= [[[NSMutableArray alloc] init] autorelease];
    [to addObject:_talkingUser];
	// 送信情報構築
	info = [SendMessage messageWithMessage:msg
							   attachments:sendAttachments
									  seal:sealed
									  lock:locked];
	// メッセージ送信
	[[MessageCenter sharedCenter] sendScreenImg:img to:to];
    
    UserInfo * touser = [to objectAtIndex:0];
    
    [messageArea insertImg:img talker:MY_NICKNAME];
    //[messageArea insertTalk:[sendMessageArea textStorage] talker:@"你"];
    
    //关闭附件对话框
    [sendAttachments removeAllObjects];
    [sendAttachTable reloadData];
    [sendAttachDrawer close];
    
    [sendMessageArea setString:@""];
}

/*----------------------------------------------------------------------------*
 * 添付ファイル
 *----------------------------------------------------------------------------*/

- (void)appendAttachmentByPath:(NSString*)path {
	AttachmentFile*	file;
	Attachment*		attach;
	file = [AttachmentFile fileWithPath:path];
	if (!file) {
		WRN(@"file invalid(%@)", path);
		return;
	}
	attach = [Attachment attachmentWithFile:file];
	if (!attach) {
		WRN(@"attachement invalid(%@)", path);
		return;
	}
	if ([sendAttachmentsDic objectForKey:path]) {
		WRN(@"already contains attachment(%@)", path);
		return;
	}
	[sendAttachments addObject:attach];
	[sendAttachmentsDic setObject:attach forKey:path];
	[sendAttachTable reloadData];
	[self setAttachHeader];
	[sendAttachDrawer open:self];
}


/*----------------------------------------------------------------------------*
 * 封書関連処理
 *----------------------------------------------------------------------------*/

// 封書ボタン押下時処理
- (IBAction)openSeal:(id)sender {
	if ([recvMsg locked]) {
		// 鍵付きの場合
		// フィールド／ラベルをクリア
		[pwdSheetField setStringValue: @""];
		[pwdSheetErrorLabel setStringValue: @""];
		// シート表示
		[NSApp beginSheet:pwdSheet
		   modalForWindow:window
			modalDelegate:self
		   didEndSelector:@selector(pwdSheetDidEnd:returnCode:contextInfo:)
			  contextInfo:nil];
	} else {
		// 封書消去
		[sender removeFromSuperview];
		[replyButton setEnabled:YES];
		[quotCheck setEnabled:YES];
		[altLogButton setEnabled:[Config sharedConfig].alternateLogEnabled];
		if ([[recvMsg attachments] count] > 0) {
			[attachButton setEnabled:YES];
			[attachDrawer open];
		}

		// 封書開封通知送信
		[[MessageCenter sharedCenter] sendOpenSealMessage:recvMsg];
	}
}

// パスワードシート終了処理
- (void)pwdSheetDidEnd:(NSWindow*)sheet returnCode:(int)code contextInfo:(void*)info {
	[pwdSheet orderOut:self];
}

// パスワード入力シートOKボタン押下時処理
- (IBAction)okPwdSheet:(id)sender {
	NSString*	password	= [Config sharedConfig].password;
	NSString*	input		= [pwdSheetField stringValue];

	// パスワードチェック
	if (password) {
		if ([password length] > 0) {
			if ([input length] <= 0) {
				[pwdSheetErrorLabel setStringValue:NSLocalizedString(@"RecvDlg.PwdChk.NoPwd", nil)];
				return;
			}
			if (![password isEqualToString:[NSString stringWithCString:crypt([input UTF8String], "IP") encoding:NSUTF8StringEncoding]] &&
				![password isEqualToString:input]) {
				// 平文とも比較するのはv0.4までとの互換性のため
				[pwdSheetErrorLabel setStringValue:NSLocalizedString(@"RecvDlg.PwdChk.PwdErr", nil)];
				return;
			}
		}
	}

	// 封書消去
	[replyButton setEnabled:YES];
	[quotCheck setEnabled:YES];
	[altLogButton setEnabled:[Config sharedConfig].alternateLogEnabled];
	if ([[recvMsg attachments] count] > 0) {
		[attachButton setEnabled:YES];
		[attachDrawer open];
	}

	// ログ出力
	if ([recvMsg needLog]) {
		[[LogManager standardLog] writeRecvLog:recvMsg];
		[recvMsg setNeedLog:NO];
	}

	// 封書開封通知送信
	[[MessageCenter sharedCenter] sendOpenSealMessage:recvMsg];

	[NSApp endSheet:pwdSheet returnCode:NSOKButton];
}

// パスワード入力シートキャンセルボタン押下時処理
- (IBAction)cancelPwdSheet:(id)sender {
	[NSApp endSheet:pwdSheet returnCode:NSCancelButton];
}

/*----------------------------------------------------------------------------*
 * 添付ファイル
 *----------------------------------------------------------------------------*/

- (void)downloadSheetRefresh:(NSTimer*)timer {
	if (attachSheetRefreshTitle) {
		unsigned num	= [downloader numberOfTargets];
		unsigned index	= [downloader indexOfTarget] + 1;
		NSString* title = [NSString stringWithFormat:NSLocalizedString(@"RecvDlg.AttachSheet.Title", nil), index, num];
		[attachSheetTitleLabel setStringValue:title];
		attachSheetRefreshTitle = NO;
	}
	if (attachSheetRefreshFileName) {
		[attachSheetFileNameLabel setStringValue:[downloader currentFile]];
		attachSheetRefreshFileName = NO;
	}
	if (attachSheetRefreshFileNum) {
		[attachSheetFileNumLabel setObjectValue:[NSNumber numberWithUnsignedInt:[downloader numberOfFile]]];
		attachSheetRefreshFileNum = NO;
	}
	if (attachSheetRefreshDirNum) {
		[attachSheetDirNumLabel setObjectValue:[NSNumber numberWithUnsignedInt:[downloader numberOfDirectory]]];
		attachSheetRefreshDirNum = NO;
	}
	if (attachSheetRefreshPercentage) {
		[attachSheetPercentageLabel setStringValue:[NSString stringWithFormat:@"%d %%", [downloader percentage]]];
		attachSheetRefreshPercentage = NO;
	}
	if (attachSheetRefreshSize) {
		double		downSize	= [downloader downloadSize];
		double		totalSize	= [downloader totalSize];
		NSString*	str			= nil;
		float		bps;
		if (totalSize < 1024) {
			str = [NSString stringWithFormat:@"%d / %d Bytes", (int)downSize, (int)totalSize];
		}
		if (!str) {
			downSize /= 1024.0;
			totalSize /= 1024.0;
			if (totalSize < 1024) {
				str = [NSString stringWithFormat:@"%.1f / %.1f KBytes", downSize, totalSize];
			}
		}
		if (!str) {
			downSize /= 1024.0;
			totalSize /= 1024.0;
			if (totalSize < 1024) {
				str = [NSString stringWithFormat:@"%.2f / %.2f MBytes", downSize, totalSize];
			}
		}
		if (!str) {
			downSize /= 1024.0;
			totalSize /= 1024.0;
			str = [NSString stringWithFormat:@"%.2f / %.2f GBytes", downSize, totalSize];
		}
		[attachSheetSizeLabel setStringValue:str];
		bps = ((float)[downloader averageSpeed] / 1024.0f);
		if (bps < 1024) {
			[attachSheetSpeedLabel setStringValue:[NSString stringWithFormat:@"%0.1f KBytes/sec", bps]];
		} else {
			bps /= 1024.0;
			[attachSheetSpeedLabel setStringValue:[NSString stringWithFormat:@"%0.2f MBytes/sec", bps]];
		}
		attachSheetRefreshSize = NO;
	}
}

- (void)downloadWillStart {
	[attachSheetTitleLabel setStringValue:NSLocalizedString(@"RecvDlg.AttachSheet.Start", nil)];
	[attachSheetFileNameLabel setStringValue:@""];
	attachSheetRefreshTitle			= NO;
	attachSheetRefreshFileName		= NO;
	attachSheetRefreshFileNum		= YES;
	attachSheetRefreshDirNum		= YES;
	attachSheetRefreshPercentage	= YES;
	attachSheetRefreshSize			= YES;
	[self downloadSheetRefresh:nil];
}

- (void)downloadDidFinished:(DownloadResult)result {
	[attachSheetTitleLabel setStringValue:NSLocalizedString(@"RecvDlg.AttachSheet.Finish", nil)];
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
	[NSApp endSheet:attachSheet returnCode:NSOKButton];
	if ((result != DL_SUCCESS) && (result != DL_STOP)) {
		NSString* msg = nil;
		switch (result) {
		case DL_TIMEOUT:				// 通信タイムアウト
			msg = NSLocalizedString(@"RecvDlg.DownloadError.TimeOut", nil);
			break;
		case DL_CONNECT_ERROR:			// 接続セラー
			msg = NSLocalizedString(@"RecvDlg.DownloadError.Connect", nil);
			break;
		case DL_DISCONNECTED:
			msg = NSLocalizedString(@"RecvDlg.DownloadError.Disconnected", nil);
			break;
		case DL_SOCKET_ERROR:			// ソケットエラー
			msg = NSLocalizedString(@"RecvDlg.DownloadError.Socket", nil);
			break;
		case DL_COMMUNICATION_ERROR:	// 送受信エラー
			msg = NSLocalizedString(@"RecvDlg.DownloadError.Communication", nil);
			break;
		case DL_FILE_OPEN_ERROR:		// ファイルオープンエラー
			msg = NSLocalizedString(@"RecvDlg.DownloadError.FileOpen", nil);
			break;
		case DL_INVALID_DATA:			// 異常データ受信
			msg = NSLocalizedString(@"RecvDlg.DownloadError.InvalidData", nil);
			break;
		case DL_INTERNAL_ERROR:			// 内部エラー
			msg = NSLocalizedString(@"RecvDlg.DownloadError.Internal", nil);
			break;
		case DL_SIZE_NOT_ENOUGH:		// ファイルサイズ以上
			msg = NSLocalizedString(@"RecvDlg.DownloadError.FileSize", nil);
			break;
		case DL_OTHER_ERROR:			// その他エラー
		default:
			msg = NSLocalizedString(@"RecvDlg.DownloadError.OtherError", nil);
			break;
		}
		NSBeginCriticalAlertSheet(	NSLocalizedString(@"RecvDlg.DownloadError.Title", nil),
									NSLocalizedString(@"RecvDlg.DownloadError.OK", nil),
									nil, nil, window, nil, nil, nil, nil, msg, result);
	}
}

- (void)downloadFileChanged {
	attachSheetRefreshFileName = YES;
}

- (void)downloadNumberOfFileChanged {
	attachSheetRefreshFileNum = YES;
}

- (void)downloadNumberOfDirectoryChanged {
	attachSheetRefreshDirNum = YES;
}

- (void)downloadIndexOfTargetChanged {
	attachSheetRefreshTitle	= YES;
}

- (void)downloadTotalSizeChanged {
	[attachSheetProgress setMaxValue:[downloader totalSize]];
	attachSheetRefreshSize = YES;
}

- (void)downloadDownloadedSizeChanged {
	[attachSheetProgress setDoubleValue:[downloader downloadSize]];
	attachSheetRefreshSize = YES;
}

- (void)downloadPercentageChanged {
	attachSheetRefreshPercentage = YES;
}

/*----------------------------------------------------------------------------*
 * NSTableDataSourceメソッド
 *----------------------------------------------------------------------------*/

- (int)numberOfRowsInTableView:(NSTableView*)aTableView {
	if (aTableView == attachTable) {
		return [self.curRcvAttachs count];
	}
    else if (aTableView == sendAttachTable) {
		return [sendAttachments count];
    }
    else {
		ERR(@"Unknown TableView(%@)", aTableView);
	}
	return 0;
}

- (id)tableView:(NSTableView*)aTableView
		objectValueForTableColumn:(NSTableColumn*)aTableColumn
		row:(int)rowIndex {
	if (aTableView == attachTable) {
		Attachment*					attach;
		NSMutableAttributedString*	cellValue;
		NSFileWrapper*				fileWrapper;
		NSTextAttachment*			textAttachment;
		if (rowIndex >= [self.curRcvAttachs count]) {
			ERR(@"invalid index(row=%d)", rowIndex);
			return nil;
		}
		attach = [self.curRcvAttachs objectAtIndex:rowIndex];
		if (!attach) {
			ERR(@"no attachments(row=%d)", rowIndex);
			return nil;
		}
		fileWrapper		= [[NSFileWrapper alloc] initRegularFileWithContents:nil];
		textAttachment	= [[NSTextAttachment alloc] initWithFileWrapper:fileWrapper];
		[(NSCell*)[textAttachment attachmentCell] setImage:attach.icon];
		cellValue		= [[[NSMutableAttributedString alloc] initWithString:[[attach file] name]] autorelease];
		[cellValue replaceCharactersInRange:NSMakeRange(0, 0)
					   withAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
		[cellValue addAttribute:NSBaselineOffsetAttributeName
						  value:[NSNumber numberWithFloat:-3.0]
						  range:NSMakeRange(0, 1)];
		[textAttachment release];
		[fileWrapper release];
		return cellValue;
	} else if (aTableView == sendAttachTable) {
		Attachment*					attach;
		NSMutableAttributedString*	cellValue;
		NSFileWrapper*				fileWrapper;
		NSTextAttachment*			textAttachment;
		attach = [sendAttachments objectAtIndex:rowIndex];
		if (!attach) {
			ERR(@"no attachments(row=%d)", rowIndex);
			return nil;
		}
		fileWrapper		= [[NSFileWrapper alloc] initRegularFileWithContents:nil];
		textAttachment	= [[NSTextAttachment alloc] initWithFileWrapper:fileWrapper];
		[(NSCell*)[textAttachment attachmentCell] setImage:attach.icon];
		cellValue		= [[[NSMutableAttributedString alloc] initWithString:[[attach file] name]] autorelease];
		[cellValue replaceCharactersInRange:NSMakeRange(0, 0)
					   withAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
		[cellValue addAttribute:NSBaselineOffsetAttributeName
						  value:[NSNumber numberWithFloat:-3.0]
						  range:NSMakeRange(0, 1)];
		[textAttachment release];
		[fileWrapper release];
		return cellValue;
	}
    else {
		ERR(@"Unknown TableView(%@)", aTableView);
	}
	return nil;
}

// ユーザリストの選択変更
- (void)tableViewSelectionDidChange:(NSNotification*)aNotification {
	NSTableView* table = [aNotification object];
	if (table == attachTable) {
		float			size	= 0;
		NSUInteger		index;
		NSIndexSet*		selects = [attachTable selectedRowIndexes];
		Attachment*		attach	= nil;

		index = [selects firstIndex];
		while (index != NSNotFound) {
			attach	= [self.curRcvAttachs objectAtIndex:index];
			size	+= (float)[attach file].size / 1024;
			index	= [selects indexGreaterThanIndex:index];
		}
		[attachSaveButton setEnabled:([selects count] > 0)];
        [attachDelButton setEnabled:([selects count] > 0)];
	}  else if (table == sendAttachTable) {
		[sendAttachDelButton setEnabled:([sendAttachTable numberOfSelectedRows] > 0)];
	}
    else {
		ERR(@"Unknown TableView(%@)", table);
	}
}

/*----------------------------------------------------------------------------*
 * その他
 *----------------------------------------------------------------------------*/

- (NSWindow*)window {
	return window;
}

- (NSTextView*)messageArea;
{
    return messageArea;
}

// 一番奥のウィンドウを手前に移動
- (IBAction)backWindowToFront:(id)sender {
	NSArray*	wins	= [NSApp orderedWindows];
	int			i;
	for (i = [wins count] - 1; i >= 0; i--) {
		NSWindow* win = [wins objectAtIndex:i];
		if ([win isVisible] && [[win delegate] isKindOfClass:[ReceiveControl class]]) {
			[win makeKeyAndOrderFront:self];
			break;
		}
	}
}

// メッセージ部フォントパネル表示
- (void)showReceiveMessageFontPanel:(id)sender {
	[[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}

// メッセージ部フォント保存
- (void)saveReceiveMessageFont:(id)sender {
	[Config sharedConfig].receiveMessageFont = [messageArea font];
}

// メッセージ部フォントを標準に戻す
- (void)resetReceiveMessageFont:(id)sender {
	[messageArea setFont:[Config sharedConfig].defaultReceiveMessageFont];
}

// 重要ログボタン押下時処理
- (IBAction)writeAlternateLog:(id)sender
{
	if ([Config sharedConfig].logWithSelectedRange) {
		[[LogManager alternateLog] writeRecvLog:recvMsg withRange:[messageArea selectedRange]];
	} else {
		[[LogManager alternateLog] writeRecvLog:recvMsg];
	}
	[altLogButton setEnabled:NO];
}

// Nibファイルロード時処理
- (void)awakeFromNib {
	Config* config	= [Config sharedConfig];
	NSSize	size	= config.receiveWindowSize;
	NSRect	frame	= [window frame];

	// ウィンドウ位置、サイズ決定
	int sw	= [[NSScreen mainScreen] visibleFrame].size.width;
	int sh	= [[NSScreen mainScreen] visibleFrame].size.height;
	int ww	= [window frame].size.width;
	int wh	= [window frame].size.height;
	frame.origin.x = (sw - ww) / 2 + (rand() % (sw / 4)) - sw / 8;
	frame.origin.y = (sh - wh) / 2 + (rand() % (sh / 4)) - sh / 8;
	if ((size.width != 0) || (size.height != 0)) {
		frame.size.width	= size.width;
		frame.size.height	= size.height;
	}
	[window setFrame:frame display:NO];

	// 引用チェックをデフォルト判定
	if (config.quoteCheckDefault) {
		[quotCheck setState:YES];
	}

	// 添付リストの行設定
	[attachTable setRowHeight:16.0];

	// 添付テーブルダブルクリック時処理
	[attachTable setDoubleAction:@selector(attachTableDoubleClicked:)];

//	[attachSheetProgress setUsesThreadedAnimation:YES];
    
    [self generateImages];
	
	JNWCollectionViewGridLayout *gridLayout = [[JNWCollectionViewGridLayout alloc] initWithCollectionView:collectionVw];
	gridLayout.delegate = self;
	collectionVw.collectionViewLayout = gridLayout;
	collectionVw.dataSource = self;
	[collectionVw registerClass:GridCell.class forCellWithReuseIdentifier:identifier];
	collectionVw.animatesSelection = NO; // (this is the default option)
	
	[collectionVw reloadData];
}

// ウィンドウリサイズ時処理
- (void)windowDidResize:(NSNotification *)notification
{
	// ウィンドウサイズを保存
	[Config sharedConfig].receiveWindowSize = [window frame].size;
}

// ウィンドウクローズ判定処理
- (BOOL)windowShouldClose:(id)sender {
	if (!pleaseCloseMe && ([self.curRcvAttachs count] > 0)) {
		// 添付ファイルが残っているがクローズするか確認
		NSBeginAlertSheet(	NSLocalizedString(@"RecvDlg.CloseWithAttach.Title", nil),
							NSLocalizedString(@"RecvDlg.CloseWithAttach.OK", nil),
							NSLocalizedString(@"RecvDlg.CloseWithAttach.Cancel", nil),
							nil,
							window,
							self,
							@selector(sheetDidEnd:returnCode:contextInfo:),
							nil,
							recvMsg,
							NSLocalizedString(@"RecvDlg.CloseWithAttach.Msg", nil));
		[attachDrawer open];
		return NO;
	}
	if (!pleaseCloseMe && ![replyButton isEnabled]) {
		// 未開封だがクローズするか確認
		NSBeginAlertSheet(	NSLocalizedString(@"RecvDlg.CloseWithSeal.Title", nil),
							NSLocalizedString(@"RecvDlg.CloseWithSeal.OK", nil),
							NSLocalizedString(@"RecvDlg.CloseWithSeal.Cancel", nil),
							nil,
							window,
							self,
							@selector(sheetDidEnd:returnCode:contextInfo:),
							nil,
							recvMsg,
							NSLocalizedString(@"RecvDlg.CloseWithSeal.Msg", nil));
		return NO;
	}

	return YES;
}

// ウィンドウクローズ時処理
- (void)windowWillClose:(NSNotification*)aNotification {
	if ([self.curRcvAttachs count] > 0) {
		// 添付ファイルが残っている場合破棄通知
		[[MessageCenter sharedCenter] sendReleaseAttachmentMessage:recvMsg];
	}
    if (_talkingUser && _talkingUser.hostName) {
        [[WindowManager sharedManager] removeReceiveWindowForKey:_talkingUser.hostName];
    }
	
// なぜか解放されないので手動で
    window = nil;
    messageArea = nil;
    //这里释放的话,再打开会报错
    //[attachDrawer release];
	[self release];
}

- (void)setAttachHeader {
	NSString*		format	= NSLocalizedString(@"RecvDlg.Attach.Header", nil);
	NSString*		title	= [NSString stringWithFormat:format, [self.curRcvAttachs count]];
	[[[attachTable tableColumnWithIdentifier:@"Attachment"] headerCell] setStringValue:title];
}

- (IBAction)screenShotClick:(id)sender {
    NSImage* screenimg = [[NSImage alloc] initWithPasteboard:[NSPasteboard generalPasteboard]];
    if(screenimg)
    {
        NSFileWrapper *imageFileWrapper = [[NSFileWrapper alloc] init];
        //setIcon才会动,否则不会动
        [imageFileWrapper setIcon:screenimg];
        
        NSTextAttachment *imageAttachment = [[[NSTextAttachment alloc] initWithFileWrapper:imageFileWrapper] autorelease];
        NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        NSMutableAttributedString* attrstr = [[NSMutableAttributedString alloc] init];
        [attrstr insertAttributedString:imageAttributedString atIndex:0];;
        
        [sendMessageArea insertText:attrstr];
        //NSImage* testimg= [[NSImage alloc] initWithContentsOfFile:@"/Users/alakenda/Documents/IPMessenger/56b940a6.bmp"];
        //[self sendImgMessage:testimg];
        [self sendImgMessage:screenimg];
    }
}

//文件发送完毕的消息监听响应
- (void) attachSendCompleted:(NSNotification *)notification
{
    
    AttachSendCompPushObj *ackobj = [notification object];
    if(ackobj && [ackobj.user.hostName isEqualTo:_talkingUser.hostName])
    {

        NSString * tips = [[NSString alloc] initWithFormat:@"文件 %@ 发送完成\r",ackobj.file.name];
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSColor grayColor] forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString* attrtxt = [[NSMutableAttributedString alloc] initWithString:tips attributes:dic];
        
        NSLog(@"%@",tips);
        if ([messageArea respondsToSelector:@selector(setEditable:)]) {
            //此处要放到主线程中去插入文本,否则传送多个小文件时此处会崩溃
            dispatch_async(dispatch_get_main_queue(), ^{
                [messageArea setEditable:YES];
                [messageArea insertText:attrtxt];
                [messageArea setEditable:NO];
            });
            
        }
    }

}

//插入表情符号响应
-(void) insertEmotionStr:(NSNotification *)notification
{
    NSDictionary *userinfo = [notification userInfo];
    
    if(self == [userinfo objectForKey:NOTICEDIC_DEST])
    {
        NSString * emotionStr = [userinfo objectForKey:NOTICEDIC_EMOTIONSTR];
        
        NSDictionary* emotiondic = [Config sharedConfig].emotionImgDic;
        
        NSString *imageName = [NSString stringWithFormat:@"%@.gif",[emotiondic valueForKey:emotionStr]];
        NSFileWrapper *imageFileWrapper = [[NSFileWrapper alloc] init];
        //setIcon才会动,否则不会动
        [imageFileWrapper setIcon:[NSImage imageNamed:imageName]];
        
        NSTextAttachment *imageAttachment = [[[NSTextAttachment alloc] initWithFileWrapper:imageFileWrapper] autorelease];
        NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        NSMutableAttributedString* attrstr = [sendMessageArea textStorage];
        //[attrstr insertAttributedString:imageAttributedString atIndex:[attrstr length]];;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [sendMessageArea insertText:emotionStr];
            [emotionDrawer close];
        });

    }
}

//插入远程发送过来的屏幕截图
-(void) insertScreenShotBMP:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    UserInfo* fromUser = [info objectForKey:NOTICEDIC_FROM_USER];
    if ([fromUser.hostName isEqualToString:_talkingUser.hostName]) {
        NSData* bmpData = [info objectForKey:NOTICEDIC_BMPDATA];
        
        NSImage* img = [[NSImage alloc] initWithData:bmpData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [messageArea insertImg:img talker:_talkingUser.userName];
        });
    }
}

#pragma mark Data source

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	GridCell *cell = (GridCell *)[collectionView dequeueReusableCellWithIdentifier:identifier];
    NSDictionary* emotiondic = [Config sharedConfig].emotionImgDic;
    NSArray* array = [emotiondic allKeysForObject:[NSString stringWithFormat:@"%ld",(long)indexPath.jnw_item + 1]];
    if (array != nil && [array count] > 0) {
        cell.emotionStr = [array objectAtIndex:0] ;
        cell.recvCtrl = self;
        cell.image = emotionimages[indexPath.jnw_item];
    }

    
	return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
	return 1;
}

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [[Config sharedConfig].emotionImgDic count];
}

- (CGSize)sizeForItemInCollectionView:(JNWCollectionView *)collectionView {
	return CGSizeMake(25.f, 25.f);
}

#pragma mark Image creation

// To simulate at least something realistic, this just generates some randomly tinted images so that not every
// cell has the same image.
- (void)generateImages {
	NSInteger numberOfImages = [[Config sharedConfig].emotionImgDic count];
	NSMutableArray *images = [NSMutableArray array];
	
	for (int i = 0; i < numberOfImages; i++) {
		
		// Just get a randomly-tinted template image.
		NSImage *image = [NSImage imageWithSize:CGSizeMake(150.f, 150.f) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
			//[[NSImage imageNamed:NSImageNameUser] drawInRect:dstRect fromRect:CGRectZero operation:NSCompositeSourceOver fraction:1];

                [[NSImage imageNamed:[NSString stringWithFormat:@"%d.gif",i + 1 ] ] drawInRect:dstRect fromRect:CGRectZero operation:NSCompositeSourceOver fraction:1];

			
			//CGFloat hue = arc4random() % 256 / 256.0;
			//CGFloat saturation = arc4random() % 128 / 256.0 + 0.5;
			//CGFloat brightness = arc4random() % 128 / 256.0 + 0.5;
			//NSColor *color = [NSColor colorWithCalibratedHue:hue saturation:saturation brightness:brightness alpha:1];
			
			//[color set];
			//NSRectFillUsingOperation(dstRect, NSCompositeDestinationAtop);
			
			return YES;
		}];
		
		[images addObject:image];
	}
	
	emotionimages = images.copy;
}


@end
