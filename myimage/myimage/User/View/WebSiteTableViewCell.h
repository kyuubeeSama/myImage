//
//  WebSiteTableViewCell.h
//  myimage
//
//  Created by liuqingyuan on 2020/5/6.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebSiteTableViewCell : UITableViewCell

@property(nonatomic,copy)void(^switchValueChange)(BOOL value);
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

@end

NS_ASSUME_NONNULL_END
