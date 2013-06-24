//
//  DataUtils.m
//  sing365
//
//  Created by 张 磊 on 13-4-11.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import "DataUtils.h"

@implementation DataUtils

+(NSDictionary *)getFileInfo:(NSString *)fileName
{
    //获取资源文件
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    return [[NSDictionary alloc] initWithContentsOfFile:filePath];
}

+(NSString *)getShowText:(NSDictionary *)menuDict
                 ArrayOf:(NSArray *)menuArray
            At:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    NSString *menuName = [menuArray objectAtIndex:section];
    NSArray *cellArray = [menuDict objectForKey:menuName];
    return [cellArray objectAtIndex:row];
}

@end
