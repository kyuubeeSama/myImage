//
//  CategoryChooseView.m
//  quanyihui
//
//  Created by liuqingyuan on 2019/3/11.
//  Copyright © 2019 qyhl. All rights reserved.
//

#import "CategoryChooseView.h"

@implementation CategoryButton

-(UIView *)bottomLineView{
    if (_bottomLineView == nil){
        _bottomLineView = [[UIView alloc] init];
        [self addSubview:_bottomLineView];
        _bottomLineView.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    }
    return _bottomLineView;
}

@end

@interface CategoryChooseView ()

@property(nonatomic, copy) NSArray *titleArr;
@property (nonatomic, strong)UIScrollView *backScrollView;
@property (nonatomic, strong)UIColor *btnBackgroundColor;
@property (nonatomic, strong)UIColor *btnTitleColor;
@property(nonatomic,strong)UIColor *hightLightColor;
@property(nonatomic,strong)UIColor *clickColor;
@property(nonatomic,strong)NSMutableArray *widthArr;
@property(nonatomic,assign)CategoryType categoryType;

@end

@implementation CategoryChooseView

-(instancetype)initWithFrame:(CGRect)frame CategoryArr:(NSArray *)categoryArr BackColor:(UIColor *)backColor hightLightColor:(UIColor *)heightLightColor TitleColor:(UIColor *)titleColor hightTitleColor:(UIColor *)clickColor bottomLineColor:(UIColor *)bottomLineColor CategoryStyle:(CategoryType)categoryType {
    self = [super initWithFrame:frame];
    if (self){
        self.categoryType = categoryType;
        self.widthArr = [[NSMutableArray alloc]init];
        self.titleArr = categoryArr;
        self.btnBackgroundColor = backColor;
        self.btnTitleColor = titleColor;
        self.hightLightColor = heightLightColor;
        self.clickColor = clickColor;
        switch (categoryType){
            case equalWidth:{
                UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
                [self addSubview:backView];
                for (int i=0;i<self.titleArr.count;i++){
                    CategoryButton *button = [CategoryButton buttonWithType:UIButtonTypeCustom];
                    [backView addSubview:button];
                    button.frame = CGRectMake(frame.size.width/categoryArr.count*i, 0, frame.size.width/categoryArr.count, frame.size.height-1);
                    [button setTitle:categoryArr[i] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                    button.tag = 4400+i;
                    button.bottomLineView.backgroundColor = bottomLineColor;
                    if (i == 0){
                        button.bottomLineView.hidden = NO;
                        [button setTitleColor:clickColor forState:UIControlStateNormal];
                    }else{
                        button.bottomLineView.hidden = YES;
                        [button setTitleColor:titleColor forState:UIControlStateNormal];
                    }
                    button.backgroundColor = backColor;
                    button.titleLabel.font = [UIFont systemFontOfSize:15];
                }
            }
                break;
            case freeSize:{
                self.backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
                [self addSubview:self.backScrollView];
                CGFloat scrollWidth = 0;
                for (int i=0;i<categoryArr.count;i++){
                    CategoryButton *button = [CategoryButton buttonWithType:UIButtonTypeCustom];
                    [self.backScrollView addSubview:button];
                    button.backgroundColor = backColor;
                    [button setTitle:categoryArr[i] forState:UIControlStateNormal];
                    [button setTitleColor:titleColor forState:UIControlStateNormal];
                    CGSize size = [categoryArr[i] getSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 15)];
                    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                    button.frame = CGRectMake(scrollWidth, 0, size.width+40, frame.size.height-1);
                    self.widthArr[i] = [NSNumber numberWithFloat:scrollWidth];
                    button.bottomLineView.backgroundColor = bottomLineColor;
                    if (i == 0){
                        button.bottomLineView.hidden = NO;
                        [button setTitleColor:clickColor forState:UIControlStateNormal];
                    } else{
                        button.bottomLineView.hidden = YES;
                        [button setTitleColor:titleColor forState:UIControlStateNormal];
                    }
                    button.tag = 4400+i;
                    scrollWidth = scrollWidth+size.width+40;
                    self.backScrollView.contentSize = CGSizeMake(scrollWidth, frame.size.height);
                    self.backScrollView.showsVerticalScrollIndicator = NO;
                    self.backScrollView.showsHorizontalScrollIndicator = NO;
                }
            }
                break;
            default:{

            }
                break;
        }

    }
    return self;
}

-(void)setIndex:(int)index{
    for (int i= 0; i<self.titleArr.count; i++) {
        CategoryButton *btn = [self viewWithTag:4400+i];
        [btn setTitleColor:self.btnTitleColor forState:UIControlStateNormal];
        btn.backgroundColor = self.btnBackgroundColor;
        btn.bottomLineView.hidden = YES;
    }
    CategoryButton *button = [self viewWithTag:4400+index];
    [button setTitleColor:self.clickColor forState:UIControlStateNormal];
    button.backgroundColor = self.hightLightColor;
    button.bottomLineView.hidden = NO;
    if(self.chooseBlock){
        self.chooseBlock(index);
    }
    [self moveToIndex:index];
}

-(void)moveToIndex:(NSInteger)index{
    if (self.categoryType == freeSize) {
        NSNumber *number = self.widthArr[index];
        CGFloat scrollWidth = [number floatValue];
        if(scrollWidth < screenW/2){
            self.backScrollView.contentOffset = CGPointMake(0, 0);
        }else if(self.backScrollView.contentSize.width-scrollWidth>screenW){
            CGSize size = [self.titleArr[index] getSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 15)];
            CGFloat offsetX = scrollWidth-(screenW-size.width-40)/2;
            self.backScrollView.contentOffset = CGPointMake(offsetX, 0);
        } else{
            self.backScrollView.contentOffset = CGPointMake(self.backScrollView.contentSize.width-screenW, 0);
        }
    }
}

-(void)buttonClick:(CategoryButton *)button{
    for (int i= 0; i<self.titleArr.count; i++) {
        CategoryButton *btn = [self viewWithTag:4400+i];
        [btn setTitleColor:self.btnTitleColor forState:UIControlStateNormal];
        btn.backgroundColor = self.btnBackgroundColor;
        btn.bottomLineView.hidden = YES;
    }
    [button setTitleColor:self.clickColor forState:UIControlStateNormal];
    button.backgroundColor = self.hightLightColor;
    button.bottomLineView.hidden = NO;
    if(self.chooseBlock){
        self.chooseBlock((int)button.tag-4400);
    }
    [self moveToIndex:button.tag-4400];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
