//
//  ImgListTableView.h
//  myimage
//
//  Created by Galaxy on 2020/8/20.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebsiteModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImgListCollectionView : UICollectionView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic, copy) void(^cellDidSelect)(NSIndexPath *indexPath);
@property(nonatomic,copy)NSArray *listArr;
@property (nonatomic, strong)WebsiteModel *model;

@end

NS_ASSUME_NONNULL_END
