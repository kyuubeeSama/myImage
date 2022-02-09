//
//  AriticleModel.m
//  myimage
//
//  Created by liuqingyuan on 2020/1/2.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "ArticleModel.h"

@implementation ArticleModel

-(instancetype)initWithArticleCollectModel:(ArticleCollectModel *)model {
    self = [super init];
    if (self){
        self.article_id = model.article_id;
        self.website_id = model.website_id;
        self.img_url = model.img_url;
        self.detail_url = model.img_url;
        self.name = model.name;
        self.has_done = model.has_done;
        self.is_delete = model.is_delete;
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"名字是%@,图标是%@,详情是%@",_name,_img_url,_detail_url];
}

@end
