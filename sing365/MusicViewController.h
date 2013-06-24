//
//  MusicViewController.h
//  sing365
//
//  Created by 张 磊 on 13-4-9.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewMusicTypeDelegate.h"

@interface MusicViewController : UITableViewController
{
    NSObject<UIViewMusicTypeDelegate> *delegate;
}

@property(nonatomic,retain) NSObject<UIViewMusicTypeDelegate> *delegate;

@end
