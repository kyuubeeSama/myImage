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
    self.listArr = [sqlTool selectDataFromTable:@"website" where:@"is_delete = 1" field:@"*" orderby:@"" Class:[WebsiteModel class]];
    [self.mainTable reloadData];
}

- (void)makeDefaultData {
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    [sqlTool createDBWithName:@"imgDatabase.db" exist:^{
        // 根据需要更新数据库内容
//        查询是否存在某字段，如果不存在，添加字段
        BOOL result = [sqlTool findColumnExistFromTable:@"article" column:@"aid"];
        if (!result) {
            // 添加字段
            BOOL result1 = [sqlTool addColumnFromTable:@"article" columnAndValue:@"aid INT DEFAULT(0)"];
            if (result1) {
                NSLog(@"添加成功");
            } else {
                NSLog(@"添加失败");
            }
        }
    }                 success:^{
        [self beginProgressWithTitle:@"正在初始化"];
        // 初次创建数据库成功
        // 创建初始表单
        [sqlTool createDbTableAndColumn];
        [self endProgress];
        [Tool showAlertWithTitle:@"提醒" Message:@"请在个人中心添加站点" withSureBtnClick:^{
            [self defaultAnimationFromLeft];
        }];
    }                 failure:^{
        // 创建数据库失败
        [self alertWithTitle:@"创建数据库失败"];
    }];
    // 判断本地是否有plist文件，如果没有就拷贝到doc中，如果有，就不操作
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [FileTool createFilePathWithName:@"website.plist"];
    if (![fileManager fileExistsAtPath:filePath]) {
        // 需要拷贝
        if ([fileManager createFileAtPath:filePath contents:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"website" ofType:@"plist"]] attributes:nil]) {
            NSLog(@"拷贝成功");
        } else{
            NSLog(@"拷贝失败");
        }

    }
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
