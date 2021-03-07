//
//  ImgDetailTableView.h
//  myimage
//
//  Created by Galaxy on 2020/8/20.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebsiteModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImgDetailTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, copy) void(^collectBtnBlock)(NSIndexPath *indexPath);
@property(nonatomic, copy) void (^cellItemDidselected)(NSIndexPath *indexPath,UIImage *image);

@property(nonatomic, strong)NSMutableArray *listArr;
@property(nonatomic, strong)WebsiteModel *websiteModel;
@property(nonatomic,strong)NSMutableArray<UIImage *> *imgArr;

@end

NS_ASSUME_NONNULL_END
