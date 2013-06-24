//
//  UIViewMusicTypeDelegate.h
//  sing365
//
//  Created by 张 磊 on 13-4-9.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Music.h"

@protocol UIViewMusicTypeDelegate <NSObject>

-(NSString *)passValue;
-(Music *)passMusic;

@end
