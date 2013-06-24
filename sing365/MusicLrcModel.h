//
//  MusicLrcModel.h
//  LrcTest
//
//  Created by apple on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicModelProtocol.h"
@interface MusicLrcModel : NSObject<MusicModelProtocol>
{
    NSString *_mp3FileServerPath; // 音乐mp3文件的服务器路径
    NSString *_lrcFileServerPath; // 音乐的lrc文件的服务器路径

    NSString *_mp3FileLocalPath; // mp3文件的本地存储路径
    NSString *_lrcFileLocalPath; // lrc文件的本地存储路径

    NSMutableArray *_arrayTemp; // 临时的数组，用来存储每次迭代后的数据
    NSMutableArray *_arrayItemList; // 存储解析后的数据

}
@property(nonatomic, copy) NSString *mp3FileServerPath;
@property(nonatomic, copy) NSString *lrcFileServerPath;
@property(nonatomic, copy) NSString *mp3FileLocalPath;
@property(nonatomic, copy) NSString *lrcFileLocalPath;


- (id)initWithMp3FileServerPath:(NSString *) mp3Path withLrcServerPath:(NSString *) lrcPath;
@end
