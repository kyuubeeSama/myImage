//
//  UUTableView.h
//  myimage
//
//  Created by Galaxy on 2023/7/7.
//  Copyright © 2023 liuqingyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UUTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,copy) NSArray *listArr;

@end

NS_ASSUME_NONNULL_END
