//
//  ScreenShotPkgHeader.h
//  IPMessenger
//
//  Created by 何谦 on 14-6-27.
//
//

#import <Foundation/Foundation.h>

@interface ScreenShotPkgHeader : NSObject
//屏幕截图文件名
@property (strong) NSString * bmpName;
//总字节数
@property long totoalByte;
//当前包的第一个字节是整个包的第几个字节
@property long startByte;
//总包数
@property int totalPkg;
//当前包序号
@property int curPkgNo;
//当前包长度
@property int pkgLen;
//屏幕截图标数据存储方式识位,
//1 表示数据未压缩 即BMP格式
@property int flag1;

//屏幕截图标数据存储方式识位,
//1 表示数据是LZW压缩格式
//2 表示数据是JPG格式
@property int flag2;


//屏幕截图标数据存储方式识位
@property int flag3;

-(NSString* ) getHeaderString;

@end
