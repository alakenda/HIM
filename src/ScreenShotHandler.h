//
//  ScreenShotHandler.h
//  IPMessenger
//
//  Created by 何谦 on 14-6-26.
//
//

#import <Foundation/Foundation.h>
#import "RecvMessage.h"
#import "UserInfo.h"

@interface ScreenShotHandler : NSObject

+(ScreenShotHandler *) shareScreenShotHandler;
-(ScreenShotHandler * ) init;

-(void) procPacket:(RecvMessage *) msg;
@end
