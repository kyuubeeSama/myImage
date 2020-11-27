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
    [self reloadData];
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
    NSString *img_url;
    if (![model.image_url isEqualToString:@"/zhu.js"]) {
        // FIXME:图片无法正常获取，在浏览器中可以，直接读取地址不行
        if([model.image_url containsString:@"http"] || [model.image_url containsString:@"https"]){
            img_url = model.image_url;
        }else{
            img_url = [NSString stringWithFormat:@"%@/%@", self.websiteModel.url, model.image_url];
            img_url = [img_url stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
        }
        if (model.website_id == 5) {
            SDWebImageDownloader *downloader = [SDWebImageManager sharedManager].imageLoader;
            [downloader setValue:@"https://sxchinesegirlz.com/" forHTTPHeaderField:@"Referer"];
        }else if(model.website_id == 2){
            SDWebImageDownloader *downloader = [SDWebImageManager sharedManager].imageLoader;
            [downloader setValue:@"https://www.luge8.cc/" forHTTPHeaderField:@"Referer"];
        }else if(model.website_id == 1){
            SDWebImageDownloader *downloader = [SDWebImageManager sharedManager].imageLoader;
            [downloader setValue:@"https://www.lunu8.com/" forHTTPHeaderField:@"Referer"];
        }
        [cell.topImg sd_setImageWithURL:[NSURL URLWithString:img_url]
                       placeholderImage:[UIImage imageNamed:@"placeholder2"]
                                options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

            }                 completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                if (error == nil) {
                    model.width = image.size.width;
                    model.height = image.size.height;
                    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                } else {
                    //FIXME:图片加载失败的话，会无限重复加载
                    NSLog(@"第%ld张图片出错，出错图片地址是%@%@,错误信息是%@，错误码是%@", (long) indexPath.row, self.websiteModel.url, model.image_url, error.localizedDescription,error.userInfo[@"SDWebImageErrorDownloadStatusCodeKey"]);
                }
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
        self.cellItemDidselected(indexPath);
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
