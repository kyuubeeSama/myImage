//
//  ImgDetailTableView.m
//  myimage
//
//  Created by Galaxy on 2020/8/20.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "ImgDetailTableView.h"
#import "ImgDetailTableViewCell.h"
#import "ImageModel.h"

@implementation ImgDetailTableView

-(void)setListArr:(NSMutableArray *)listArr{
    _listArr = listArr;
    [self prefetcherImage];
    [self reloadData];
}

-(void)prefetcherImage{
    NSMutableArray *urlArr =@[].mutableCopy;
    for (ImageModel *model in self.listArr) {
        NSString *img_url;
        if (![model.image_url containsString:@"zhu.js"]){
            if([model.image_url containsString:@"http"] || [model.image_url containsString:@"https"]){
                img_url = model.image_url;
            }else{
                if (model.website_id == 5 && [model.image_url containsString:@"//"]) {
                    img_url = [NSString stringWithFormat:@"https:%@",model.image_url];
                }else{
                    img_url = [NSString stringWithFormat:@"%@/%@", self.websiteModel.url, model.image_url];
                    img_url = [img_url stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
                }
            }
            if (model.website_id != 4) {
                SDWebImageDownloader *downloader = [SDWebImageManager sharedManager].imageLoader;
                [downloader setValue:[NSString stringWithFormat:@"%@/",self.websiteModel.url] forHTTPHeaderField:@"Referer"];
            }
            if (model.website_id == 5) {
                img_url = [img_url componentsSeparatedByString:@"?"][0];
                for (NSString *itemStr in @[@"0",@"1",@"2",@"3"]) {
                    img_url = [img_url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"https://i%@.wp.com/www.sxchinesegirlz.xyz/",itemStr] withString:@"https://sxchinesegirlz-0ne.b-cdn.net/"];
                }
            }
        }
        model.image_url = img_url;
        NSURL *url = [NSURL URLWithString:img_url];
        [urlArr addObject:url];
    }
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urlArr];
}

-(NSMutableArray *)imgArr{
    if (!_imgArr) {
        _imgArr = [[NSMutableArray alloc]init];
        for (int i=0; i<self.listArr.count; i++) {
            [_imgArr addObject:[[UIImage alloc]init]];
        }
    }
    return _imgArr;
}

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self){
        self.delegate = self;
        self.dataSource = self;
        self.estimatedRowHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        [self registerClass:[ImgDetailTableViewCell class] forCellReuseIdentifier:@"cell"];
        self.backgroundColor = [UIColor systemBackgroundColor];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImgDetailTableViewCell *cell = [[ImgDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    ImageModel *model = self.listArr[(NSUInteger) indexPath.row];
    if (![model.image_url containsString:@"zhu.js"]){
//        [cell.topImg sd_setImageWithURL:[NSURL URLWithString:model.image_url]
//                       placeholderImage:[UIImage imageNamed:@"placeholder2"]
//                                options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {
//
//        }                 completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
//            if (error == nil && image.size.width > 0 && image.size.height > 0) {
//                self.imgArr[indexPath.row] = image;
//                model.width = image.size.width;
//                model.height = image.size.height;
//                [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            } else {
//                NSLog(@"第%ld张图片出错，出错图片地址是%@,错误信息是%@，错误码是%@", (long) indexPath.row,  model.image_url, error.localizedDescription,error.userInfo[@"SDWebImageErrorDownloadStatusCodeKey"]);
//            }
//        }];
        [cell.topImg sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:nil options:SDWebImageQueryMemoryData progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
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
                    NSLog(@"错误码是%ld,错误的图片地址是%@",error.code,model.image_url);
                    cell.progressView.progress = 0;
                    cell.progressView.titleLab.text = [NSString stringWithFormat:@"%ld",error.code];
                }else{
                    [cell.progressView removeFromSuperview];
                    cell.progressView = nil;
                }
            });
        }];
    } else {
        // 容错错误文件
        model.width = screenW;
        model.height = 1;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.cellItemDidselected){
        self.cellItemDidselected(indexPath,self.imgArr[indexPath.row]);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageModel *model = self.listArr[(NSUInteger) indexPath.row];
    if (model.width > 0 && model.height > 0) {
        return model.height * screenW / model.width + 10;
    } else {
        return screenW*3/2;
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
