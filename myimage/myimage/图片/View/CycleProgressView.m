//
//  CycleProgressView.m
//  myimage
//
//  Created by 刘清元 on 2022/3/9.
//  Copyright © 2022 liuqingyuan. All rights reserved.
//

#import "CycleProgressView.h"

@implementation CycleProgressView

-(void)setProgress:(CGFloat)progress{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(50, 50) radius:47 startAngle:-M_PI_2 endAngle:-M_PI_2+M_PI_2*2*progress clockwise:YES];
    self.progressLayer.path = path.CGPath;
}

-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]init];
        [self addSubview:_titleLab];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textColor = [UIColor redColor];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.left.right.equalTo(self);
            make.height.mas_equalTo(20);
        }];
    }
    return _titleLab;
}

-(CAShapeLayer *)progressLayer{
    if (!_progressLayer) {
        _progressLayer = [[CAShapeLayer alloc]init];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor redColor].CGColor;
        _progressLayer.opacity = 1;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineWidth = 3;
        [self.layer addSublayer:_progressLayer];
    }
    return _progressLayer;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
