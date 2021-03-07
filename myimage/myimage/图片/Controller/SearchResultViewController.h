//
//  SearchResultViewController.h
//  myimage
//
//  Created by Galaxy on 2020/9/8.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "BaseViewController.h"
#import "WebsiteModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SearchResultViewController : BaseViewController

@property (nonatomic,strong)WebsiteModel *model;
@property (nonatomic,copy) NSString *keyword;

@end

NS_ASSUME_NONNULL_END
