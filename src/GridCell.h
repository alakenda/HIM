//
//  GridCell.h
//  IPMessenger
//
//  Created by 何谦 on 14-5-29.
//
//

#import <JNWCollectionView/JNWCollectionView.h>
#import "ReceiveControl.h"


@interface GridCell : JNWCollectionViewCell

//@property (nonatomic, strong) JNWLabel *label;
@property (nonatomic, strong) NSString *emotionStr;
@property (nonatomic, strong) ReceiveControl *recvCtrl;
@property (nonatomic, strong) NSImage *image;
@end
