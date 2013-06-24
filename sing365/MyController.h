//
//  MyController.h
//  LrcTest
//
//  Created by 于 同非 on 06/07/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AVFoundation/AVFoundation.h"
#import <StoreKit/StoreKit.h>

@interface MyController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    AVPlayer * _player;
    NSTimer * _timerPlay;
    UITableView* _tableView;
    NSMutableArray *_arrayItemList;
}
@property(nonatomic, retain) NSMutableArray *arrayItemList;
@property(nonatomic,retain) UISlider *slider;
@property(nonatomic,retain) UIButton *playButton;
@property(nonatomic,retain) UIButton *pauseButton;
@property(nonatomic,retain) UIButton *nextButton;
@property(nonatomic,retain) UIButton *previousButton;


-(id) initWithArrayItem:(NSMutableArray *) arrayItemValue;

@end
