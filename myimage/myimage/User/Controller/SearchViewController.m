//
//  SearchViewController.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/27.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//  搜索结果页

#import "SearchViewController.h"
#import "ImgListViewController.h"
@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property(nonatomic, retain) UITableView *mainTable;
@property(nonatomic, retain) NSMutableArray *historyArr;

@end

@implementation SearchViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.historyArr = [[NSMutableArray alloc] init];
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"history"];
    [self.historyArr addObjectsFromArray:array];
    self.historyArr = (NSMutableArray *) [[self.historyArr reverseObjectEnumerator] allObjects];
    [self.mainTable reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createHead];
    [self createBodyView];
}

- (void)createHead {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, 10, screenW - 40, 24)];
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
}

- (void)createBodyView {
    self.mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, TOP_HEIGHT, screenW, screenH - (TOP_HEIGHT)) style:UITableViewStylePlain];
    [self.view addSubview:self.mainTable];
    self.mainTable.delegate = self;
    self.mainTable.dataSource = self;

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    searchBar.text;
//    NSLog(@"%@",searchBar.text);
    [self.historyArr addObject:searchBar.text];
    NSMutableArray *listAry = [[NSMutableArray alloc] init];
    for (NSString *str in self.historyArr) {
        if (![listAry containsObject:str]) {
            [listAry addObject:str];
        }
    }
//    NSLog(@"%@",listAry);
    [[NSUserDefaults standardUserDefaults] setObject:listAry forKey:@"history"];
    ImgListViewController *VC = [[ImgListViewController alloc] init];
//    VC.type = 3;
    [self.navigationController pushViewController:VC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historyArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.historyArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *keyword = self.historyArr[indexPath.row];
    ImgListViewController *VC = [[ImgListViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
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
