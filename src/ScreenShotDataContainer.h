//
//  ScreenShotDataContainer.h
//  IPMessenger
//
//  Created by 何谦 on 14-7-1.
//
//

#import <Foundation/Foundation.h>
#import "RecvMessage.h"

@interface ScreenShotDataContainer : NSObject

-(ScreenShotDataContainer*) init:(RecvMessage *) msg;
-(void) insertData:(RecvMessage *) msg;
-(BOOL) isPkgRcvCompleted;
-(NSData*) getBmpData;
@end
