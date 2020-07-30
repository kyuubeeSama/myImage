//
//  ImgDetailTableViewCell.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/14.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "ImgDetailTableViewCell.h"

@implementation ImgDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self){
//        self.topImg = [[UIImageView alloc] init];
//        [self addSubview:self.topImg];
//    }
//    return self;
//}

-(UIImageView *)topImg{
    if (!_topImg) {
        _topImg = [[UIImageView alloc]init];
        [self.contentView addSubview:_topImg];
        [_topImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        }];
    }
    return _topImg;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
