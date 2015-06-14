//
//  ScreenShotPkgHeader.m
//  IPMessenger
//
//  Created by 何谦 on 14-6-27.
//
//

#import "ScreenShotPkgHeader.h"
#import "Constants.h"

@implementation ScreenShotPkgHeader

-(NSString* ) getHeaderString
{
    return [NSString stringWithFormat:@"%@|%ld|%ld|%d|%d|%d|%d|%d|%d|00000000#\0",self.bmpName,self.totoalByte,self.startByte,self.totalPkg,self.curPkgNo,self.pkgLen,self.flag1,self.flag2,self.flag3];
}
@end
