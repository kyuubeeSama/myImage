//
//  ImgCollectionViewCell.h
//  myimage
//
//  Created by liuqingyuan on 2020/1/3.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImgCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *contentImg;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;

@property(nonatomic,copy)void(^chooseBlock)(void);

@end

NS_ASSUME_NONNULL_END
