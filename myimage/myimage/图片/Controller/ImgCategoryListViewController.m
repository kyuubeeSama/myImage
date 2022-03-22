//
//  ImgCategoryListViewController.m
//  myimage
//
//  Created by Galaxy on 2021/2/21.
//  Copyright © 2021 liuqingyuan. All rights reserved.
//

#import "ImgCategoryListViewController.h"
#import "ImgListCollectionView.h"
#import "ArticleModel.h"
#import "ImgDetailViewController.h"
#import "ImgListCollectionViewCell.h"

@interface ImgCategoryListViewController ()

@property(nonatomic, strong) ImgListCollectionView *mainCollection;
@property(nonatomic, strong) NSMutableArray *listArr;
// 是否从web获取
@property(nonatomic, assign) BOOL is_web;

@end

@implementation ImgCategoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.is_web = self.isJump;
    self.listArr = [[NSMutableArray alloc] init];
    if (self.pageNum == 0) {
        self.pageNum = 1;
    }
    [self makeUI];
    [self getData];
}

- (UIView *)listView {
    return self.view;
}


// 获取数据
- (void)getData {
    if (self.is_web) {
        [self getListDataWithType:2];
    } else {
        //    从本地数据库获取已经缓存的数据
        SqliteTool *sqliteTool = [SqliteTool sharedInstance];
        // 直接查询所有
        NSArray *array = [sqliteTool selectDataFromTable:@"article"
                                                   where:[NSString stringWithFormat:@"website_id = %d and category_id = %d", self.webModel.value, self.categoryModel.category_id]
                                                   field:@"*"
                                                 orderby:@"aid desc"
                                                   Class:[ArticleModel class]];
        if ([array count]) {
            self.listArr = [[NSMutableArray alloc] initWithArray:array];
            self.mainCollection.listArr = self.listArr;
        } else {
            // 本地没有数据，从网络获取。
            [self getListDataWithType:2];
            self.is_web = YES;
        }
    }
}

- (void)getListDataWithType:(NSInteger)type {
    // 从网络获取数据
    [self beginProgressWithTitle:@"爬取中"];
    DataManager *dataManager = [[DataManager alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [dataManager getDataWithType:self.webModel
                             pageNum:self.pageNum
                            category:self.categoryModel
                             success:^(NSMutableArray *_Nonnull array) {
                                 [self.listArr addObjectsFromArray:array];
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self endProgress];
                                     if (array.count > 0) {
                                         self.pageNum += 1;
                                         if (type == 1) {
                                             [self.mainCollection.mj_header endRefreshing];
                                         } else {
                                             [self.mainCollection.mj_footer endRefreshing];
                                         }
                                     } else {
                                         [self.mainCollection.mj_footer endRefreshingWithNoMoreData];
                                     }
                                     self.mainCollection.listArr = self.listArr;
                                 });
                             } failure:^(NSError *_Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self endProgress];
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"数据获取失败" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                        [alert addAction:cancelAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                }];
    });
}

- (void)makeUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.mainCollection = [[ImgListCollectionView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH) collectionViewLayout:layout];
    [self.view addSubview:self.mainCollection];
    [self.mainCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    self.mainCollection.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        if (self.is_web) {
            [self getListDataWithType:2];
        }
    }];
    self.mainCollection.model = self.webModel;
    self.mainCollection.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        self.is_web = YES;
        self.pageNum = 1;
        [self.listArr removeAllObjects];
        [self getListDataWithType:1];
    }];


    WeakSelf(self)
    self.mainCollection.cellDidSelect = ^(NSIndexPath *_Nonnull indexPath) {
        ArticleModel *aModel = weakself.listArr[indexPath.row];
        ImgDetailViewController *VC = [[ImgDetailViewController alloc] init];
        VC.articleModel = aModel;
        VC.websiteModel = weakself.webModel;
        VC.imageSaved = ^(ArticleModel *_Nonnull model) {
            weakself.listArr[indexPath.row] = model;
            dispatch_async(dispatch_get_main_queue(), ^{
                ImgListCollectionViewCell *cell = (ImgListCollectionViewCell *) [weakself.mainCollection cellForItemAtIndexPath:indexPath];
                if (model.has_done == 1) {
                    cell.signView.hidden = YES;
                } else {
                    cell.signView.hidden = NO;
                }
            });
        };
        [weakself.navigationController pushViewController:VC animated:YES];
    };
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
