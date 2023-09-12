//
//  WebsiteViewController.m
//  myimage
//
//  Created by liuqingyuan on 2020/1/6.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//  站点管理
//

#import "WebsiteViewController.h"
#import "WebSiteTableViewCell.h"

@interface WebsiteViewController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UITableView *mainTable;
@property(nonatomic, strong) NSMutableArray *websiteArr;
@property(nonatomic, copy) NSArray<WebsiteBaseModel *> *websiteModelArr;

@end
@implementation WebsiteViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.websiteArr = [[NSMutableArray alloc] init];
    self.websiteModelArr = @[
            [[AmetartModel alloc] init],
            [[SexyAsianModel alloc] init],
            [[TwoFourFaModel alloc] init],
            [[ElitebabesModel alloc] init],
            [[SxChineseModel alloc] init],
            [[PiaoLiangModel alloc] init],
            [[OmegaProjectModel alloc] init],
            [[GyrlsModel alloc] init]
    ];
    [self setNav];
    [self getData];
}
- (void)setNav {
    self.navigationItem.title = @"站点管理";
}
- (void)getData {
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    NSMutableArray *webArr = [sqlTool selectDataFromTable:@"website" where:@"is_delete = 1" field:@"*" orderby:@"" Class:[WebsiteModel class]];
    for (WebsiteModel *model  in webArr) {
        [self.websiteArr addObject:model.name];
    }
    [self.mainTable reloadData];
}
- (UITableView *)mainTable {
    if (!_mainTable) {
        _mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, screenW, screenH - (TOP_HEIGHT) - 45) style:UITableViewStylePlain];
        [self.view addSubview:_mainTable];
        _mainTable.delegate = self;
        _mainTable.dataSource = self;
        _mainTable.estimatedRowHeight = 0;
        _mainTable.estimatedSectionFooterHeight = 0;
        _mainTable.estimatedSectionHeaderHeight = 0;
        [_mainTable registerNib:[UINib nibWithNibName:@"WebSiteTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
        [_mainTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        }];
    }
    return _mainTable;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.websiteModelArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WebSiteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"WebSiteTableViewCell" owner:nil options:nil][0];
    }
    cell.titleLab.text = self.websiteModelArr[(NSUInteger) indexPath.row].name;
    cell.switchBtn.on = [self.websiteArr containsObject:self.websiteModelArr[(NSUInteger) indexPath.row].name] ? YES : NO;
    cell.switchValueChange = ^(BOOL value) {
        if (value) {
            // 添加
            [self beginProgressWithTitle:nil];
            SqliteTool *sqlTool = [SqliteTool sharedInstance];
            NSError *error;
            NSArray *array = [[NSArray alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"website" ofType:@"plist"]] error:&error];
            NSMutableArray *valueArr = [[NSMutableArray alloc] init];
            for (NSArray *array1 in array) {
                [valueArr addObject:[array1 componentsJoinedByString:@","]];
            }
            [sqlTool insertTable:@"website"
                         element:@"name,url,value"
                           value:valueArr[indexPath.row]
                           where:nil];
            NSArray *titleArr = self.websiteModelArr[indexPath.row].CategoryTitleArr;
            NSArray *idArr = self.websiteModelArr[indexPath.row].categoryIdsArr;
            for (NSUInteger i = 0; i < titleArr.count; i++) {
                [sqlTool insertTable:@"category"
                             element:@"website_id,name,value"
                               value:[NSString stringWithFormat:@"%ld,'%@','%@'", (long) indexPath.row + 1, titleArr[i], idArr[i]] where:nil];
            }
            [self alertWithTitle:@"添加成功"];
            [self endProgress];
        } else {
            // 删除
            SqliteTool *sqlTool = [SqliteTool sharedInstance];
            // FIXME:需要删除三个表中的相关数据,联表删除
            if ([sqlTool deleteDataFromTable:@"website"
                                       where:[NSString stringWithFormat:@"name = '%@'", self.websiteModelArr[(NSUInteger) indexPath.row].name]]
                    &&
                    [sqlTool deleteDataFromTable:@"category"
                                           where:[NSString stringWithFormat:@"website_id = %ld", indexPath.row + 1]]
                            &&
                    [sqlTool deleteDataFromTable:@"article" where:[NSString stringWithFormat:@"website_id = %ld", indexPath.row + 1]]
                            &&
                    [sqlTool deleteDataFromTable:@"image" where:[NSString stringWithFormat:@"website_id = %ld", indexPath.row + 1]]) {
                [self.websiteArr removeAllObjects];
                [self alertWithTitle:@"删除成功"];
                [self getData];
            } else {
                [self alertWithTitle:@"删除失败"];
            }
        }
    };
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 点击编辑
    NSString *plistPath = [FileTool createFilePathWithName:@"website.plist"];
    NSMutableArray<NSMutableArray<NSString *> *> *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"修改网站地址" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
    }];
    alert.textFields.firstObject.text = [array[indexPath.row][1] stringByReplacingOccurrencesOfString:@"'" withString:@""];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        // 修改plist文件内容
        // 判断地址是否是网址,是就更新到plist文件中
        NSString *urlStr = alert.textFields.firstObject.text;
        if ([self urlValidation:urlStr]) {
            array[indexPath.row][1] = [NSString stringWithFormat:@"'%@'", urlStr];
            // TODO:同时需要判断数据库中是否该数据，是否需要更新
            if ([[SqliteTool sharedInstance] updateTable:@"website" where:[NSString stringWithFormat:@"value = %@", array[indexPath.row][2]] value:[NSString stringWithFormat:@"url = %@", array[indexPath.row][1]]]) {
                NSError *error;
                [array writeToURL:[NSURL URLWithString:plistPath] error:&error];
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                }
            };
        } else {
            [self alertWithTitle:@"输入的网址错误"];
        }
    }];
    [alert addAction:sureAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (BOOL)urlValidation:(NSString *)string {
    NSError *error;
    // 正则1
    NSString *regulaStr = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        return YES;
    }
    return NO;
}

@end
