//
//  MusicPlayController.h
//  sing365
//
//  Created by 张 磊 on 13-5-5.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
#import "UIViewMusicTypeDelegate.h"
@class MyController;
@interface MusicPlayController : UIViewController
{
    NSMutableArray *_tempArrayList;
    NSMutableArray *_arrayItemList;
    MyController *_myController;
    NSObject<UIViewMusicTypeDelegate> *delegate;
}

@property(nonatomic,retain) NSObject<UIViewMusicTypeDelegate> *delegate;
@end
