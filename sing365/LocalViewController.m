//
//  LocalViewController.m
//  sing365
//
//  Created by 张 磊 on 13-4-8.
//  Copyright (c) 2013年 Stone_Zl. All rights reserved.
//

#import "LocalViewController.h"
#import "MusicViewController.h"
#import "DataUtils.h"

@interface LocalViewController ()

@end


@implementation LocalViewController
@synthesize menuArray;
@synthesize menuDict;
@synthesize checkValue;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.title = @"本地歌曲";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.menuDict = [DataUtils getFileInfo:@"dataInfo"];
    //直接获取key,然后排序
    self.menuArray = [[menuDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [menuArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    NSString *menuName = [menuArray objectAtIndex:section];
    return [[menuDict objectForKey:menuName]  count];
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
    
    cell.textLabel.text = [DataUtils getShowText:self.menuDict ArrayOf:self.menuArray At:indexPath];
    //设置每行可跳转样式
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //把数据源填充进去
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    checkValue = [DataUtils getShowText:self.menuDict ArrayOf:self.menuArray At:indexPath];
    MusicViewController *musicViewController = [[MusicViewController alloc] init];
    musicViewController.delegate = self;
    [self.navigationController pushViewController:musicViewController animated:YES];
}

-(NSString *)passValue
{
   return checkValue;
}




@end
