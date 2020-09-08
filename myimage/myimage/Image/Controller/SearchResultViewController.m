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

@property(nonatomic, retain) ImgListCollectionView *mainCollection;
@property(nonatomic, retain) NSMutableArray *listArr;

@end

@implementation SearchResultViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNav];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getData];
}

- (void)setNav {
    self.navigationItem.title = self.keyword;
}

- (void)getData {
    // 从数据中获取列表页
    [self beginProgressWithTitle:@"爬取中"];
    DataManager *dataManager = [[DataManager alloc]init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获取搜索结果
    });
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
    }
    return _mainCollection;
}

- (void)getMoreData {
    self.mainCollection.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [self getData];
    }];
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
