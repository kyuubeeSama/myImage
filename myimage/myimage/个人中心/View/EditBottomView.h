//
//  EditBottomView.h
//  myimage
//
//  Created by Galaxy on 2020/12/29.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditBottomView : UIView

@property(nonatomic,strong)UIButton *allBtn;
@property(nonatomic,assign)BOOL is_all;
@property(nonatomic,copy)void(^allBlock)(void);
@property(nonatomic,copy)void(^deleteBlock)(void);

@end

NS_ASSUME_NONNULL_END
