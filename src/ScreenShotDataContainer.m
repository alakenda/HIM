//
//  ScreenShotDataContainer.m
//  IPMessenger
//
//  Created by 何谦 on 14-7-1.
//
//

#import "ScreenShotDataContainer.h"
#import "RecvMessage.h"
#import "ScreenShotPkgHeader.h"
#import "Constants.h"
#import "MessageCenter.h"
#import "Constants.h"

static int const BMP_HEADER_LEN = 14;

@implementation ScreenShotDataContainer
{
    //截图数据
    NSMutableData * bmpdata;
    
    //图像头长度
    int fileHeaderLen;
    
    //图像数据总长度
    int fileTotalLen;

    //bmp数据头
    //ScreenShotPkgHeader * bmpHeader

    //包接收标识位
    NSMutableArray* receiveFlagArray;
    //总包数
    long totalPkg;
    //当前接收的包总数
    long curRcvPkg;
    
    //bmp数据包是否接收完成
    BOOL isCompleted;
    
    //常量:false
    NSNumber* falseFlag;
    //常量:ture
    NSNumber* trueFlag;
    
}

-(ScreenShotDataContainer*) init:(RecvMessage *) msg
{
    self = [self init];
    
    falseFlag = [NSNumber numberWithBool:NO];
    trueFlag = [NSNumber numberWithBool:YES];

    //ScreenShotPkgHeader* bmpHeader = msg.bmpHeader;
    fileHeaderLen = [self getFileHeaderLenByType:msg];
    fileTotalLen = msg.bmpHeader.totoalByte + fileHeaderLen;

    bmpdata = [[NSMutableData alloc] initWithLength:fileTotalLen];
    
    [self insertHeader:msg];
    
    receiveFlagArray = [[NSMutableArray alloc] init];
    //NSEnumerator* en = [receiveFlagArray objectEnumerator];
    //NSObject* flagint = nil;
    //while (flagint = [en nextObject]) {
    for (int i = 0; i < msg.bmpHeader.totalPkg; i ++) {
        NSNumber* flag = [NSNumber numberWithBool:NO];
        [receiveFlagArray addObject:flag];
    }
    
    totalPkg = msg.bmpHeader.totalPkg;
    curRcvPkg = 0;
    
    isCompleted = NO;
    
    [self insertData:msg];

    return self;
}

//获取不同类型文件的头长度
-(int) getFileHeaderLenByType : (RecvMessage *) msg
{
    switch (msg.bmpHeader.flag1) {
            //BMP文件头
        case 1:
            return BMP_HEADER_LEN;
            break;
            
        default:
            return 0;
            break;
    }
}

//插入图像的文件头数据
-(void) insertHeader:(RecvMessage *) msg
{
    char bmpFileheader[BMP_HEADER_LEN] = {'\x42','\x4d','\x00','\x00','\x00','\x00','\x00','\x00','\x00','\x00','\x36','\x00','\x00','\x00'};
    
    switch (msg.bmpHeader.flag1) {
            //BMP文件头
        case 1:
            bmpFileheader[2] = fileTotalLen & 0x000000FF;
            bmpFileheader[3] = (fileTotalLen & 0x0000FF00) >> 8;
            bmpFileheader[4] = (fileTotalLen & 0x00FF0000) >> 16;
            bmpFileheader[5] = (fileTotalLen & 0xFF000000) >> 24;

            NSRange replaceRange;
            replaceRange.location = 0;
            replaceRange.length = BMP_HEADER_LEN;
            [bmpdata replaceBytesInRange:replaceRange withBytes:bmpFileheader length:BMP_HEADER_LEN];
            break;
            
        default:
            break;
    }
}

-(void) insertData:(RecvMessage *) msg
{
    if (msg.bmpHeader) {
        NSNumber* flag = [receiveFlagArray objectAtIndex:msg.bmpHeader.curPkgNo - 1];
        if (![flag boolValue]) {
            NSRange replaceRange;
            replaceRange.location = msg.bmpHeader.startByte + fileHeaderLen;
            replaceRange.length = msg.bmpHeader.pkgLen;
            
            [bmpdata replaceBytesInRange:replaceRange withBytes:[msg.binData bytes] length:msg.bmpHeader.pkgLen];
            
            [receiveFlagArray replaceObjectAtIndex:(msg.bmpHeader.curPkgNo -1) withObject:trueFlag];
            
            curRcvPkg ++;
            if (curRcvPkg == totalPkg) {
                [bmpdata writeToFile:[NSString stringWithFormat:@"%@/%@.bmp",[DIR_Rcv_Photo stringByExpandingTildeInPath],msg.bmpHeader.bmpName] atomically:YES];
                
                isCompleted = YES;
                //NSLog(@"bmpdata complete");
            }
        }
        else
        {
            NSLog(@"double data");
        }
    }
}

-(BOOL) isPkgRcvCompleted
{
    return isCompleted;
}

-(NSData*) getBmpData
{
    if (isCompleted) {
        return bmpdata;
    }
    else
    {
        return nil;
    }
}

@end
