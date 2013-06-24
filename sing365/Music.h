//
//  Music.h
//  sing365
//
//  Created by 张 磊 on 13-5-2.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Music : NSObject
@property(nonatomic) int musicId;
@property(nonatomic,retain) NSString *musicName;
@property(nonatomic,retain) NSString *musicSinger;
@property(nonatomic,retain) NSString *downPath;
@property(nonatomic,retain) NSString *lrcPath;
@end
