//
//  WebSiteTableViewCell.m
//  myimage
//
//  Created by liuqingyuan on 2020/5/6.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "WebSiteTableViewCell.h"

@implementation WebSiteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)switchChange:(UISwitch *)sender {
    if (self.switchValueChange) {
        self.switchValueChange(sender.on);
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
