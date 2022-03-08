//
//  ImgDetailViewController.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//  写真详情

#import "ImgDetailViewController.h"
#import "ImgDetailTableViewCell.h"
#import "ImageModel.h"
#import "CollectModel.h"
#import "ImgDetailTableView.h"
#import "WKWebViewController.h"
#import "NSDate+Category.h"

@interface ImgDetailViewController ()

@property(nonatomic, strong) ImgDetailTableView *mainTable;
@property(nonatomic, strong) NSMutableArray *listArr;

@end

@implementation ImgDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listArr = [[NSMutableArray alloc] init];
    if (self.websiteModel == nil) {
        SqliteTool *sqlTool = [SqliteTool sharedInstance];
        self.websiteModel = (WebsiteModel *) [sqlTool findDataFromTable:@"website"
                                                                  where:[NSString stringWithFormat:@"value = %d", self.articleModel.website_id]
                                                                  field:@"*"
                                                                  Class:[WebsiteModel class]];
    }
    [self makeUI];
    [self addHistory];
    [self getData];
    [self setNav];
}
// 获取数据
- (void)getData {
    [self beginProgressWithTitle:nil];
    if (self.articleModel.has_done == 1) {
        DataManager *dataManager = [[DataManager alloc]init];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [dataManager getImageDetailWithType:self.websiteModel detailUrl:self.articleModel.detail_url progress:^(NSUInteger page) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self beginProgressWithTitle:[NSString stringWithFormat:@"正在爬取第%lu页",(unsigned long)page]];
                });
            } success:^(NSMutableArray * _Nonnull array) {
                self.listArr = array;
                SqliteTool *sqlTool = [SqliteTool sharedInstance];
                // 将该页面爬取到的图片都保存到数据库
                if ([self saveImageWithArr:array]) {
                    [sqlTool updateTable:@"article"
                                   where:[NSString stringWithFormat:@"article_id = %d", self.articleModel.article_id]
                                   value:@"has_done = 2"];
                    self.articleModel.has_done = 2;
                    if (self.imageSaved) {
                        self.imageSaved(self.articleModel);
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self endProgress];
                    self.mainTable.listArr = [[NSMutableArray alloc]initWithArray:array];
                });
            } failure:^(NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self endProgress];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (![self.listArr count]) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"数据获取失败" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                            [alert addAction:action];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    });
                });
            }];
        });
    } else {
        SqliteTool *sqlTool = [SqliteTool sharedInstance];
        NSMutableArray *array = [sqlTool selectDataFromTable:@"image"
                                                       where:[NSString stringWithFormat:@"article_id = %d", self.articleModel.article_id]
                                                       field:@"*"
                                                     orderby:@""
                                                       Class:[ImageModel class]];
        [self endProgress];
        self.listArr = array;
        self.mainTable.listArr = [[NSMutableArray alloc]initWithArray:array];
    }
}

// 插入历史数据
-(void)addHistory{
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    [sqlTool replaceTable:@"history" element:@"article_id,add_time" value:[NSString stringWithFormat:@"%d,%@",self.articleModel.article_id,[NSDate nowTimestamp]]];
}

- (BOOL)saveImageWithArr:(NSMutableArray *)array {
    for (ImageModel *model in array) {
        // 保存数据到数据库
        SqliteTool *sqlTool = [SqliteTool sharedInstance];
        if(![sqlTool insertTable:@"image"
                         element:@"image_url,article_id,website_id"
                           value:[NSString stringWithFormat:@"'%@',%d,%d", model.image_url, self.articleModel.article_id,self.articleModel.website_id]
                           where:[NSString stringWithFormat:@"select * from image where image_url = '%@' and article_id = %d",model.image_url,self.articleModel.article_id]]){
            return false;
        }
    }
    return YES;
}

