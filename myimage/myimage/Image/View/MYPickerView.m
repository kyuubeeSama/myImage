//
//  MYPickerView.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/28.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "MYPickerView.h"

@implementation MYPickerView

-(id)initWithFrame:(CGRect)frame WithArr:(nonnull NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        self.array = array;
        self.backgroundColor = [UIColor whiteColor];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:cancelBtn];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelBtn.frame = CGRectMake(10, 10, 50, 44);
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:sureBtn];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        sureBtn.frame = CGRectMake(screenW-60, 10, 50, 44);
        
        UIPickerView *picker = [[UIPickerView alloc]init];
        [self addSubview:picker];
        picker.frame = CGRectMake(10, 60, screenW, 240);
        picker.delegate = self;
        picker.dataSource = self;
    }
    return self;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.array.count;
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.array[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.num = (int)row;
}

-(void)cancelBtnClick:(UIButton *)button
{
    [self.delegate MYPickerViewCancelBtnClick];
}

-(void)sureBtnClick:(UIButton *)button
{
    [self.delegate MYPickerViewSureBtnClick:self.num];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
