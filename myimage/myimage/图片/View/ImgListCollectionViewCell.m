//
//  ImgListCollectionViewCell.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/14.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "ImgListCollectionViewCell.h"

@implementation ImgListCollectionViewCell

-(UIImageView *)headImg{
    if (!_headImg) {
        _headImg = [[UIImageView alloc] init];
        [self.contentView addSubview:_headImg];
        _headImg.frame = CGRectMake(0, 0, (screenW-10)/2, (screenW-10)/2);
        _headImg.contentMode = UIViewContentModeScaleAspectFill;
        _headImg.clipsToBounds = YES;
    }
    return _headImg;
}

-(UILabel *)signView{
    if (!_signView) {
        _signView = [[UILabel alloc]init];
        [self.headImg addSubview:_signView];
        [_signView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 20));
            make.right.equalTo(self.headImg.mas_right).offset(-5);
            make.bottom.equalTo(self.headImg.mas_bottom).offset(-5);
        }];
        _signView.backgroundColor = [UIColor blueColor];
        _signView.textAlignment = NSTextAlignmentCenter;
        _signView.text = @"已缓存";
        _signView.textColor = [UIColor whiteColor];
        _signView.font = [UIFont systemFontOfSize:14];
    }
    return _signView;
}

-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        [self.contentView addSubview:_titleLab];
        _titleLab.font = [UIFont systemFontOfSize:13];
        _titleLab.numberOfLines = 2;
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(5);
            make.right.equalTo(self.contentView.mas_right).offset(-5);
            make.height.mas_equalTo(40);
            make.top.equalTo(self.headImg.mas_bottom).offset(5);
        }];
    }
    return _titleLab;
}

-(CycleProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[CycleProgressView alloc]init];
        [self.headImg addSubview:_progressView];
        
        [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.headImg);
            make.size.mas_equalTo(CGSizeMake(100, 100));
        }];
    }
    return _progressView;
}

@end
