//
//  ImgListCollectionViewCell.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/14.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "ImgListCollectionViewCell.h"

@implementation ImgListCollectionViewCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.headImg = [[UIImageView alloc] init];
        [self.contentView addSubview:self.headImg];
        self.headImg.frame = CGRectMake(0, 0, (screenW-10)/2, (screenW-10)/2);
        self.headImg.contentMode = UIViewContentModeScaleAspectFill;
        self.headImg.clipsToBounds = YES;
        
        self.signView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.headImg addSubview:self.signView];
        [self.signView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 20));
            make.right.equalTo(self.headImg.mas_right).offset(-5);
            make.bottom.equalTo(self.headImg.mas_bottom).offset(-5);
        }];
        self.signView.hidden = YES;
        self.signView.backgroundColor = [UIColor blueColor];
        [self.signView setTitle:@"已缓存" forState:UIControlStateNormal];
        [self.signView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.signView.titleLabel.font = [UIFont systemFontOfSize:14];
        
        self.titleLab = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLab];
        self.titleLab.font = [UIFont systemFontOfSize:13];
        self.titleLab.numberOfLines = 2;
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(5);
            make.right.equalTo(self.contentView.mas_right).offset(-5);
            make.height.mas_equalTo(40);
            make.top.equalTo(self.headImg.mas_bottom).offset(5);
        }];
    }
    return self;
}



@end
