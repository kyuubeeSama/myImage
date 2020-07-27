//
//  ImgListViewController.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//  TODO:替换控件为AsyncDisplayKit控件。数据数组，减少重复访问

#import "ImgListViewController.h"
#import "ImgListCollectionViewCell.h"
#import "CategoryChooseView.h"
#import "ArticleModel.h"
#import "CategoryModel.h"
#import "ImgDetailViewController.h"

@interface ImgListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, retain) UICollectionView *mainCollection;
@property(nonatomic, retain) NSMutableArray *listArr;
@property(nonatomic, assign) int pageNum;
//@property(nonatomic, copy) NSString *categoryType;
@property(nonatomic, strong) CategoryModel *categoryModel;

@end

@implementation ImgListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageNum = 1;
    self.listArr = [[NSMutableArray alloc] init];
    [self setNav];
    [self makeUI];
    [self getMoreData];
}

- (void)setNav {
    self.navigationItem.title = self.model.name;
}

- (void)getData {
    // 从数据中获取列表页
    [self beginProgressWithTitle:nil];
    [DataManager getDataWithType:self.model
                         pageNum:self.pageNum
                        category:self.categoryModel
                         success:^(NSMutableArray *_Nonnull array) {
                             if (array.count > 0) {
                                 self.pageNum = self.pageNum + 1;
                             } else {
                                 [self.mainCollection.mj_footer endRefreshingWithNoMoreData];
                             }
                             [self.listArr addObjectsFromArray:array];
                             [self.mainCollection reloadData];
                             [self endProgress];

                         } failure:^(NSError *_Nonnull error) {
            NSLog(@"%@", error);
        }];
}

- (void)makeUI {
    NSMutableArray *titleArr = [[NSMutableArray alloc] init];
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    NSArray *categoryArr = [sqlTool selectDataFromTable:@"category"
                                                  where:[NSString stringWithFormat:@"website_id = %d and is_delete = 1", self.model.value]
                                                  field:@"*"
                                                  Class:[CategoryModel class]];
    for (NSUInteger i = 0; i < categoryArr.count; i++) {
        CategoryModel *model = categoryArr[(NSUInteger) i];
        if (i == 0) {
//            self.categoryType = model.value;
            self.categoryModel = model;
        }
        [titleArr addObject:model.name];
    }
    CategoryChooseView *chooseView = [[CategoryChooseView alloc] initWithFrame:CGRectMake(0, TOP_HEIGHT, screenW, 45)
                                                                   CategoryArr:titleArr
                                                                     BackColor:[UIColor whiteColor]
                                                               hightLightColor:[UIColor whiteColor]
                                                                    TitleColor:[UIColor blackColor]
                                                               hightTitleColor:[UIColor redColor]
                                                               bottomLineColor:[UIColor redColor]
                                                                 CategoryStyle:equalWidth];
    chooseView.chooseBlock = ^(NSInteger index) {
//        点击切换图片显示
        CategoryModel *model = categoryArr[(NSUInteger) index];
        self.categoryModel = model;
//        self.categoryType = model.value;
        [self.listArr removeAllObjects];
        self.pageNum = 1;
        [self getData];
    };
    [self.view addSubview:chooseView];
    [self getData];
}

-(UICollectionView *)mainCollection{
    if (!_mainCollection) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _mainCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH) collectionViewLayout:layout];
        _mainCollection.backgroundColor = [UIColor whiteColor];
        _mainCollection.delegate = self;
        _mainCollection.dataSource = self;
        [self.view addSubview:_mainCollection];
        [_mainCollection registerClass:[ImgListCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        [_mainCollection mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(45);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        }];
    }
    return _mainCollection;
}

- (void)getMoreData {
    self.mainCollection.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [self getData];
        [self.mainCollection.mj_footer endRefreshing];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ArticleModel *model = self.listArr[(NSUInteger) indexPath.row];
    ImgListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSLog(@"%@,%@,%@", model.name, model.img_url, model.detail_url);
    cell.titleLab.text = model.name;
    [cell.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.model.url, model.img_url]] placeholderImage:[UIImage imageNamed:@"placeholder1"]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(screenW / 2 - 5, screenW / 2 + 45);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ArticleModel *model = self.listArr[(NSUInteger) indexPath.row];
    ImgDetailViewController *VC = [[ImgDetailViewController alloc] init];
    VC.articleModel = model;
    VC.websiteModel = self.model;
    VC.imageSaved = ^(ArticleModel *_Nonnull model) {
        self.listArr[(NSUInteger) indexPath.row] = model;
    };
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
