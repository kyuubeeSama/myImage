//
//  ImgListCollectionViewCell.h
//  myimage
//
//  Created by liuqingyuan on 2018/12/14.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImgListCollectionViewCell : UICollectionViewCell

@property (nonatomic, retain)UIImageView *headImg;
@property (nonatomic, retain)UILabel *titleLab;
@property (nonatomic, retain)UIButton *signView;

@end

NS_ASSUME_NONNULL_END
