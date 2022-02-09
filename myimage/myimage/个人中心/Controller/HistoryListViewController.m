//
//  HistoryListViewController.m
//  myimage
//
//  Created by Galaxy on 2022/2/9.
//  Copyright © 2022 liuqingyuan. All rights reserved.
//

#import "HistoryListViewController.h"
#import "ImgDetailViewController.h"

#import "ImgListCollectionViewCell.h"

#import "ArticleCollectModel.h"

@interface HistoryListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)NSMutableArray *listArr;
@property(nonatomic, strong) UICollectionView *mainCollect;

@end

@implementation HistoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listArr = @[].mutableCopy;
    self.navigationItem.title = @"历史记录";
    [self getHistoryList];
    [self makeUI];
}

-(void)getHistoryList{
   NSArray *array = [SqliteTool.sharedInstance selectDataFromTable:@"history" join:@"left join article,website" on:@"article.article_id = history.article_id and website.value = article.website_id" where:@"1=1 order by add_time desc" field:@"article.*,website.url" limit:self.listArr.count pageSize:20 class:[ArticleCollectModel class]];
    [self.listArr addObjectsFromArray:array];
    [self.mainCollect reloadData];
    NSLog(@"%@",array);
}

- (void)makeUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.mainCollect = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.mainCollect.delegate = self;
    self.mainCollect.dataSource = self;
    [self.view addSubview:self.mainCollect];
    self.mainCollect.backgroundColor = [UIColor systemBackgroundColor];
    [self.mainCollect registerClass:[ImgListCollectionViewCell class] forCellWithReuseIdentifier:@"listCell"];
    [self.mainCollect registerNib:[UINib nibWithNibName:@"ImgCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"imgCell"];
    [self.mainCollect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    self.mainCollect.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [self getHistoryList];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        ImgListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"listCell" forIndexPath:indexPath];
        ArticleCollectModel *model = self.listArr[(NSUInteger) indexPath.row];
        cell.titleLab.text = model.name;
        NSString *img_url;
        if([model.img_url containsString:@"http"] || [model.img_url containsString:@"https"]){
            img_url = model.img_url;
        }else{
            img_url = [NSString stringWithFormat:@"%@/%@", model.url, model.img_url];
        }
        if (model.website_id != 4) {
            SDWebImageDownloader *downloader = [SDWebImageManager sharedManager].imageLoader;
            [downloader setValue:[NSString stringWithFormat:@"%@/",model.url] forHTTPHeaderField:@"Referer"];
        }
        NSLog(@"图片地址是%@",img_url);
        [cell.headImg sd_setImageWithURL:[NSURL URLWithString:img_url] placeholderImage:[UIImage imageNamed:@"placeholder1"]];
        return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
        ArticleCollectModel *model = self.listArr[(NSUInteger) indexPath.row];
        ImgDetailViewController *VC = [[ImgDetailViewController alloc] init];
        VC.articleModel = [[ArticleModel alloc] initWithArticleCollectModel:model];
        [self.navigationController pushViewController:VC animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
        return CGSizeMake(screenW / 2 - 5, screenW / 2 + 45);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
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
