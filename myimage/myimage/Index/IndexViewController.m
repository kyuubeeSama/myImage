//
//  IndexViewController.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "IndexViewController.h"
#import "WebsiteModel.h"
#import "UserViewController.h"
#import "ImgListViewController.h"
#import "UIViewController+CWLateralSlide.h"

@interface IndexViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *mainTable;
@property(nonatomic, copy) NSArray *listArr;

@end

@implementation IndexViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self makeDefaultData];
    self.title = @"首页";
    [self setNav];
    [self makeUI];
    NSLog(@"%@", [FileTool getDocumentPath]);
    WeakSelf(self)
    [self cw_registerShowIntractiveWithEdgeGesture:YES transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        if (direction == CWDrawerTransitionFromLeft) { // 左侧滑出
            [weakself defaultAnimationFromLeft];
        } else if (direction == CWDrawerTransitionFromRight) { // 右侧滑出
        }
    }];
}

- (void)defaultAnimationFromLeft {
    // 强引用leftVC，不用每次创建新的,也可以每次在这里创建leftVC，抽屉收起的时候会释放掉
    UserViewController *VC = [[UserViewController alloc] init];
    [self cw_showDefaultDrawerViewController:VC];
}

- (void)getData {
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    self.listArr = [sqlTool selectDataFromTable:@"website" where:@"is_delete = 1" field:@"*" Class:[WebsiteModel class]];
    [self.mainTable reloadData];
}

- (void)makeDefaultData {
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    [sqlTool createDBWithName:@"imgDatabase.db" exist:^{
        // 根据需要更新数据库内容
    }                 success:^{
        [self beginProgressWithTitle:@"正在初始化"];
        // 初次创建数据库成功
        // 创建初始表单
//        website
        [sqlTool createTableWithSql:@"CREATE TABLE IF NOT EXISTS `website`  "
                                    "(website_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,"
                                    "name VARCHAR(200) NOT NULL,"
                                    "value INT NOT NULl,"
                                    "url VARCHAR(200) NOT NULL,"
                                    "is_delete INT NOT NULL DEFAULT(1))"];
//        category
        [sqlTool createTableWithSql:@"CREATE TABLE IF NOT EXISTS `category` "
                                    "(category_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,"
                                    "website_id INT NOT NULL,"
                                    "name VARCHAR(200) NOT NULL,"
                                    "value VARCHAR(50) NOT NULL,"
                                    "is_delete INT NOT NULL DEFAULT(1))"];
//        此处使用项目时间还是使用前id
        [sqlTool createTableWithSql:@"CREATE TABLE IF NOT EXISTS `article` "
                                    "(article_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,"
                                    "website_id INT NOT NULL,"
                                    "name VARCHAR(200) NOT NULL,"
                                    "category_id INT NOT NULL,"
                                    "detail_url VARCHAR(200) NOT NULL UNIQUE,"
                                    "has_done INT NOT NULL DEFAULT(1),"
                                    "is_delete INT NOT NULL DEFAULT(1),"
                                    "img_url VARCHAR(200) NOT NULL)"];
//        image
        [sqlTool createTableWithSql:@"CREATE TABLE IF NOT EXISTS `image` "
                                    "(image_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                                    "image_url VARCHAR(200) NOT NULL,"
                                    "website_id INT NOT NULL,"
                                    "article_id INT NOT NULL,"
                                    "width FLOAT DEFAULT(0),"
                                    "height FLOAT DEFAULT(0))"];
//        collect
        [sqlTool createTableWithSql:@"CREATE TABLE IF NOT EXISTS `collect` "
                                    "(collect_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                                    "value INT NOT NULL,"
                                    "type INT NOT NULL)"];
//        history  历史记录
        [sqlTool createTableWithSql:@"CREATE TABLE IF NOT EXISTS 'history'"
                                    "(history_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                                    "article_id INTEGER NOT NULL UNIQUE,"
                                    "add_time INTEGER)"];

        [self endProgress];
        [Tool showAlertWithTitle:@"提醒" Message:@"请在个人中心添加站点" withSureBtnClick:^{
            [self defaultAnimationFromLeft];
        }];
    }                 failure:^{
        // 创建数据库失败
        [self alertWithTitle:@"创建数据库失败"];
    }];
}

- (void)setNav {
    UIBarButtonItem *user = [[UIBarButtonItem alloc] initWithTitle:@"用户" style:UIBarButtonItemStylePlain target:self action:@selector(userBtnClick)];
    self.navigationItem.leftBarButtonItem = user;
}

- (void)userBtnClick {
    [self defaultAnimationFromLeft];
}

- (void)makeUI {
    self.mainTable = [[UITableView alloc] init];
    [self.view addSubview:self.mainTable];
    self.mainTable.delegate = self;
    self.mainTable.dataSource = self;
    self.mainTable.estimatedRowHeight = 0;
    self.mainTable.estimatedSectionFooterHeight = 0;
    self.mainTable.estimatedSectionHeaderHeight = 0;
    [self.mainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WebsiteModel *model = self.listArr[(NSUInteger) indexPath.row];
    cell.textLabel.text = model.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ImgListViewController *VC = [[ImgListViewController alloc] init];
    WebsiteModel *model = self.listArr[(NSUInteger) indexPath.row];
    VC.model = model;
    [self.navigationController pushViewController:VC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
