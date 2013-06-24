//
//  Created by YuTongFei on 12-7-13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MusicDownLoadManager.h"
#import "MusicLrcModel.h"

#define kDownloadType_MP3 @"mp3"
#define kDownloadType_LRC @"lrc"
#define kMusicDirectory @"musicDownloadDir"
#define kDownloadPathKey @"downloadKey"
#define kDownloadType @"downloadType"

static MusicDownLoadManager *instance;
@interface MusicDownLoadManager(Private)
-(void) setDefaultValuesWithCurrentObject;
-(void) queueDownloadSuccess:(ASIHTTPRequest *) request;
-(void) queueDownloadFail:(ASIHTTPRequest *) request;
-(NSString *) nameForDownloadPath:(NSString *) downLoadPath;
-(NSString *) createDownloadPath:(NSString *) downloadName;
-(NSString *) createDirWithDirName:(NSString*) dirName withBasePath:(NSString *) basePath;

-(void) downloadTheFile:(MusicLrcModel *) musicModel withType:(NSString *) type;
-(void) sendDownloadSuccessEvent:(MusicLrcModel *)musicModel withLocalPath:(NSString *)localPath withType:(NSString *) type;
@end

@implementation MusicDownLoadManager



-(id) init
{
    self = [super init];
    if (self) {
        [self setDefaultValuesWithCurrentObject];
    }
    return self;
}

-(void)loadMusic:(MusicLrcModel *)musicLrcModel {
    if (!musicLrcModel)
        return;
    [self downloadTheFile:musicLrcModel withType:kDownloadType_MP3];
}

-(void) setDefaultValuesWithCurrentObject
{
    if (!_queue)
    {
        _queue = [[ASINetworkQueue alloc] init];
        [_queue setDelegate:self];
        [_queue setRequestDidFinishSelector:@selector(queueDownloadSuccess:)];
        [_queue setRequestDidFailSelector:@selector(queueDownloadFail:)];
        [_queue setShouldCancelAllRequestsOnFailure:NO]; // 当有一个下载失败时，并不取消队列中的其他下载
        [_queue setMaxConcurrentOperationCount:1]; // 设置同一时间当前队列中的最大下载进程数
        [_queue go]; // 启动这个下载队列
    }
}

-(void) queueDownloadSuccess:(ASIHTTPRequest *) request
{

    // Get the download model


    // Download the success  callback operation
    NSDictionary *requestUserInfo = request.userInfo;
    NSString *type = [requestUserInfo objectForKey:@"type"];
    MusicLrcModel *model = [requestUserInfo objectForKey:@"model"];
    NSString *requestDownloadPath = request.downloadDestinationPath;
    [self sendDownloadSuccessEvent:model withLocalPath:requestDownloadPath withType:type];
    if ([type isEqualToString:kDownloadType_MP3])
    {
        NSLog(@"mp3 file download success!!!");
        [self downloadTheFile:model withType:kDownloadType_LRC];
    }else if ([type isEqualToString:kDownloadType_LRC])
    {
        NSLog(@"lrc file download success!!!");
    }

}
-(void) queueDownloadFail:(ASIHTTPRequest *) request
{
    NSLog(@"Music download fail !!!");
}

-(NSString *) nameForDownloadPath:(NSString *) downLoadPath
{
    if (downLoadPath && downLoadPath.length > 0)
    {
        NSArray *array = [downLoadPath componentsSeparatedByString:@"/"];
        if(array && array.count > 0)
        {
            return [array lastObject];
        }
    }
    return nil;
}

-(NSString *) createDownloadPath:(NSString *) downloadName
{
    // Get the documents directory
    NSString *documentsDirPath = [NSHomeDirectory()   stringByAppendingPathComponent:@"Documents"];

    // Find or create music folder
    NSString *musicDownLoadDir = [self createDirWithDirName:kMusicDirectory withBasePath:documentsDirPath];

    // Create a local storage address
    NSString *downloadPath = [NSString stringWithFormat:@"%@/%@",musicDownLoadDir,downloadName];

    // return result
    return downloadPath;
}

-(NSString *) createDirWithDirName:(NSString*) dirName withBasePath:(NSString *) basePath
{
    if (!dirName || dirName.length <= 0)
        return nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *newPath = [basePath stringByAppendingPathComponent:dirName];
    if (!newPath || newPath.length <= 0)
        return nil;
    NSError *error = [[[NSError alloc] init] autorelease];
    if ([manager createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:&error])
    {
        return newPath;
    }
    return nil;
}


-(void) downloadTheFile:(MusicLrcModel *) musicModel withType:(NSString *) type
{
    NSString *downloadPath;

    if ([type isEqualToString:kDownloadType_MP3])
    {
        downloadPath = musicModel.mp3FileServerPath;
    }else if ([type isEqualToString:kDownloadType_LRC]) {
        downloadPath = musicModel.lrcFileServerPath;
    }else
    {
        return;
    }

    // Download the file
    if (!downloadPath ||downloadPath.length <= 0)
        return;

    // Detects whether a file exist
    NSString *downloadFileName = [self nameForDownloadPath:downloadPath];
    if (!downloadFileName || downloadFileName.length <= 0)
        return;
    NSString *downloadLocalPath = [self createDownloadPath:downloadFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadLocalPath]) {
        NSLog(@"The file [%@] already exitsts, no need to repeat download!",downloadFileName);
        [self sendDownloadSuccessEvent:musicModel withLocalPath:downloadLocalPath withType:type];
        if ([type isEqualToString:kDownloadType_MP3]) {
            [self downloadTheFile:musicModel withType:kDownloadType_LRC];
        }else if ([type isEqualToString:kDownloadType_LRC]) {
            if ([musicModel respondsToSelector:@selector(musicDownloadSuccess:)])
            {
            }
        }
        return;
    }

    // send request to download the file
    NSURL *fileUrl = [NSURL URLWithString:downloadPath];
    if (fileUrl) {
        ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:fileUrl] autorelease];
        [request setDownloadDestinationPath:downloadLocalPath]; // 设置下载后的存储路径
        [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:musicModel,@"model", type,@"type",nil]];
        [_queue addOperation:request];
    }
}

-(void) sendDownloadSuccessEvent:(MusicLrcModel *)musicModel withLocalPath:(NSString *)localPath withType:(NSString *) type
{
    if(musicModel && type && type.length > 0 && localPath && localPath.length > 0)
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:localPath, kDownloadPathKey, type, kDownloadType,nil];
        if([musicModel respondsToSelector:@selector(musicDownloadSuccess:)])
            [musicModel performSelector:@selector(musicDownloadSuccess:) withObject:dictionary];
    }
}

#pragma mark shared
+(MusicDownLoadManager *)shared {
    if (!instance) {
        instance = [[MusicDownLoadManager alloc] init];
    }
    return instance;
}

-(void)dealloc {
    [_queue release];
    _queue = nil;
    [super dealloc];
}
@end