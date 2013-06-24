//
//  NetWorkViewController.h
//  sing365
//
//  Created by 张 磊 on 13-4-9.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Music.h"
#import "UIViewMusicTypeDelegate.h"


@interface NetWorkViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate,UIViewMusicTypeDelegate>
@property(nonatomic,retain) Music *music;
@property(nonatomic,retain) NSMutableArray *musicTableArray;
@property(nonatomic,retain) NSMutableArray *filterTableArray;
@property(nonatomic) BOOL isSearch;
@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic,retain) UISearchDisplayController *mySearchDisplayController;
-(void)parseJsonObjectToArray:(id)jsonObject;
-(void)searchObject:(NSString *)searchText;
@end
