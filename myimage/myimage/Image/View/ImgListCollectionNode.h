//
//  ImgListCollectionNode.h
//  myimage
//
//  Created by liuqingyuan on 2020/6/10.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImgListCollectionNode : ASCellNode

@property(nonatomic,strong)ASNetworkImageNode *topImgNode;
@property(nonatomic,strong)ASTextNode *titleNode;

@end

NS_ASSUME_NONNULL_END
