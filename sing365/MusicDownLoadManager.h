//
//  Created by YuTongFei on 12-7-13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ASIHTTPRequest.h"
#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "MusicModelProtocol.h"
@class MusicLrcModel;

@interface MusicDownLoadManager : NSObject {
    ASINetworkQueue *_queue;
}

+(MusicDownLoadManager *) shared;
-(void) loadMusic:(MusicLrcModel *) musicLrcModel;
@end