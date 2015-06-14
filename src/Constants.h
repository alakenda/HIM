//
//  Constants.h
//  IPMessenger
//
//  Created by 何谦 on 14-5-30.
//
//

#import <Foundation/Foundation.h>


extern NSString* const NOTICE_USER_LIST_CHANGED;
extern NSString* const NOTICE_ATTACH_SEND_COMPLETED;
extern NSString* const NOTICE_ATTACH_LIST_CHANGED;
extern NSString* const NOTICE_INSERT_EMOTIONSTR;
extern NSString* const NOTICE_INSERT_SCREENSHOTBMP;

extern NSString* const MY_NICKNAME;

extern NSString* const NOTICEDIC_DEST;
extern NSString* const NOTICEDIC_EMOTIONSTR;
//int const BMP_HEADER_LEN = 14;
extern NSString* const NOTICEDIC_BMPDATA;
extern NSString* const NOTICEDIC_FROM_USER;

extern NSString* const DIR_PRI_ROOT;
extern NSString* const DIR_LOG;
extern NSString* const DIR_Rcv_Photo;

extern NSString* const FILE_STD_LOG;
extern NSString* const FILE_ALT_LOG;

extern int const UDPIMG_PKG_SIZE;
@interface Constants : NSObject

@end
