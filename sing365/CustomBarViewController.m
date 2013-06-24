//
//  CustomBarControllerViewController.m
//  sing365
//
//  Created by 张 磊 on 13-4-8.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import "CustomBarViewController.h"
#import "LocalViewController.h"
#import "NetWorkViewController.h"
#import "SettingViewController.h"

@interface CustomBarViewController ()

@end

@implementation CustomBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //设置系统自带TabBar
    UITabBarItem *localBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:1];
    LocalViewController *localViewController = [[LocalViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //设置导航栏
    UINavigationController *localNav = [[UINavigationController alloc] initWithRootViewController:localViewController];
    localViewController.tabBarItem = localBarItem;
    
    //设置网络页面
    UITabBarItem *netWorkBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:2];
    NetWorkViewController *netWorkViewController = [[NetWorkViewController alloc] init];
    //设置导航栏
    UINavigationController *netWorkNav = [[UINavigationController alloc] initWithRootViewController:netWorkViewController];
    netWorkViewController.tabBarItem = netWorkBarItem;
    
    
    
    //设置设置页面
    UITabBarItem *settingBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:3];
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    //设置导航栏
    UINavigationController *settingNav = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    settingViewController.tabBarItem = settingBarItem;
    
    NSArray *uiViewControllers = @[localNav,netWorkNav,settingNav];
    
    [self setViewControllers:uiViewControllers animated:YES];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
