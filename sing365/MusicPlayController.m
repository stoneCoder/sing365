//
//  MusicPlayController.m
//  sing365
//
//  Created by 张 磊 on 13-5-5.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import "MusicPlayController.h"
#import "MyController.h"
#import "MusicLrcModel.h"
#import "MusicDownLoadManager.h"
#import "Music.h"

@interface MusicPlayController (private)
-(NSString*) parseLrcLine:(NSString *)sourceLineText;
-(BOOL) sortForPlayData:(NSString*) firstData WithSecondData:(NSString *)secondData;
-(void) parseTempArray:(NSMutableArray *) tempArray;
-(void) sortAllItem:(NSMutableArray *) array;
-(NSString*) timeToSecond:(NSString *) formatTime;
@end

@implementation MusicPlayController
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
//    NSString *serverPath = @"http://192.168.1.102:8080/sing365/music/";
//    NSString *musicDownLoadPath = [serverPath stringByAppendingString:music.musicName];
//    NSLog(@"the music name is %@",music.musicName);
    Music *music = [delegate passMusic];
   
    MusicLrcModel *lrcModel = [[MusicLrcModel alloc] initWithMp3FileServerPath:music.downPath withLrcServerPath:music.lrcPath];

    [[MusicDownLoadManager shared] loadMusic:lrcModel];
    
    if (!_tempArrayList)
    {
        _tempArrayList = [[NSMutableArray alloc] init];
    }
    
    if (!_arrayItemList)
    {
        _arrayItemList = [[NSMutableArray alloc] init];
    }
    NSString * textContent = [NSString stringWithContentsOfFile:lrcModel.lrcFileLocalPath encoding:NSUTF8StringEncoding error:nil];
    NSArray * tempArray=[textContent componentsSeparatedByString:@"\n"];
    
    
    for (NSString * str in tempArray)
    {
        if (!str || str.length <= 0)
            continue;
        [self parseLrcLine:str];
        [self parseTempArray:_tempArrayList];
    }
    
    [self sortAllItem:_arrayItemList];
    _myController = [[MyController alloc] initWithArrayItem:_arrayItemList];
    [self.view addSubview:_myController.view];
    [self.view.superview setHidden:YES];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [music retain];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// 解析每一行，将每一行的[time]和内容分开
-(NSString*) parseLrcLine:(NSString *)sourceLineText
{
    if (!sourceLineText || sourceLineText.length <= 0)
        return nil;
    NSRange range = [sourceLineText rangeOfString:@"]"];
    if (range.length > 0)
    {
        NSString * time = [sourceLineText substringToIndex:range.location + 1];
        NSString * other = [sourceLineText substringFromIndex:range.location + 1];
        if (time && time.length > 0)
            [_tempArrayList addObject:time];
        if (other)
            [self parseLrcLine:other];
    }else
    {
        [_tempArrayList addObject:sourceLineText];
    }
    return nil;
    
}

-(BOOL) sortForPlayData:(NSString*) firstData WithSecondData:(NSString *)secondData
{
    NSString * firstMinute = [firstData substringWithRange:NSMakeRange(1, 2)];
    int i_firstMinute = firstMinute.intValue;
    
    NSString * secondMinute = [secondData substringWithRange:NSMakeRange(1, 2)];
    int i_secondMinute = secondMinute.intValue;
    
    if (i_firstMinute > i_secondMinute)
    {
        return YES;
    }else if (i_firstMinute == i_secondMinute)
    {
        NSString * firstS = [firstData substringWithRange:NSMakeRange(4, 5)];
        float f_FirstS = firstS.floatValue;
        
        NSString * secondS = [secondData substringWithRange:NSMakeRange(4, 5)];
        float f_SecondS = secondS.floatValue;
        
        if (f_FirstS > f_SecondS)
            return YES;
        else
            return NO;
    }
    else
    {
        return NO;
    }
    
}

-(void) parseTempArray:(NSMutableArray *) tempArray
{
    if (!tempArray || tempArray.count <= 0)
        return;
    NSString *value = [tempArray lastObject];
    if (!value || ([value rangeOfString:@"["].length > 0 && [value rangeOfString:@"]"].length > 0))
    {
        [_tempArrayList removeAllObjects];
        return;
    }
    
    for (int i = 0; i < tempArray.count - 1; i++)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSString * key = [tempArray objectAtIndex:(NSUInteger)i];
        NSString *secondKey = [self timeToSecond:key]; // 转换成以秒为单位的时间计数器
        [dic setObject:value forKey:secondKey];
        [_arrayItemList addObject:dic];
    }
    [_tempArrayList removeAllObjects];
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

-(void)dealloc
{
    [_tempArrayList release];
    [_arrayItemList release];
    [super dealloc];
}

@end
