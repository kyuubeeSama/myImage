//
//  CategoryChooseView.h
//  quanyihui
//
//  Created by liuqingyuan on 2019/3/11.
//  Copyright © 2019 qyhl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CategoryButton:UIButton

@property (nonatomic, strong)UIView *bottomLineView;

@end

@interface CategoryChooseView : UIView

@property(nonatomic, copy) void (^chooseBlock)(NSInteger index);

typedef NS_ENUM(NSInteger, CategoryType) {
    // 等宽平分屏幕
        equalWidth,
    // 按照内容大小自适应
        freeSize
};

-(id)initWithFrame:(CGRect)frame CategoryArr:(NSArray *)categoryArr BackColor:(UIColor *)backColor hightLightColor:(UIColor *)heightLightColor TitleColor:(UIColor *)titleColor hightTitleColor:(UIColor *)clickColor bottomLineColor:(UIColor *)bottomLineColor CategoryStyle:(CategoryType)categoryType;

@end

NS_ASSUME_NONNULL_END
