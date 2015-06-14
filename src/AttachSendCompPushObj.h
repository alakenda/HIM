//
//  AttachSendCompPushObj.h
//  IPMessenger
//
//  Created by 何谦 on 14-5-12.
//
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "AttachmentFile.h"

@interface AttachSendCompPushObj : NSObject
{
    UserInfo*               user;
    AttachmentFile*			file;
}

@property (strong,readwrite) UserInfo*                  user;
@property (strong,readwrite) AttachmentFile*			file;

@end
