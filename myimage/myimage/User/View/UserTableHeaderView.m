//
//  UserTableHeaderView.m
//  myimage
//
//  Created by liuqingyuan on 2019/1/24.
//  Copyright © 2019 liuqingyuan. All rights reserved.
//

#import "UserTableHeaderView.h"

@implementation UserTableHeaderView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, 100)];
        [self addSubview:backView];
        backView.backgroundColor = [UIColor whiteColor];

        self.contentLab = [[UILabel alloc] init];
        [backView addSubview:self.contentLab];
        self.contentLab.font = [UIFont systemFontOfSize:15];
        self.contentLab.textColor = [UIColor redColor];
        [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView.mas_left).offset(10);
            make.top.equalTo(backView.mas_top).offset(17.5);
            make.size.mas_equalTo(CGSizeMake(screenW/2-10, 15));
        }];
        
        self.downLab = [[UILabel alloc] init];
        [backView addSubview:self.downLab];
        self.downLab.font = [UIFont systemFontOfSize:15];
        self.downLab.textColor = [UIColor redColor];
        [self.downLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView.mas_left).offset(10);
            make.top.equalTo(backView.mas_centerY).offset(17.5);
            make.size.mas_equalTo(CGSizeMake(screenW/2-10, 15));
        }];
        
        self.imgLab = [[UILabel alloc] init];
        [backView addSubview:self.imgLab];
        self.imgLab.font = [UIFont systemFontOfSize:15];
        self.imgLab.textColor = [UIColor redColor];
        [self.imgLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView.mas_centerX).offset(10);
            make.top.equalTo(backView.mas_top).offset(17.5);
            make.size.mas_equalTo(CGSizeMake(screenW/2-10, 15));
        }];
        
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
