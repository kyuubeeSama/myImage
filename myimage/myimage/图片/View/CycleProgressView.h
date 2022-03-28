//
//  CycleProgressView.h
//  myimage
//
//  Created by 刘清元 on 2022/3/9.
//  Copyright © 2022 liuqingyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CycleProgressView : UIView

@property(nonatomic,strong) UILabel *titleLab;
@property(nonatomic,assign) CGFloat progress;
@property(nonatomic,strong) CAShapeLayer *progressLayer;

@end

NS_ASSUME_NONNULL_END
