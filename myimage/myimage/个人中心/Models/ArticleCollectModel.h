//
//  ArticleCollectModel.h
//  myimage
//
//  Created by liuqingyuan on 2020/1/3.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//  写真收藏

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArticleCollectModel : NSObject

@property (nonatomic, assign)int article_id;
@property (nonatomic, assign)int website_id;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *detail_url;
@property (nonatomic, copy)NSString *img_url;
@property (nonatomic, assign)int has_done;
@property (nonatomic, assign)int is_delete;
@property (nonatomic,copy)NSString *url;

@end

NS_ASSUME_NONNULL_END
