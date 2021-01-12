//
//  EditBottomView.m
//  myimage
//
//  Created by Galaxy on 2020/12/29.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "EditBottomView.h"

@implementation EditBottomView

-(instancetype)init{
    self = [super init];
    if (self) {
        self.is_all = NO;
        // 左侧全选按钮
        self.allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.allBtn];
        [self.allBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 40));
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self).offset(30);
        }];
        [self.allBtn setTitle:@"全选" forState:UIControlStateNormal];
        [self.allBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.allBtn setImage:[UIImage systemImageNamed:@"circle"] forState:UIControlStateNormal];
        [self.allBtn setImagePositionWithType:SSImagePositionTypeLeft spacing:5];
        [self.allBtn addTarget:self action:@selector(allBtnClick) forControlEvents:UIControlEventTouchUpInside];
        // 右侧删除按钮
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:deleteBtn];
        [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 40));
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self).offset(-30);
        }];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.layer.masksToBounds = YES;
        deleteBtn.layer.cornerRadius = 20;
        deleteBtn.backgroundColor = [UIColor redColor];
    }
    return self;
}

-(void)allBtnClick{
    self.is_all = !self.is_all;
    if (self.is_all) {
        [self.allBtn setImage:[UIImage systemImageNamed:@"circle.fill"] forState:UIControlStateNormal];
    }else{
        [self.allBtn setImage:[UIImage systemImageNamed:@"circle"] forState:UIControlStateNormal];
    }
    if (self.allBlock) {
        self.allBlock();
    }
}

-(void)deleteBtnClick{
    if (self.deleteBlock) {
        self.deleteBlock();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