- (void)makeUI {
    self.mainTable = [[ImgDetailTableView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH) style:UITableViewStylePlain];
    [self.view addSubview:self.mainTable];
    WeakSelf(self)
    self.mainTable.cellItemDidselected = ^(NSIndexPath * _Nonnull indexPath, UIImage * _Nonnull image) {
        ImageModel *model = weakself.listArr[(NSUInteger) indexPath.row];
        if (model.width > 0 && model.height > 0) {
            HZPhotoBrowser *browser = [[HZPhotoBrowser alloc] init];
            browser.isFullWidthForLandScape = YES;
            browser.isNeedLandscape = YES;
            browser.currentImageIndex = 0;
            browser.btnArr = @[@"收藏",@"下载"];
            NSString *img_url;
            if([model.image_url containsString:@"http"] || [model.image_url containsString:@"https"]){
                img_url = model.image_url;
            }else{
                if (model.website_id == 5 && [model.image_url containsString:@"//"]) {
                    img_url = [NSString stringWithFormat:@"https:%@",model.image_url];
                }else{
                    img_url = [NSString stringWithFormat:@"%@/%@", self.websiteModel.url, model.image_url];
                    img_url = [img_url stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
                }
            }
            if (model.website_id == 4) {
                img_url = model.image_url;
            }
            if (model.website_id == 5) {
                img_url = [img_url componentsSeparatedByString:@"?"][0];
                for (NSString *itemStr in @[@"0",@"1",@"2",@"3"]) {
                    img_url = [img_url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"https://i%@.wp.com/www.sxchinesegirlz.xyz/",itemStr] withString:@"https://sxchinesegirlz.b-cdn.net/"];
                }
            }
            browser.imageArray = @[img_url];
            [browser show];
            WeakSelf(browser)
            browser.otherBtnBlock = ^(NSInteger index) {
                if (index == 0){
                    // 收藏
                    SqliteTool *sqlTool = [SqliteTool sharedInstance];
                    CollectModel *collect = (CollectModel *)[sqlTool findDataFromTable:@"collect" where:[NSString stringWithFormat:@"value=%d and type = 2",model.image_id] field:@"*" Class:[CollectModel class]];
                    if (collect.value != 0){
                        [weakself alertWithTitle:@"已收藏"];
                    }else{
                        if([sqlTool insertTable:@"collect"
                                        element:@"value,type"
                                          value:[NSString stringWithFormat:@"%d,2",model.image_id]
                                          where:nil]){
                            [weakbrowser showTip:@"收藏成功"];
                        }else{
                            [weakbrowser showTip:@"收藏失败"];
                        }
                    }
                }else if(index == 1){
                    //                    创建文件名
                    NSString *fileName = [NSString stringWithFormat:@"%d_%@.jpg",weakself.websiteModel.value,[NSDate nowTimestamp]];
                    NSString *filePath = [FileTool createFilePathWithName:[NSString stringWithFormat:@"images/%@",fileName]];
                    [FileTool createDocumentWithname:@"images"];
                    //MARK:保存前需要先创建文件夹
                    if ([UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:YES]) {
                        [weakbrowser showTip:@"本地保存成功"];
                    }else{
                        [weakbrowser showTip:@"本地保存失败"];
                    }
                }
            };
        }
    };
    self.mainTable.websiteModel = self.websiteModel;
}

- (void)setNav {
    UIBarButtonItem *moreBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"filemenu.and.selection"] style:UIBarButtonItemStylePlain target:self action:@selector(moreBtnClick)];
    self.navigationItem.rightBarButtonItem = moreBtnItem;
    
}

-(void)moreBtnClick{
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    CollectModel *model = (CollectModel *) [sqlTool findDataFromTable:@"collect"
                                                                where:[NSString stringWithFormat:@"value = %d and type = 1", self.articleModel.article_id]
                                                                field:@"*"
                                                                Class:[CollectModel class]];
    NSString *colStr;
    if (model.value == 0) {
        colStr = @"收藏";
    } else {
        colStr = @"取消收藏";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"菜单" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    //    收藏
    UIAlertAction *collectAction = [UIAlertAction actionWithTitle:colStr style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self collectBtnClick];
    }];
    [alertController addAction:collectAction];
    // 系统浏览器打开
    UIAlertAction *webAction = [UIAlertAction actionWithTitle:@"浏览器打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self browserBtnClick];
    }];
    [alertController addAction:webAction];
    // 删除本地缓存
    UIAlertAction *cleanAction = [UIAlertAction actionWithTitle:@"删除本地缓存" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        BOOL result = [sqlTool updateTable:@"article" where:[NSString stringWithFormat:@"article_id = %d",self.articleModel.article_id] value:@"has_done = 1"];
        if (result && self.imageSaved){
            self.articleModel.has_done = 1;
            self.imageSaved(self.articleModel);
        }
    }];
    [alertController addAction:cleanAction];
    // 取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)collectBtnClick {
    // 收藏操作
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    CollectModel *model = (CollectModel *) [sqlTool findDataFromTable:@"collect"
                                                                where:[NSString stringWithFormat:@"value = %d and type = 1", self.articleModel.article_id]
                                                                field:@"*"
                                                                Class:[CollectModel class]];
    if (model.value == 0) {
        // 收藏
        if ([sqlTool insertTable:@"collect"
                         element:@"value,type"
                           value:[NSString stringWithFormat:@"%d,1", self.articleModel.article_id]
                           where:nil]) {
            [self alertWithTitle:@"收藏成功"];
        } else {
            [self alertWithTitle:@"收藏失败"];
        }
    } else {
        // 取消收藏
        if ([sqlTool deleteDataFromTable:@"collect" where:[NSString stringWithFormat:@"value = %d and type = 1", self.articleModel.article_id]]) {
            [self alertWithTitle:@"取消收藏"];
        } else {
            [self alertWithTitle:@"操作失败"];
        }
    }
}

- (void)browserBtnClick {
    NSString  *urlStr = [NSString stringWithFormat:@"%@/%@", self.websiteModel.url, self.articleModel.detail_url];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:nil];
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
