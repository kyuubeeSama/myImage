//
//  MYPickerView.h
//  myimage
//
//  Created by liuqingyuan on 2018/12/28.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MYPickerViewDelegate <NSObject>

-(void)MYPickerViewCancelBtnClick;
-(void)MYPickerViewSureBtnClick:(int)row;

@end

@interface MYPickerView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic,copy)NSArray *array;
@property(nonatomic,weak)id<MYPickerViewDelegate> delegate;
@property(nonatomic,assign)int num;

-(id)initWithFrame:(CGRect)frame WithArr:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
