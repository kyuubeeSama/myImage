//
//  ImgCollectModel.h
//  myimage
//
//  Created by liuqingyuan on 2020/1/3.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface ImgCollectModel : NSObject

@property (nonatomic, assign)int image_id;
@property (nonatomic, copy)NSString *image_url;
@property(nonatomic,assign)int article_id;
@property(nonatomic, assign) int website_id;
@property (nonatomic, assign)CGFloat width;
@property (nonatomic, assign)CGFloat height;
@property (nonatomic, copy)NSString *url;

@end

NS_ASSUME_NONNULL_END
