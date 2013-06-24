//
//  MyController.m
//  LrcTest
//
//  Created by 于 同非 on 06/07/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyController.h"


@interface MyController(private)
-(void) setupAVPlayerForURL: (NSURL*) url;
-(void) playAudio:(id) sender;
-(void) pauseAudio:(id) sender;
-(float) currentPlayTime;
-(int) currentPlayIndex:(NSString*) currentPlaySecond;
@end

@implementation MyController
@synthesize arrayItemList = _arrayItemList;
@synthesize slider = _slider;
@synthesize playButton = _playButton;
@synthesize pauseButton = _pauseButton;
@synthesize nextButton = _nextButton;
@synthesize previousButton = _previousButton;


-(id)init {
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

-(id)initWithArrayItem:(NSMutableArray *)arrayItemValue {
    self = [super init];
    if (self)
    {
        self.arrayItemList = arrayItemValue;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
//构建播放器页面
-(void)loadView {
    [super loadView];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //设置底部背景色
    UIImageView *buttonBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 310, self.view.bounds.size.width, 96)];
	buttonBackground.image = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerBarBackground" ofType:@"png"]] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	[self.view addSubview:buttonBackground];
	[buttonBackground release];
	buttonBackground  = nil;
    //播放按钮
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(144, 320, 40, 40)];
    [_playButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerPlay" ofType:@"png"]] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    _playButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:_playButton];//100, 420, 60, 25
    //CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    _pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(140, 320, 40, 40)];
	[_pauseButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerPause" ofType:@"png"]] forState:UIControlStateNormal];
	[_pauseButton addTarget:self action:@selector(pauseAudio:) forControlEvents:UIControlEventTouchUpInside];
	_pauseButton.showsTouchWhenHighlighted = YES;
    
    _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(220, 320, 40, 40)];
	[_nextButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerNextTrack" ofType:@"png"]]
				forState:UIControlStateNormal];
	//[_nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
	_nextButton.showsTouchWhenHighlighted = YES;
	[self.view addSubview:_nextButton];
	
	_previousButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 320, 40, 40)];
	[_previousButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerPrevTrack" ofType:@"png"]]
                    forState:UIControlStateNormal];
	//[_previousButton addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
	_previousButton.showsTouchWhenHighlighted = YES;
	[self.view addSubview:_previousButton];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(25, 370, 270, 9)];
	[_slider setThumbImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerVolumeKnob" ofType:@"png"]]
                       forState:UIControlStateNormal];
	[_slider setMinimumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberLeft" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
                              forState:UIControlStateNormal];
	[_slider setMaximumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberRight" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
							  forState:UIControlStateNormal];
    _slider.minimumValue = 0.0;
    [_slider addTarget:self action:@selector(volumeSliderMoved:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider];

    

    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 320)];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:_tableView];
    }
    

    NSString * path = [[NSBundle mainBundle] pathForResource:@"qbd" ofType:@"mp3"];
    NSURL *url = [[[NSURL alloc] initFileURLWithPath:path] autorelease];
    [self setupAVPlayerForURL:url];

}

- (void)volumeSliderMoved:(UISlider *)sender
{
    [_player seekToTime:CMTimeMakeWithSeconds([sender value], 1)];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) setupAVPlayerForURL: (NSURL *) url {
    AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:asset];
    _player = [[AVPlayer playerWithPlayerItem:anItem] retain];
    NSLog(@"%d",_player.status);
    _slider.maximumValue = CMTimeGetSeconds(_player.currentItem.duration);
    double duration = CMTimeGetSeconds(_player.currentItem.duration);
    CGFloat width = CGRectGetWidth([_slider bounds]);
    double tolerance = 0.5f * duration / width;
    id mTimeObserver = [[_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)
            queue:NULL /* If you pass NULL, the main queue is used. */
             usingBlock:^(CMTime time)
                           {
                               [self currentPlayTime];
                           }] retain];
    [_player addObserver:self forKeyPath:@"status" options:0 context:nil];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (object == _player && [keyPath isEqualToString:@"status"]) {
        if (_player.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
        } else if (_player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayer Ready to Play");
        } else if (_player.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
        }
    }
}

-(float) currentPlayTime
{
    if (_player)
    {
        float fCurrentTime = CMTimeGetSeconds(_player.currentItem.currentTime);
        float fDuration  = CMTimeGetSeconds(_player.currentItem.duration);
        int currentIndex = [self currentPlayIndex:[NSString stringWithFormat:@"%f",fCurrentTime]];
        if (fCurrentTime!= 0) {
            [_slider setValue:fCurrentTime animated:YES];
        }
        //音频播放完毕
        if(fCurrentTime >= fDuration){
            [_player setActionAtItemEnd:AVPlayerActionAtItemEndPause];
            currentIndex = 0;
            [_slider setValue:0.0f animated:YES];
        }
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(NSUInteger )currentIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        return fCurrentTime;
    }
    return -1.0f;
}

#pragma mark uitableViewDelegate回调
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayItemList count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellI = @"CellI";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellI];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellI] autorelease];
    }

    if (cell)
    {
        NSDictionary *dic = [self.arrayItemList objectAtIndex:indexPath.row];
        NSString *key = @"key is nil";
        NSString *value = @"value is nil";
        if (dic)
        {
            key = [dic.allKeys objectAtIndex:0];
            value = [dic objectForKey:key];
            cell.textLabel.text = value;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont fontWithName: @"Arial" size: 15.0];
        }
    }
    //设置选中背景为透明
    UIColor* color=[[UIColor alloc]initWithRed:0.0 green:0.0 blue:0.0 alpha:0];//通过RGB来定义颜色
    cell.selectedBackgroundView= [[[UIView alloc]initWithFrame:cell.frame]autorelease];
    cell.selectedBackgroundView.backgroundColor= color;
    //设置选中字体的颜色为紫色
    cell.textLabel.highlightedTextColor = [UIColor purpleColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}


//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self playAudio:nil];
//}

-(void) playAudio:(id) sender
{
    [_player play];
    [_playButton removeFromSuperview];
    [self.view addSubview:_pauseButton];
}
-(void) pauseAudio:(id) sender
{
    [_player pause];
    [_pauseButton removeFromSuperview];
    [self.view addSubview:_playButton];
}

-(int) currentPlayIndex:(NSString*) currentPlaySecond
{
    if (!currentPlaySecond || currentPlaySecond.length <= 0)
        return 0;
    int index;
    for (index = 0; index < self.arrayItemList.count; index++)
    {
        NSDictionary *dic = [self.arrayItemList objectAtIndex:index];
        if (dic)
        {
            NSString * strSecondValue = [dic.allKeys objectAtIndex:0];
            float fValue = strSecondValue.floatValue;
            if (fValue > currentPlaySecond.floatValue)
                break;
        }
    }
    return index - 1;
}

-(void)dealloc {
    [_player release];
    [_tableView release];
    [_arrayItemList release];
    [super dealloc];
}
@end
