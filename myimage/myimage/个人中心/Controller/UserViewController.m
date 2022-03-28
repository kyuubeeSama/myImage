//
//  UserViewController.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/27.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "UserViewController.h"
#import "CollectViewController.h"
#import "WebsiteViewController.h"
#import "UIViewController+CWLateralSlide.h"
#import "LocalImgViewController.h"
#import "HistoryListViewController.h"

@interface UserViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *mainTable;
@property(nonatomic, strong) NSMutableArray *listArr;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *cache = [NSString stringWithFormat:@"缓存(%@)", [Tool getMemonry]];
    self.listArr = [[NSMutableArray alloc] initWithArray:@[@"相册收藏",@"图片收藏", @"站点管理",@"本地图片",@"历史记录",cache]];
    [self makeUI];
}

- (void)makeUI {
    self.mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, TOP_HEIGHT, screenW, screenH - (TOP_HEIGHT)) style:UITableViewStylePlain];
    self.mainTable.dataSource = self;
    self.mainTable.delegate = self;
    [self.view addSubview:self.mainTable];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.listArr[(NSUInteger) indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 点击按钮
    switch (indexPath.row) {
        case 0:{
            CollectViewController *VC = [[CollectViewController alloc]init];
            VC.type = 1;
            [self cw_pushViewController:VC];
        }
            break;
        case 1: {
            CollectViewController *VC = [[CollectViewController alloc]init];
            VC.type = 2;
            [self cw_pushViewController:VC];
        }
            break;
        case 2:{
            WebsiteViewController *VC = [[WebsiteViewController alloc] init];
            [self cw_pushViewController:VC];
        }
            break;
        case 3:{
            // 打开本地自建相册
            LocalImgViewController *VC = [[LocalImgViewController alloc]init];
            [self cw_pushViewController:VC];
        }
            break;
        case 4:{
            HistoryListViewController *VC = [[HistoryListViewController alloc]init];
            [self cw_pushViewController:VC];
        }
            break;
        default:{
            // 清理缓存
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
            NSString *cache = [NSString stringWithFormat:@"缓存(%@)", [Tool getMemonry]];
            self.listArr[4] = cache;
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.cleanImgCacheBlock) {
                    self.cleanImgCacheBlock();
                }
            }];
        }
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 100;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]init];
    return headerView;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
