//
//  SearchResultViewController.m
//  myimage
//
//  Created by Galaxy on 2020/9/8.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "SearchResultViewController.h"
#import "ImgListCollectionView.h"
#import "ArticleModel.h"
#import "ImgDetailViewController.h"
@interface SearchResultViewController ()

@property(nonatomic, strong) ImgListCollectionView *mainCollection;
@property(nonatomic, strong) NSMutableArray *listArr;
@property(nonatomic, assign) NSInteger pageNum;
// 添加详情地址数组，通过判断详情地址，判断写真集已存储
@property(nonatomic,strong)NSMutableArray *detailArr;

@end

@implementation SearchResultViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNav];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listArr = [[NSMutableArray alloc]init];
    self.detailArr = [[NSMutableArray alloc]init];
    self.pageNum = 1;
    [self.mainCollection reloadData];
    [self getData];
    [self getMoreData];
}

- (void)setNav {
    self.navigationItem.title = self.keyword;
}

- (void)getData {
    // 从数据中获取列表页
    [self beginProgressWithTitle:@"爬取中"];
    DataManager *dataManager = [[DataManager alloc]init];
    // 获取搜索结果
    // 搜索
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [dataManager getSearchResultWithType:self.model
                                     pageNum:self.pageNum
                                     keyword:self.keyword
                                     success:^(NSMutableArray *_Nonnull array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self endProgress];
                if (array.count > 0) {
                    self.pageNum += 1;
                    [self.mainCollection.mj_footer endRefreshing];
                } else {
                    [self.mainCollection.mj_footer endRefreshingWithNoMoreData];
                }
                for (ArticleModel *model in array) {
                    if (![self.detailArr containsObject:model.detail_url]) {
                        [self.detailArr addObject:model.detail_url];
                        [self.listArr addObject:model];
                    }
                }
                self.mainCollection.listArr = self.listArr;
            });
        } failure:^(NSError *_Nonnull error) {
            
        }];
    });
}

-(void)getMoreData {
    self.mainCollection.mj_footer=[MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getData];
    }];
}

-(ImgListCollectionView *)mainCollection{
    if (!_mainCollection) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _mainCollection = [[ImgListCollectionView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH) collectionViewLayout:layout];
        [self.view addSubview:_mainCollection];
        [_mainCollection mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(45+(TOP_HEIGHT));
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        }];
        _mainCollection.model = self.model;
        WeakSelf(self)
        _mainCollection.cellDidSelect = ^(NSIndexPath * _Nonnull indexPath) {
                ArticleModel *aModel = weakself.listArr[indexPath.row];
                ImgDetailViewController *VC = [[ImgDetailViewController alloc] init];
                VC.articleModel = aModel;
                VC.websiteModel = weakself.model;
                VC.imageSaved = ^(ArticleModel *_Nonnull model) {
                    weakself.listArr[indexPath.row] = model;
                };
                [weakself.navigationController pushViewController:VC animated:YES];
        };
        [_mainCollection mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.view);
        }];
    }
    return _mainCollection;
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
