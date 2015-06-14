//
//  Constants.m
//  IPMessenger
//
//  Created by 何谦 on 14-5-30.
//
//

#import "Constants.h"

//通知消息常量
NSString* const NOTICE_USER_LIST_CHANGED = @"Notic_User_List_Change";
NSString* const NOTICE_ATTACH_SEND_COMPLETED = @"Notice_Attach_Send_Completed";
NSString* const NOTICE_ATTACH_LIST_CHANGED = @"Notice_Attach_List_Change";
NSString* const NOTICE_INSERT_EMOTIONSTR = @"Notice_Insert_EmotionStr";
NSString* const NOTICE_INSERT_SCREENSHOTBMP = @"Notic_Insert_ScreenShotBMP";

NSString* const MY_NICKNAME = @"你";

//通知消息所附带信息相关常量
NSString* const NOTICEDIC_DEST = @"Dest";
NSString* const NOTICEDIC_EMOTIONSTR = @"EmotionStr";
NSString* const NOTICEDIC_BMPDATA =@"BMPData";
NSString* const NOTICEDIC_FROM_USER = @"FromUser";

NSString* const DIR_PRI_ROOT = @"~/Documents/IPMessenger/";
NSString* const DIR_LOG = @"~/Documents/IPMessenger/log/";
NSString* const DIR_Rcv_Photo = @"~/Documents/IPMessenger/rcvphoto/";

NSString* const FILE_STD_LOG = @"~/Documents/IPMessenger/log/ipmsg_log.txt";
NSString* const FILE_ALT_LOG = @"~/Documents/IPMessenger/log/ipmsg_alt_log.txt";

//int const BMP_HEADER_LEN = 14;
int const UDPIMG_PKG_SIZE = 512;
@implementation Constants


@end
