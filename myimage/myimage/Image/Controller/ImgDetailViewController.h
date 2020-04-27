//
//  ImgDetailViewController.h
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "BaseViewController.h"
#import "ArticleModel.h"
#import "WebsiteModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImgDetailViewController : BaseViewController

@property(nonatomic,copy)void(^imageSaved)(ArticleModel *model);

@property(nonatomic,retain)ArticleModel *articleModel;
@property(nonatomic,retain)WebsiteModel *websiteModel;

@end

NS_ASSUME_NONNULL_END
