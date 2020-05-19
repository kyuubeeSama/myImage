//
//  NSObject+Tool.m
//  PPDLoanSDKDemon
//
//  Created by 秦 on 16/8/19.
//  Copyright © 2016年 ppdai. All rights reserved.
//

#import "NSObject+Tool.h"

@implementation NSObject (Tool)
-(UIViewController *)currentViewController
{
    UIViewController *vc=objc_getAssociatedObject(self, _cmd);
    if (vc==nil) {
        if(@available(iOS 13,*)){
            vc = [UIApplication topViewControllerWithRootViewController:[UIApplication sharedApplication].windows[0].rootViewController];
        }else{
            vc=[UIApplication topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        }
    }
    return vc;
}
+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end
