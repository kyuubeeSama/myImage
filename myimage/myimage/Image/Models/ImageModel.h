//
//  ImageModel.h
//  myimage
//
//  Created by liuqingyuan on 2020/1/2.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageModel : NSObject

@property (nonatomic, assign)int image_id;
@property (nonatomic, copy)NSString *image_url;
@property(nonatomic,assign)int article_id;
@property (nonatomic, assign)CGFloat width;
@property (nonatomic, assign)CGFloat height;

@end

NS_ASSUME_NONNULL_END
