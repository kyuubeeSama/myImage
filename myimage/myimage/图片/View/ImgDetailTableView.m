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
    NSString *img_url;
    if (![model.image_url containsString:@"zhu.js"]){
        if([model.image_url containsString:@"http"] || [model.image_url containsString:@"https"]){
            img_url = model.image_url;
        }else{
            img_url = [NSString stringWithFormat:@"%@/%@", self.websiteModel.url, model.image_url];
            img_url = [img_url stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
        }
        if (model.website_id != 4) {
            SDWebImageDownloader *downloader = [SDWebImageManager sharedManager].imageLoader;
            [downloader setValue:[NSString stringWithFormat:@"%@/",self.websiteModel.url] forHTTPHeaderField:@"Referer"];
        }
        [cell.topImg sd_setImageWithURL:[NSURL URLWithString:img_url]
                       placeholderImage:[UIImage imageNamed:@"placeholder2"]
                                options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

            }                 completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                if (error == nil && image.size.width > 0 && image.size.height > 0) {
                    self.imgArr[indexPath.row] = image;
                    model.width = image.size.width;
                    model.height = image.size.height;
                    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                } else {
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
