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
        self.backgroundColor = [UIColor whiteColor];
        CALayer *layer = [[CALayer alloc]init];
        [self.layer addSublayer:layer];
        layer.frame = CGRectMake(0, 0, screenW, 1);
        layer.backgroundColor = [UIColor colorWithHexString:@"888888"].CGColor;
        self.is_all = NO;
        // 左侧全选按钮
        self.allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.allBtn];
        [self.allBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self).offset(30);
        }];
        [self.allBtn setTitle:@"全选" forState:UIControlStateNormal];
        [self.allBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.allBtn setImage:[UIImage systemImageNamed:@"circle"] forState:UIControlStateNormal];
        [self.allBtn setImagePositionWithType:SSImagePositionTypeLeft spacing:5];
        [[self.allBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *x) {
            self.is_all = !self.is_all;
            if (self.is_all) {
                [self.allBtn setImage:[UIImage systemImageNamed:@"circle.fill"] forState:UIControlStateNormal];
            }else{
                [self.allBtn setImage:[UIImage systemImageNamed:@"circle"] forState:UIControlStateNormal];
            }
            if (self.allBlock) {
                self.allBlock();
            }
        }];
        // 右侧删除按钮
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:deleteBtn];
        [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self).offset(-30);
        }];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *x) {
            if (self.deleteBlock) {
                self.deleteBlock();
            }
        }];
        deleteBtn.titleLabel.font= [UIFont systemFontOfSize:15];
        deleteBtn.layer.masksToBounds = YES;
        deleteBtn.layer.cornerRadius = 15;
        deleteBtn.backgroundColor = [UIColor redColor];
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
