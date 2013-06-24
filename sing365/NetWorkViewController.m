//
//  NetWorkViewController.m
//  sing365
//
//  Created by 张 磊 on 13-4-9.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import "NetWorkViewController.h"
#import "Reachability.h"
#import "MBButtonMenuViewController.h"
#import "MusicPlayController.h"


#define CONNECT_URL [NSURL URLWithString:@"http://192.168.1.13:8080/sing365/MusicServlet"]

@interface NetWorkViewController ()<MBButtonMenuViewControllerDelegate>
-(void)parseJsonObjectToArray:(id)jsonObject;
-(void)searchObject:(NSString *)searchText;
@property(nonatomic,retain) MBButtonMenuViewController *menu;
@end

@implementation NetWorkViewController
@synthesize music = _music;
@synthesize musicTableArray = _musicTableArray;
@synthesize filterTableArray = _filterTableArray;
@synthesize isSearch = _isSearch;
@synthesize searchBar = _searchBar;
@synthesize mySearchDisplayController = _mySearchDisplayController;


-(void)searchObject:(NSString *)searchText
{
    _isSearch = YES;
    _filterTableArray = [[NSMutableArray alloc] init];
    for (int i = 0; i< _musicTableArray.count ; i++) {
        Music *music = [_musicTableArray objectAtIndex:i];
        NSString *musicName = music.musicName;
        NSRange titleResultsRange = [musicName rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if(titleResultsRange.location != NSNotFound)
        {
            [_filterTableArray addObject:[_musicTableArray objectAtIndex:i]];
        }
    }
    [self.tableView reloadData];
}

-(void)parseJsonObjectToArray:(id)jsonObject
{
    NSArray *deserializedArray = (NSArray *)jsonObject;
    _musicTableArray = [[NSMutableArray alloc] init];
    Music *music;
    for (int i=0; i<deserializedArray.count; i++) {
        music = [[Music alloc] init];
        music.musicId = (int)[deserializedArray[i] objectForKey:@"musicId"];
        music.musicName = [deserializedArray[i] objectForKey:@"musicName"];
        music.musicSinger = [deserializedArray[i] objectForKey:@"musicSinger"];
        music.downPath = [deserializedArray[i] objectForKey:@"downPath"];
        music.lrcPath = [deserializedArray[i] objectForKey:@"lrcPath"];
        [_musicTableArray addObject:music];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"在线音乐";
        Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
        switch ([r currentReachabilityStatus]) {
            case NotReachable:
                // 没有网络连接
                NSLog(@"没有网络连接");
                break;
            case ReachableViaWWAN:
                // 使用3G网络
                NSLog(@"使用3G网络");
                break;
            case ReachableViaWiFi:
                // 使用WiFi网络
                NSLog(@"使用WiFi网络");
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:CONNECT_URL];
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if ([data length] >0 && error == nil){
                      //将获取到的json数据转换成json对象
                      id jsonObject =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                       if (jsonObject != nil && error == nil)
                       {
                           if ([jsonObject isKindOfClass:[NSArray class]]) {
                               //将json对象中的数据封装
                               [self parseJsonObjectToArray:jsonObject];
                           }
                       }
                    }
                    else if ([data length] == 0 && error == nil){
                        NSLog(@"Nothing was downloaded.");
                    }
                    else if (error != nil){
                        NSLog(@"Error happened = %@", error);
                    }
                }];
                 break;
        }
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 40)];
        self.tableView.tableHeaderView = _searchBar;
        _searchBar.delegate = self;
        _searchBar.keyboardType=UIKeyboardTypeDefault;
        
        _mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
        _mySearchDisplayController.searchResultsDelegate = self;
        _mySearchDisplayController.searchResultsDataSource = self;
        _mySearchDisplayController.delegate = self;
        
        _isSearch = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_isSearch)
    {
        return [_filterTableArray count];
        
    }else{
        
        return [_musicTableArray count];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"TestTableViewItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //返回可重用的cell
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
        //如果没有可重用的，就新建一个
    }
    if (_isSearch) {
        cell.textLabel.text = [[_filterTableArray objectAtIndex:indexPath.row] musicName];
    }else{
        cell.textLabel.text = [[_musicTableArray objectAtIndex:indexPath.row] musicName];
    }
    //设置每行可跳转样式
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    //把数据源填充进去
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _music = [_musicTableArray objectAtIndex:indexPath.row];
    NSLog(@"the music name is %@, the singer name  is %@, the downloadPath is %@, the lrcPath is %@",_music.musicName,_music.musicSinger,_music.downPath,_music.lrcPath);
    MusicPlayController *musicPlayController = [[MusicPlayController alloc] init];
    musicPlayController.delegate = self;
    musicPlayController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:musicPlayController animated:YES];
}

-(Music *)passMusic
{
    return _music;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    _music = [_musicTableArray objectAtIndex:indexPath.row];
    [self showMenu];
}

#pragma mark - Menu
//override
- (void) showMenu
{
    if (![self menu]) {
        
        NSArray *titles = @[@"DownLoad",
                            @"Share",
                            @"Cancel"];
        _menu = [[MBButtonMenuViewController alloc] initWithButtonTitles:titles];
        [_menu setDelegate:self];
        [_menu setCancelButtonIndex:[[_menu buttonTitles]count]-1];
    }
    [[self menu] showInView:[self view]];
}

#pragma mark - MBButtonMenuViewControllerDelegate

- (void)buttonMenuViewController:(MBButtonMenuViewController *)buttonMenu buttonTappedAtIndex:(NSUInteger)index
{
    //  Hide the menu
    [buttonMenu hide];
    //  Create a title
    NSString *title = [[self menu] buttonTitles][index];
    if ([title isEqualToString:@"Cancle"]) {
        [buttonMenu hide];
    } else if([title isEqualToString:@"DownLoad"]){
//        NSLog(@"the music_id is %d, the music_name is %@, the music_singer is %@, the download path is %@, the lrcPath is %@",_music.musicId,_music.musicName,_music.musicSinger,_music.downPath,_music.lrcPath);
    } else if([title isEqualToString:@"Share"]){
//         NSLog(@"the music_id is %d, the music_name is %@, the music_singer is %@, the download path is %@, the lrcPath is %@",_music.musicId,_music.musicName,_music.musicSinger,_music.downPath,_music.lrcPath);
    }
}

- (void)buttonMenuViewControllerDidCancel:(MBButtonMenuViewController *)buttonMenu
{
    [buttonMenu hide];
}

#pragma mark - Search Bar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchText = searchBar.text;
   [self searchObject:searchText];
   [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchObject:searchText];
}

-(void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    _isSearch = YES;
}

-(void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    _isSearch = NO;
    [self.tableView reloadData];
}

@end
