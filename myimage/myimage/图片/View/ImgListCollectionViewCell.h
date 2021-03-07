//
//  ImgListCollectionViewCell.h
//  myimage
//
//  Created by liuqingyuan on 2018/12/14.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//  图片列表cell

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImgListCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong)UIImageView *headImg;
@property (nonatomic, strong)UILabel *titleLab;
@property (nonatomic, strong)UIButton *signView;

@end

NS_ASSUME_NONNULL_END
