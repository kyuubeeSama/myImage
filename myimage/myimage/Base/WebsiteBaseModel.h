//
//  WebsiteBaseModel.h
//  myimage
//
//  Created by Galaxy on 2023/7/7.
//  Copyright © 2023 liuqingyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"
#import "WebsiteProtocol.h"
#import "ArticleModel.h"
#import "ImageModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface WebsiteBaseModel : NSObject

@property(nonatomic,copy) NSArray *CategoryTitleArr;
@property(nonatomic,copy) NSArray *categoryIdsArr;
@property(nonatomic,copy) NSString *urlStr;
@property(nonatomic,assign) WebsiteType type;

@end

NS_ASSUME_NONNULL_END
