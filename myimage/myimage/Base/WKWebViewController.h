//
//  WKWebViewController.h
//  quanyihui
//
//  Created by liuqingyuan on 2019/9/11.
//  Copyright © 2019 qyhl. All rights reserved.
//

#import "BaseViewController.h"
#import "WebsiteModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewController : BaseViewController

@property(nonatomic, copy) NSString *titleStr;
@property(nonatomic, copy) NSString *urlStr;
@property(nonatomic, strong) WebsiteModel *model;

@end

NS_ASSUME_NONNULL_END
