//
//  BaseViewController.h
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//  基础ViewController

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

-(void)alertWithTitle:(NSString *)string;

- (void)beginProgressWithTitle:(nullable NSString *)title;

- (void)endProgress;

@end

NS_ASSUME_NONNULL_END
