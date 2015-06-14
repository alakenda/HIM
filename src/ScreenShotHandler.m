//
//  ScreenShotHandler.m
//  IPMessenger
//
//  Created by 何谦 on 14-6-26.
//
//

#import "ScreenShotHandler.h"
#import "IPMessenger.h"
#import "NSStringIPMessenger.h"
#import "ScreenShotPkgHeader.h"
#import "MessageCenter.h"
#import "ScreenShotDataContainer.h"
#import "Constants.h"

@implementation ScreenShotHandler
{
    NSMutableDictionary * dataPool;
    int sendcount;
}

+(ScreenShotHandler *) shareScreenShotHandler;
{
    static ScreenShotHandler * share = nil;
    if (!share) {
        share = [[ScreenShotHandler alloc] init];

    }
    return share;
}

-(ScreenShotHandler * ) init;
{
    self = [super init];
    dataPool = [[NSMutableDictionary alloc] init];
    sendcount = 0;
    return self;
}

-(void) procPacket:(RecvMessage *) msg
{
    if (msg.bmpHeader) {
        ScreenShotDataContainer* container = [dataPool objectForKey:msg.bmpHeader.bmpName];
        if (container) {
            [container insertData:msg];
            
            //flag1=1  非压缩BMP
            //flag2==2 非压缩jpg图像
            if ([container isPkgRcvCompleted] && (msg.bmpHeader.flag1 == 1 || msg.bmpHeader.flag2 == 2)) {
                NSMutableDictionary* userinfo = [[NSMutableDictionary alloc] init];
                [userinfo setObject:[container getBmpData] forKey:NOTICEDIC_BMPDATA];
                [userinfo setObject:msg.fromUser forKey:NOTICEDIC_FROM_USER];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_INSERT_SCREENSHOTBMP object:self userInfo:userinfo];
                [dataPool removeObjectForKey:msg.bmpHeader.bmpName];

            }
        }
        else
        {
            container = [[ScreenShotDataContainer alloc] init:msg];
            [dataPool setObject:container forKey:msg.bmpHeader.bmpName];
        }
        
        //发送回应报给截图发送方
        //NSLog(@"send ack no:%d",msg.bmpHeader.curPkgNo);
        [[MessageCenter sharedCenter] sendTo:msg.fromUser messageID:-1 command:IPMSG_RECVSCREENSHOT message:[NSString stringWithFormat:@"%@|%d#",msg.bmpHeader.bmpName,msg.bmpHeader.curPkgNo] option:nil];
        sendcount ++;
        /*if (sendcount > 1500) {
            //usleep(100000);
            sleep(1);
            NSLog(@"sleep 1");
            sendcount = 0;
        }*/
    }
    /*
    ScreenShotPkgHeader * header = [msg getScreenShotPkgHeader];
    NSMutableData* bmpData = nil;
    if (header) {
        NSLog(@"pkg No:%d",header.curPkgNo);
        if (header.curPkgNo == 1) {
            bmpData = [[NSMutableData alloc] initWithLength:header.totoalByte];
            [dataPool setObject:bmpData forKey:header.bmpName];
        }
        else
        {
            bmpData = [dataPool objectForKey:header.bmpName];
        }
        
        if ([msg.binData length]> 0) {
            NSRange replaceRange;
            replaceRange.location = header.startByte;
            replaceRange.length = header.pkgLen;
            
            [bmpData replaceBytesInRange:replaceRange withBytes:[msg.binData bytes] length:header.pkgLen];
        }

        
        if (header.curPkgNo == header.totalPkg) {
            int bmplen = header.totoalByte + 14;
            char bmpheader[14] = {'\x42','\x4d','\x00','\x00','\x00','\x00','\x00','\x00','\x00','\x00','\x36','\x00','\x00','\x00'};
            bmpheader[2] = bmplen & 0x000000FF;
            bmpheader[3] = (bmplen & 0x0000FF00) >> 8;
            bmpheader[4] = (bmplen & 0x00FF0000) >> 16;
            bmpheader[5] = (bmplen & 0xFF000000) >> 24;
            
            NSMutableData * newbmpData = [[NSMutableData alloc] initWithBytes:bmpheader length:bmplen];
            NSRange replaceRange;
            replaceRange.location = 14;
            replaceRange.length = header.totoalByte;
            [newbmpData replaceBytesInRange:replaceRange withBytes:[bmpData mutableBytes] length:header.totoalByte];

            [dataPool removeObjectForKey:header.bmpName];
            [dataPool setObject:newbmpData forKey:header.bmpName];
            
            [newbmpData writeToFile:[NSString stringWithFormat:@"/Users/alakenda/Documents/%@.bmp",header.bmpName] atomically:YES];
            NSLog(@"screenshot complete");
        }
        [[MessageCenter sharedCenter] sendTo:fromUser messageID:-1 command:IPMSG_RECVSCREENSHOT message:[NSString stringWithFormat:@"%@|%d#",header.bmpName,header.curPkgNo] option:nil];
    }
    else
    {
        NSLog(@"ScreenShotPkgHeader is nil");
    }
     */
}

@end
