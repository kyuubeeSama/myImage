//
//  ImgListTableView.m
//  myimage
//
//  Created by Galaxy on 2020/8/20.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "ImgListCollectionView.h"
#import "ArticleModel.h"
#import "ImgListCollectionViewCell.h"
@implementation ImgListCollectionView

-(void)setListArr:(NSArray *)listArr{
    _listArr = listArr;
    [self reloadData];
}

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self){
        self.delegate = self;
        self.dataSource = self;
        self.automaticallyAdjustsScrollIndicatorInsets = NO;
        [self registerClass:[ImgListCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        self.backgroundColor = [UIColor systemBackgroundColor];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ArticleModel *model = self.listArr[indexPath.row];
    ImgListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSLog(@"%@,%@,%@", model.name, model.img_url, model.detail_url);
    cell.titleLab.text = model.name;
    NSString *imageStr;
    // 判断图片是否需要拼接
    if([model.img_url containsString:@"http"] || [model.img_url containsString:@"https"]){
        imageStr = model.img_url;
    }else{
        imageStr = [NSString stringWithFormat:@"%@/%@", self.model.url, model.img_url];
//        imageStr = [imageStr stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    }
    if (model.website_id != 4) {
        SDWebImageDownloader *downloader = [SDWebImageManager sharedManager].imageLoader;
        [downloader setValue:[NSString stringWithFormat:@"%@/",self.model.url] forHTTPHeaderField:@"Referer"];
    }
    if (model.has_done == 2) {
        cell.signView.hidden = NO;
    }else{
        cell.signView.hidden = YES;
    }
    NSLog(@"图片地址是%@",imageStr);
//     [cell.headImg sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"placeholder1"]];
    [cell.headImg sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:nil options:SDWebImageQueryMemoryData progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat progress = (CGFloat)receivedSize/(CGFloat)expectedSize;
            cell.progressView.progress = progress*2;
            if (progress <= 0) {
                progress = 0.0;
            }
            cell.progressView.titleLab.text = [NSString stringWithFormat:@"%ld%%",(NSInteger)(progress*100)];
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"错误码是%ld,错误的图片地址是%@",error.code,imageStr);
                cell.progressView.progress = 0;
                cell.progressView.titleLab.text = [NSString stringWithFormat:@"%ld",error.code];
            }else{
                [cell.progressView removeFromSuperview];
                cell.progressView = nil;
            }
        });
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(screenW / 2 - 5, screenW / 2 + 45);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellDidSelect){
        self.cellDidSelect(indexPath);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
