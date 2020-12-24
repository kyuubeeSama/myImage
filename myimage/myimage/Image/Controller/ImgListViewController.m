//
//  ImgListViewController.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//  TODO:替换控件为AsyncDisplayKit控件。数据数组，减少重复访问

#import "ImgListViewController.h"
#import "CategoryChooseView.h"
#import "ArticleModel.h"
#import "CategoryModel.h"
#import "ImgDetailViewController.h"
#import "ImgListCollectionView.h"
#import "SearchResultViewController.h"
@interface ImgListViewController ()<UISearchBarDelegate>

@property(nonatomic, strong) ImgListCollectionView *mainCollection;
@property(nonatomic, strong) NSMutableArray<NSArray *> *listArr;
@property(nonatomic,strong) NSMutableArray *pageArr;
@property(nonatomic, strong) CategoryModel *categoryModel;
// 当前分类
@property(nonatomic,assign)NSInteger categoryIndex;

@end

@implementation ImgListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageArr = [[NSMutableArray alloc]init];
    self.categoryIndex = 0;
    self.listArr = [[NSMutableArray alloc] init];
    [self setNav];
    [self makeUI];
    [self getMoreData];
}

- (void)setNav {
    self.navigationItem.title = self.model.name;
}

-(void)getData{
    SqliteTool *sqliteTool = [SqliteTool sharedInstance];
    NSArray *array = [sqliteTool selectDataFromTable:@"article"
                                               where:[NSString stringWithFormat:@"website_id= %d and category_id = %d",self.model.website_id,self.categoryModel.category_id]
                                               field:@"*" Class:[ArticleModel class]
                                               limit:self.listArr[self.categoryIndex].count pageSize:[self.pageArr[self.categoryIndex] integerValue]];
    self.listArr[self.categoryIndex] = array;
    // 该分类在当前数据库中无数据
    if ([self.listArr[self.categoryIndex] count]) {
        [self getListData];
    }
}

- (void)getListData {
//    TODO:进入页面首先从数据库读取一组50个的数据，如果数据库为空，再从服务器获取新数据。下拉刷新会重新从服务器获取新数据。
    // 从网络获取数据
    [self beginProgressWithTitle:@"爬取中"];
    DataManager *dataManager = [[DataManager alloc]init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [dataManager getDataWithType:self.model
                             pageNum:[self.pageArr[self.categoryIndex] intValue]
                            category:self.categoryModel
                             success:^(NSMutableArray *_Nonnull array) {
            NSMutableArray *dataArr = [[NSMutableArray alloc]initWithArray:self.listArr[self.categoryIndex]];
            [dataArr addObjectsFromArray:array];
            self.listArr[self.categoryIndex] = dataArr;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self endProgress];
                if (array.count > 0) {
                    self.pageArr[self.categoryIndex] = [NSString stringWithFormat:@"%d",[self.pageArr[self.categoryIndex] intValue]+1];
                    [self.mainCollection.mj_footer endRefreshing];
                } else {
                    [self.mainCollection.mj_footer endRefreshingWithNoMoreData];
                }
                self.mainCollection.listArr = dataArr;
            });
        } failure:^(NSError *_Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
    });
}

- (void)makeUI {
    // 搜索UI
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, TOP_HEIGHT+10, screenW, 40)];
    [self.view addSubview:searchBar];
    searchBar.backgroundImage = [UIImage new];
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    // 类别UI
    NSMutableArray *titleArr = [[NSMutableArray alloc] init];
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    NSArray *categoryArr = [sqlTool selectDataFromTable:@"category"
                                                  where:[NSString stringWithFormat:@"website_id = %d and is_delete = 1", self.model.value]
                                                  field:@"*"
                                                  Class:[CategoryModel class]];
    for (NSUInteger i = 0; i < categoryArr.count; i++) {
        [self.pageArr addObject:@"1"];
        [self.listArr addObject:@[]];
        CategoryModel *model = categoryArr[(NSUInteger) i];
        if (i == 0) {
            self.categoryModel = model;
        }
        [titleArr addObject:model.name];
    }
    CategoryChooseView *chooseView = [[CategoryChooseView alloc] initWithFrame:CGRectMake(0, TOP_HEIGHT+60, screenW, 45)
                                                                   CategoryArr:titleArr
                                                                     BackColor:[UIColor systemBackgroundColor]
                                                               hightLightColor:[UIColor systemBackgroundColor]
                                                                    TitleColor:[UIColor dm_colorWithLightColor:[UIColor blackColor] darkColor:[UIColor whiteColor]]
                                                               hightTitleColor:[UIColor redColor]
                                                               bottomLineColor:[UIColor redColor]
                                                                 CategoryStyle:equalWidth];
    chooseView.chooseBlock = ^(NSInteger index) {
        //        点击切换图片显示
        CategoryModel *model = categoryArr[(NSUInteger) index];
        self.categoryModel = model;
        self.categoryIndex = index;
        NSArray *dataArr = self.listArr[self.categoryIndex];
        if (dataArr.count>0) {
            self.mainCollection.listArr = dataArr;
        }else{
            [self getListData];
        }
    };
    [self.view addSubview:chooseView];
    [self.mainCollection reloadData];
    [self getListData];
}

-(ImgListCollectionView *)mainCollection{
    if (!_mainCollection) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _mainCollection = [[ImgListCollectionView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH) collectionViewLayout:layout];
        [self.view addSubview:_mainCollection];
        [_mainCollection mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(105+(TOP_HEIGHT));
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        }];
        _mainCollection.model = self.model;
        WeakSelf(self)
        _mainCollection.cellDidSelect = ^(NSIndexPath * _Nonnull indexPath) {
            NSMutableArray *dataArr = [[NSMutableArray alloc]initWithArray:weakself.listArr[weakself.categoryIndex]];
            ArticleModel *aModel = dataArr[(NSUInteger) indexPath.row];
            ImgDetailViewController *VC = [[ImgDetailViewController alloc] init];
            VC.articleModel = aModel;
            VC.websiteModel = weakself.model;
            VC.imageSaved = ^(ArticleModel *_Nonnull model) {
                dataArr[indexPath.row] = model;
                weakself.listArr[weakself.categoryIndex] = dataArr;
            };
            [weakself.navigationController pushViewController:VC animated:YES];
        };
    }
    return _mainCollection;
}

- (void)getMoreData {
    self.mainCollection.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [self getListData];
    }];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    // 开始搜索
    NSLog(@"搜索");
    [searchBar endEditing:YES];
    // 跳转到搜索结果页面
    SearchResultViewController *VC = [[SearchResultViewController alloc]init];
    VC.model = self.model;
    VC.keyword = searchBar.text;
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar endEditing:YES];
    [searchBar setShowsCancelButton:NO animated:YES];
    NSLog(@"取消");
    searchBar.text = @"";
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
