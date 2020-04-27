//
//  BaseViewController.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property(nonatomic, strong) MBProgressHUD *progress;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)alertWithTitle:(NSString *)string {
    MBProgressHUD *alert = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    alert.label.text = string;
    [alert hideAnimated:YES afterDelay:1];
}

- (void)beginProgressWithTitle:(nullable NSString *)title {
    if (self.progress == nil) {
        self.progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    self.progress.label.text = title;
}

- (void)endProgress {
    if (self.progress) {
        [self.progress hideAnimated:YES];
        self.progress = nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
