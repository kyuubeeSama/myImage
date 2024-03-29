//
//  CollectViewController.m
//  myimage
//
//  Created by liuqingyuan on 2020/1/3.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "CollectViewController.h"
#import "ImgListCollectionViewCell.h"
#import "ImgCollectionViewCell.h"
#import "ArticleModel.h"
#import "ArticleCollectModel.h"
#import "ImgDetailViewController.h"
#import "ImgCollectModel.h"

@interface CollectViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *mainCollect;
@property(nonatomic, strong) NSMutableArray *listArr;

@end

@implementation CollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listArr = [[NSMutableArray alloc] init];
    [self setNav];
    [self makeUI];
    [self getData];
}

- (void)setNav {
    self.navigationItem.title = @"收藏";
}

- (void)getData {
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    // 获取相册
    if (self.type == 1) {
//    select article.*,website.url from article left join collect,website on collect.value = article.article_id and website.website_id = article.website_id where type = 1
        NSMutableArray *array = [sqlTool selectDataFromTable:@"article"
                                                        join:@"left join collect,website"
                                                          on:@"article.article_id = collect.value and website.value = article.website_id"
                                                       where:@"collect.type = 1"
                                                       field:@"article.*,website.url"
                                                       limit:self.listArr.count
                                                    pageSize:20
                                                       class:[ArticleCollectModel class]];
        if (array.count > 0) {
        } else {
            [self.mainCollect.mj_footer endRefreshingWithNoMoreData];
        }
        [self.listArr addObjectsFromArray:array];
    } else {
        // 获取图片
//        select image.*,website.url,website.value as website_id from image left join collect,article,website on image.image_id = collect.value and image.article_id = article.article_id and article.website_id = website.website_id where collect.type = 2
        NSMutableArray *array = [sqlTool selectDataFromTable:@"image"
                                                        join:@"left join collect,article,website"
                                                          on:@"image.image_id = collect.value and image.article_id = article.article_id and article.website_id = website.value"
                                                       where:@"collect.type = 2"
                                                       field:@"image.*,website.url,website.value as website_id"
                                                       limit:self.listArr.count
                                                    pageSize:20
                                                       class:[ImgCollectModel class]];
        if (array.count > 0) {
        } else {
            [self.mainCollect.mj_footer endRefreshingWithNoMoreData];
        }
        [self.listArr addObjectsFromArray:array];
    }
    [self.mainCollect.mj_footer endRefreshing];
    [self.mainCollect reloadData];
}

- (void)makeUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.mainCollect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH) collectionViewLayout:layout];
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
        [self getData];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == 1) {
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
    } else {
        // 图片列表
        ImgCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imgCell" forIndexPath:indexPath];
        cell.chooseBtn.hidden = YES;
        ImgCollectModel *model = self.listArr[(NSUInteger) indexPath.row];
        NSString *img_url;
        if([model.image_url containsString:@"http"] || [model.image_url containsString:@"https"]){
            img_url = model.image_url;
        }else{
            img_url = [NSString stringWithFormat:@"%@/%@", model.url, model.image_url];
        }
        if (model.website_id != 4) {
            SDWebImageDownloader *downloader = [SDWebImageManager sharedManager].imageLoader;
            [downloader setValue:[NSString stringWithFormat:@"%@/",model.url] forHTTPHeaderField:@"Referer"];
        }
//        [cell.contentImg sd_setImageWithURL:[NSURL URLWithString:img_url] placeholderImage:[UIImage imageNamed:@"placeholder1"]];
        [cell.contentImg sd_setImageWithURL:[NSURL URLWithString:img_url]
                       placeholderImage:[UIImage imageNamed:@"placeholder1"]
                                options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

            }                 completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                if (error == nil && image.size.width > 0 && image.size.height > 0) {
                    model.width = image.size.width;
                    model.height = image.size.height;
                } else {
                    NSLog(@"第%ld张图片出错，出错图片地址是%@%@,错误信息是%@，错误码是%@", (long) indexPath.row, model.url, model.image_url, error.localizedDescription,error.userInfo[@"SDWebImageErrorDownloadStatusCodeKey"]);
                }
            }];

        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == 1) {
        ArticleCollectModel *model = self.listArr[(NSUInteger) indexPath.row];
        ImgDetailViewController *VC = [[ImgDetailViewController alloc] init];
        VC.articleModel = [[ArticleModel alloc] initWithArticleCollectModel:model];
        [self.navigationController pushViewController:VC animated:YES];
    } else {
        ImgCollectModel *model = self.listArr[(NSUInteger) indexPath.row];
        if (model.width > 0 && model.height>0) {
            NSString *img_url;
            if([model.image_url containsString:@"http"] || [model.image_url containsString:@"https"]){
                img_url = model.image_url;
            }else{
                img_url = [NSString stringWithFormat:@"%@/%@", model.url, model.image_url];
                img_url = [img_url stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            }
            if (model.website_id == 4) {
                img_url = model.image_url;
            }
            GKPhoto *photo = [[GKPhoto alloc]init];
            photo.url = [NSURL URLWithString:img_url];
            GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:@[photo] currentIndex:0];
            browser.showStyle = GKPhotoBrowserShowStyleZoom;
            [browser showFromVC:self];
            
            UIStackView *stackView = [[UIStackView alloc]init];
            stackView.spacing = 20;
            stackView.axis = UILayoutConstraintAxisHorizontal;
            [browser.contentView addSubview:stackView];
            [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@20);
                make.bottom.equalTo(browser.contentView.mas_safeAreaLayoutGuideBottom).offset(-40);
            }];
            
            UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [stackView addArrangedSubview:saveBtn];
            [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
            [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            saveBtn.bounds = CGRectMake(0, 0, 60, 30);
            [[saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:img_url]];
                    [FileTool saveImgWithImageData:data result:^(BOOL success, NSError * _Nonnull error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (error){
                                [self alertWithTitle:@"相册保存失败"];
                            }else{
                                [self alertWithTitle:@"相册保存成功"];
                            }
                        });
                    }];
                });
            }];
            
            UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [stackView addArrangedSubview:deleteBtn];
            [deleteBtn setTitle:@"取消收藏" forState:UIControlStateNormal];
            [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            deleteBtn.bounds = CGRectMake(0, 0, 100, 30);
            [[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                SqliteTool *sqlTool = [SqliteTool sharedInstance];
                if ([sqlTool deleteDataFromTable:@"collect" where:[NSString stringWithFormat:@"value = %d and type = 2", model.image_id]]) {
                    [self.listArr removeObjectAtIndex:(NSUInteger) indexPath.row];
                    [self alertWithTitle:@"取消收藏成功"];
                    [browser dismiss];
                    [self.mainCollect reloadData];
                }
            }];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == 1) {
        return CGSizeMake(screenW / 2 - 5, screenW / 2 + 45);
    } else {
        return CGSizeMake(screenW / 3, screenW / 3 * 48 / 32);
    }
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
