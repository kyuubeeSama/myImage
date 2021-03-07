//
//  ImgCollectionViewCell.m
//  myimage
//
//  Created by liuqingyuan on 2020/1/3.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "ImgCollectionViewCell.h"

@implementation ImgCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)chooseBtnClick:(UIButton *)sender {
    if (self.chooseBlock) {
        self.chooseBlock();
    }
}

@end
