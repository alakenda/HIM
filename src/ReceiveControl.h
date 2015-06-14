/*============================================================================*
 * (C) 2001-2011 G.Ishiwata, All Rights Reserved.
 *
 *	Project		: IP Messenger for Mac OS X
 *	File		: ReceiveControl.h
 *	Module		: 受信メッセージウィンドウコントローラ
 *============================================================================*/

#import <Cocoa/Cocoa.h>
#import "MessageCenter.h"
#import "AttachmentClient.h"
#import "TalkTextView.h"
#import "JNWCollectionView/JNWCollectionView.h"
#import <JNWCollectionView/JNWCollectionViewGridLayout.h>
@class RecvMessage;

/*============================================================================*
 * クラス定義
 *============================================================================*/

@interface ReceiveControl : NSObject <AttachmentClientListener,JNWCollectionViewDataSource,JNWCollectionViewGridLayoutDelegate>
{
	IBOutlet NSWindow*				window;						// ウィンドウ
	IBOutlet NSBox*					infoBox;					// ヘッダ部BOX
	IBOutlet NSTextField*			userNameLabel;				// 送信元ユーザ名ラベル
	IBOutlet NSTextField*			dateLabel;					// 受信日時ラベル
	IBOutlet NSButton*				altLogButton;				// 重要ログボタン
	IBOutlet NSButton*				quotCheck;					// 引用チェックボックス
	IBOutlet NSButton*				replyButton;				// 返信ボタン
	IBOutlet NSButton*				sealButton;					// 封書ボタン（メッセージ部のカバー）
    IBOutlet TalkTextView*			messageArea;				// メッセージ部
    IBOutlet NSTextView*            sendMessageArea;            // 发送消息对话框
	IBOutlet NSButton*				attachButton;				// 添付ボタン
	IBOutlet NSDrawer*				attachDrawer;				// 添付ファイルDrawer
    IBOutlet NSDrawer*              sendAttachDrawer;           // 发送附件Drawer
	IBOutlet NSTableView*			attachTable;				// 添付ファイル一覧
	IBOutlet NSButton*				attachSaveButton;			// 添付保存ボタン
    IBOutlet NSButton*              attachDelButton;            // 附件删除
    IBOutlet NSTableView*           sendAttachTable;            // 发送附件列表
    IBOutlet NSButton *             sendAttachAddButton;        // 发送附件添加按钮
    IBOutlet NSButton *             sendAttachDelButton;        // 发送附件删除按钮
	IBOutlet NSPanel*				pwdSheet;					// パスワード入力パネル（シート）
	IBOutlet NSTextField*			pwdSheetErrorLabel;			// パスワード入力パネルエラーラベル
	IBOutlet NSSecureTextField*		pwdSheetField;				// パスワード入力パネルテキストフィールド
	IBOutlet NSPanel*				attachSheet;				// ダウンロードシート
	IBOutlet NSTextField*			attachSheetTitleLabel;		// ダウンロードシートタイトルラベル
	IBOutlet NSTextField*			attachSheetSpeedLabel;		// ダウンロードシート転送速度ラベル
	IBOutlet NSTextField*			attachSheetFileNameLabel;	// ダウンロードシートファイル名ラベル
	IBOutlet NSTextField*			attachSheetPercentageLabel;	// ダウンロードシート％ラベル
	IBOutlet NSTextField*			attachSheetFileNumLabel;	// ダウンロードシートファイル数ラベル
	IBOutlet NSTextField*			attachSheetDirNumLabel;		// ダウンロードシートフォルダ数ラベル
	IBOutlet NSTextField*			attachSheetSizeLabel;		// ダウンロードシートサイズラベル
	IBOutlet NSProgressIndicator*	attachSheetProgress;		// ダウンロードシートプログレスバー
	IBOutlet NSButton*				attachSheetCancelButton;	// ダウンロードシートキャンセルボタン
 	RecvMessage*					recvMsg;					// 受信メッセージ
	BOOL							pleaseCloseMe;				// 閉じる確認済みか？
	AttachmentClient*				downloader;					// ダウンロードオブジェクト
	NSTimer*						attachSheetRefreshTimer;	// ダウンロードシート更新タイマ
	BOOL							attachSheetRefreshFileName;	// ダウンロードシード更新フラグ
	BOOL							attachSheetRefreshPercentage;
	BOOL							attachSheetRefreshTitle;
	BOOL							attachSheetRefreshFileNum;
	BOOL							attachSheetRefreshDirNum;
	BOOL							attachSheetRefreshSize;
    
    NSMutableArray*                 sendAttachments;		// 添付ファイル
	NSMutableDictionary*            sendAttachmentsDic;		// 添付ファイル辞書
    
    
    IBOutlet NSDrawer *             emotionDrawer;          //表情抽屉
    IBOutlet JNWCollectionView *    collectionVw;           //表情图墙
    NSArray *                       emotionimages;          //表情图
}

@property(strong,readonly)UserInfo*                 talkingUser;
@property(strong,readwrite)NSMutableArray*          curRcvAttachs;


// 初期化（ウィンドウは表示しない）
- (id)initWithRecvMessage:(UserInfo*)userinfo ;
- (void)updateRecvMessage:(RecvMessage*)msg;
// ウィンドウの表示
- (void)showWindow;
// ハンドラ
- (IBAction)buttonPressed:(id)sender;
- (IBAction)rcvAttachDelButton:(id)sender;

- (IBAction)openSeal:(id)sender;
- (IBAction)replyMessage:(id)sender;
- (IBAction)writeAlternateLog:(id)sender;
- (IBAction)cancelPwdSheet:(id)sender;
- (IBAction)okPwdSheet:(id)sender;
// その他
- (IBAction)backWindowToFront:(id)sender;
- (NSWindow*)window;
- (NSTextView*)messageArea;
- (void)setAttachHeader;
- (IBAction)screenShotClick:(id)sender;

@end
