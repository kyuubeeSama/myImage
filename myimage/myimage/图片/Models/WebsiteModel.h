//
//  WebsiteModel.h
//  myimage
//
//  Created by liuqingyuan on 2020/1/2.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebsiteModel : NSObject

@property (nonatomic, assign)int website_id;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *url;
@property (nonatomic, assign)int is_delete;
@property (nonatomic, assign)int value;

@end

NS_ASSUME_NONNULL_END
