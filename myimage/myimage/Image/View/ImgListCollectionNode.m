//
//  ImgListCollectionNode.m
//  myimage
//
//  Created by liuqingyuan on 2020/6/10.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "ImgListCollectionNode.h"

@implementation ImgListCollectionNode

-(instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

-(ASNetworkImageNode *)topImgNode{
    if (!_topImgNode) {
        _topImgNode = [[ASNetworkImageNode alloc]init];
        [self addSubnode:_topImgNode];
        _topImgNode.frame = CGRectMake(0, 0, screenW/2-5, screenW/2-5);
        _topImgNode.contentMode = UIViewContentModeScaleAspectFill;
        _topImgNode.clipsToBounds = YES;
    }
    return _topImgNode;
}

-(ASTextNode *)titleNode{
    if (!_titleNode) {
        _titleNode = [[ASTextNode alloc]init];
        [self addSubnode:_titleNode];
        _titleNode.frame = CGRectMake(0, screenW/2, screenW/2-5, 40);
        _titleNode.tintColor = [UIColor dm_colorWithLightColor:[UIColor colorWithHexString:@"333333"] darkColor:[UIColor whiteColor]];
    }
    return _titleNode;
}

@end
