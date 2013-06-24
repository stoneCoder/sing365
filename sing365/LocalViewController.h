//
//  LocalViewController.h
//  sing365
//
//  Created by 张 磊 on 13-4-8.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewMusicTypeDelegate.h"

@interface LocalViewController : UITableViewController<UIViewMusicTypeDelegate,UITableViewDataSource>
{
    NSArray *menuArray;
    NSDictionary *menuDict;
    NSString *checkValue;
}

@property(nonatomic,retain) NSArray *menuArray;
@property(nonatomic,retain) NSDictionary *menuDict;
@property(nonatomic,retain) NSString *checkValue;


@end
