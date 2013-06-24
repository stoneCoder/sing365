//
//  MusicLrcModel.m
//  LrcTest
//
//  Created by apple on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MusicLrcModel.h"

@interface MusicLrcModel(private)
-(void) setDefaultValuesWithCurrentModel;
-(void) parseLrcSourceData;
-(void) parseLrcLineWithLineText:(NSString *)sourceLineText; // 解析LRC文件的一行数据 支持[time][time]xxx格式
-(NSString *)timeToSecond:(NSString *)formatTime; // 将数据转换成以秒为单位的格式
-(void) parseTempArray:(NSMutableArray *) tempArray; // 解析每一行迭代后的临时文件
-(void)sortAllItem:(NSMutableArray *)array; // 将最终得到的所有数据按时间顺序进行排序
@end

@implementation MusicLrcModel
@synthesize mp3FileServerPath = _mp3FileServerPath;
@synthesize lrcFileServerPath = _lrcFileServerPath;
@synthesize mp3FileLocalPath = _mp3FileLocalPath;
@synthesize lrcFileLocalPath = _lrcFileLocalPath;


- (id)initWithMp3FileServerPath:(NSString *) mp3Path withLrcServerPath:(NSString *) lrcPath
{
    self = [super init];
    if (self) {
        if (mp3Path) {
            _mp3FileServerPath = mp3Path;
        }
        if (lrcPath) {
            _lrcFileServerPath = lrcPath;
        }
        [self setDefaultValuesWithCurrentModel];
    }
    return self;
}




#pragma mark Privat Method

-(void) parseLrcSourceData
{
    if (_lrcFileServerPath) {
        NSError *error = [[[NSError alloc] init] autorelease];
        if (!_lrcFileServerPath)
        {
            NSLog(@"lrc文件为空!!!");
            return;
        }
        NSURL *url = [NSURL URLWithString:_lrcFileServerPath];
        if (url) {
            NSString *sourceText = [NSString stringWithContentsOfFile:_lrcFileLocalPath encoding:NSUTF8StringEncoding error:&error];
            if (!sourceText || sourceText.length <= 0)
            {
                NSLog(@"lrc error = %@",error.description);
                return;
            }
            NSArray * tempArray=[sourceText componentsSeparatedByString:@"\n"];
            for (NSString *str in tempArray)
            {
                if (str && str.length > 0)
                {
                    [_arrayTemp removeAllObjects]; // 清除数组里面的临时数据
                    [self parseLrcLineWithLineText:str];
                    [self parseTempArray:_arrayTemp];
                }
            }
            if (_arrayItemList && _arrayItemList.count > 0)
                [self sortAllItem:_arrayItemList];
        }else
        {
            NSLog(@"创建lrc - url无效");
        }
    }

}
-(void) parseLrcLineWithLineText:(NSString *)sourceLineText{
    if (!sourceLineText || sourceLineText.length <= 0)
        return;
    NSRange range = [sourceLineText rangeOfString:@"]"];
    if (range.length > 0)
    {
        NSString * time = [sourceLineText substringToIndex:range.location + 1];
        NSLog(@"time = %@",time);
        NSString * other = [sourceLineText substringFromIndex:range.location + 1];
        NSLog(@"other = %@",other);
        if (time && time.length > 0)
            [_arrayTemp addObject:time];
        if (other)
            [self parseLrcLineWithLineText:other];
    }else
    {
        [_arrayTemp addObject:sourceLineText];
    }
}

-(NSString *)timeToSecond:(NSString *)formatTime {
    if (!formatTime || formatTime.length <= 0)
        return nil;
    if ([formatTime rangeOfString:@"["].length <= 0 && [formatTime rangeOfString:@"]"].length <= 0)
        return nil;
    NSString * minutes = [formatTime substringWithRange:NSMakeRange(1, 2)];
    NSString * second = [formatTime substringWithRange:NSMakeRange(4, 5)];
    float finishSecond = minutes.floatValue * 60 + second.floatValue;
    return [NSString stringWithFormat:@"%f",finishSecond];
}

-(void) parseTempArray:(NSMutableArray *) tempArray
{
    if (!tempArray || tempArray.count <= 0)
        return;
    NSString *value = [tempArray lastObject];
    if (!value || ([value rangeOfString:@"["].length > 0 && [value rangeOfString:@"]"].length > 0))
    {
        [_arrayTemp removeAllObjects];
        return;
    }

    for (int i = 0; i < tempArray.count - 1; i++)
    {
        NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
        NSString * key = [tempArray objectAtIndex:(NSUInteger)i];
        NSString *secondKey = [self timeToSecond:key]; // 转换成以秒为单位的时间计数器
        [dic setObject:value forKey:secondKey];
        [_arrayItemList addObject:dic];
    }
    [_arrayTemp removeAllObjects];

}

// 以时间顺序进行排序
-(void)sortAllItem:(NSMutableArray *)array {
    if (!array || array.count <= 0)
        return;
    for (int i = 0; i < array.count - 1; i++)
    {
        for (int j = i + 1; j < array.count; j++)
        {
            id firstDic = [array objectAtIndex:(NSUInteger )i];
            id secondDic = [array objectAtIndex:(NSUInteger)j];
            if (firstDic && [firstDic isKindOfClass:[NSDictionary class]] && secondDic && [secondDic isKindOfClass:[NSDictionary class]])
            {
                NSString *firstTime = [[firstDic allKeys] objectAtIndex:0];
                NSString *secondTime = [[secondDic allKeys] objectAtIndex:0];
                BOOL b = firstTime.floatValue > secondTime.floatValue;
                if (b) // 第一句时间大于第二句，就要进行交换
                {
                    [array replaceObjectAtIndex:(NSUInteger )i withObject:secondDic];
                    [array replaceObjectAtIndex:(NSUInteger )j withObject:firstDic];
                }
            }
        }
    }
}

-(void) setDefaultValuesWithCurrentModel
{
    if (!_arrayTemp)
    {
        _arrayTemp = [[NSMutableArray alloc] init];
    }

    if (!_arrayItemList) {
        _arrayItemList = [[NSMutableArray alloc] init];
    }
    //[self parseLrcSourceData];
}

-(void)musicDownloadSuccess:(id)sender {
    NSLog(@"Music download success!!!");
    if ([[sender objectForKey:@"downloadType"] isEqualToString:@"lrc"]) {
        _lrcFileLocalPath = [sender objectForKey:@"downloadKey"];
    } else if([[sender objectForKey:@"downloadType"] isEqualToString:@"mp3"]) {
        _mp3FileLocalPath = [sender objectForKey:@"downloadKey"];
    }
}

-(void)musicDownloadFail:(id)sender {
    NSLog(@"Music download fail!!!");
}

-(void)dealloc {
    [_arrayTemp release];
    _arrayTemp = nil;
    [_arrayItemList release];
    _arrayItemList = nil;
    [_mp3FileServerPath release];
    [_lrcFileServerPath release];
//    [_mp3FileLocalPath release];
//    [_lrcFileLocalPath release];
    [super dealloc];
}

@end
