//
//  DataUtils.h
//  sing365
//
//  Created by 张 磊 on 13-4-11.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataUtils : NSObject

+(NSDictionary *)getFileInfo:(NSString *)fileName;

+(NSString *)getShowText:(NSDictionary *)menuDict
                 ArrayOf:(NSArray *)menuArray
                      At:(NSIndexPath *)indexPath;
@end
