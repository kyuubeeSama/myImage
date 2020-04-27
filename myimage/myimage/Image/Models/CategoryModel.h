//
//  CategoryModel.h
//  myimage
//
//  Created by liuqingyuan on 2020/1/2.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface CategoryModel : NSObject

@property (nonatomic, assign)int website_id;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, assign)int is_delete;
@property (nonatomic, copy)NSString *value;
@property (nonatomic, assign)int category_id;

@end

NS_ASSUME_NONNULL_END
