//
//  ImgDetailTableViewCell.h
//  myimage
//
//  Created by liuqingyuan on 2018/12/14.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//  图片详情cell

#import <UIKit/UIKit.h>
#import "CycleProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImgDetailTableViewCell : UITableViewCell

@property (nonatomic, strong)UIImageView *topImg;
@property(nonatomic,strong) CycleProgressView *progressView;

@end

NS_ASSUME_NONNULL_END
