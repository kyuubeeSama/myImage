//
//  NewImgListViewController.m
//  myimage
//
//  Created by liuqingyuan on 2020/6/9.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "NewImgListViewController.h"
#import "CategoryChooseView.h"
#import "ArticleModel.h"
#import "CategoryModel.h"
#import "ImgDetailViewController.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ImgListCollectionNode.h"

@interface NewImgListViewController ()<ASCollectionDelegate,ASCollectionDataSource,ASCollectionDelegateFlowLayout>

//@property(nonatomic, retain) UICollectionView *mainCollection;
@property(nonatomic,retain)ASCollectionNode *mainCollection;
@property(nonatomic, retain) NSMutableArray *listArr;
@property(nonatomic, assign) int pageNum;
@property(nonatomic, copy) NSString *categoryType;

@end

@implementation NewImgListViewController

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
                        category:self.categoryType
                         success:^(NSMutableArray *_Nonnull array) {
        if (array.count > 0) {
            self.pageNum = self.pageNum + 1;
        } else {
            [self.mainCollection.view.mj_footer endRefreshingWithNoMoreData];
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
            self.categoryType = model.value;
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
        CategoryModel *model = categoryArr[(NSUInteger) index];
        self.categoryType = model.value;
        [self.listArr removeAllObjects];
        self.pageNum = 1;
        [self getData];
    };
    [self.view addSubview:chooseView];
    UICollectionViewLayout *layout = [[UICollectionViewLayout alloc]init];
    self.mainCollection = [[ASCollectionNode alloc]initWithFrame:CGRectMake(0, 0, screenW, screenH) collectionViewLayout:layout];
    self.mainCollection.backgroundColor = [UIColor dm_colorWithLightColor:[UIColor whiteColor] darkColor:[UIColor blackColor]];
    self.mainCollection.delegate = self;
    self.mainCollection.dataSource = self;
    [self.view addSubnode:self.mainCollection];
    [self.mainCollection.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(chooseView.mas_bottom);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];
    [self getData];
}

- (void)getMoreData {
    self.mainCollection.view.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [self getData];
        [self.mainCollection.view.mj_footer endRefreshing];
    }];
}

-(NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section{
    return self.listArr.count;
}

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"contentsize = %f",collectionNode.view.contentSize.height);
    ArticleModel *model = self.listArr[(NSUInteger) indexPath.row];
    return ^{
        ImgListCollectionNode *node = [[ImgListCollectionNode alloc] init];
        node.backgroundColor = [UIColor yellowColor];
        node.titleNode.attributedText = [[NSAttributedString alloc]initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
        node.topImgNode.URL = [NSURL URLWithString:model.img_url];
        return node;
    };
}

-(void)collectionNode:(ASCollectionNode *)collectionNode didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ArticleModel *model = self.listArr[(NSUInteger) indexPath.row];
    ImgDetailViewController *VC = [[ImgDetailViewController alloc] init];
    VC.articleModel = model;
    VC.websiteModel = self.model;
    VC.imageSaved = ^(ArticleModel *_Nonnull model) {
        self.listArr[(NSUInteger) indexPath.row] = model;
    };
    [self.navigationController pushViewController:VC animated:YES];
}

-(ASSizeRange)collectionNode:(ASCollectionNode *)collectionNode constrainedSizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return ASSizeRangeMake(CGSizeMake(screenW / 2 - 5, screenW / 2 + 45));
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
