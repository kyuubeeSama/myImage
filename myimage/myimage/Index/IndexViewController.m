//
//  IndexViewController.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

//TODO:新添加的站点，在此处要更新

#import "IndexViewController.h"
#import "WebsiteModel.h"
#import "UserViewController.h"
#import "ImgListViewController.h"
@interface IndexViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)UITableView *mainTable;
@property(nonatomic,copy)NSArray *listArr;

@end

@implementation IndexViewController

-(void)viewWillAppear:(BOOL)animated {
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
    NSLog(@"%@",[FileTool getDocumentPath]);

}

-(void)getData{
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    self.listArr = [sqlTool selectDataFromTable:@"website" where:@"is_delete = 1" field:@"*" Class:[WebsiteModel class]];
    [self.mainTable reloadData];
}

-(void)makeDefaultData{
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    [sqlTool createDBWithName:@"imgDatabase.db" exist:^{
        // 根据需要更新数据库内容
    } success:^{
        [self beginProgressWithTitle:@"正在初始化"];
        // 初次创建数据库成功
        // 创建初始表单
//        website
        [sqlTool createTableWithSql:@"CREATE TABLE IF NOT EXISTS `website`  (website_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,name VARCHAR(200) NOT NULL,value INT NOT NULl,url VARCHAR(200) NOT NULL,is_delete INT NOT NULL DEFAULT(1))"];
//        category
        [sqlTool createTableWithSql:@"CREATE TABLE IF NOT EXISTS `category` (category_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,website_id INT NOT NULL,name VARCHAR(200) NOT NULL,value VARCHAR(50) NOT NULL,is_delete INT NOT NULL DEFAULT(1))"];
//        article
        [sqlTool createTableWithSql:@"CREATE TABLE IF NOT EXISTS `article` (article_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,website_id INT NOT NULL,name VARCHAR(200) NOT NULL,detail_url VARCHAR(200) NOT NULL,has_done INT NOT NULL DEFAULT(1),is_delete INT NOT NULL DEFAULT(1),img_url VARCHAR(200) NOT NULL)"];
//        image
        [sqlTool createTableWithSql:@"CREATE TABLE IF NOT EXISTS `image` (image_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,image_url VARCHAR(200) NOT NULL,article_id INT NOT NULL,width FLOAT DEFAULT(0),height FLOAT DEFAULT(0))"];
//        collect
        [sqlTool createTableWithSql:@"CREATE TABLE IF NOT EXISTS `collect` (collect_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,value INT NOT NULL,type INT NOT NULL)"];
        // 保存最初的数据
//        id，name,url(网站地址)，is_delete(2:删除)
        [sqlTool insertTable:@"website" element:@"name,url,value" value:@"\"撸女吧\",\"https://www.lunu8.com\",1"];
        // 插入分类数据
        NSArray *titleArr = @[@"撸女",@"撸吧",@"推图",@"亚洲",@"欧美",@"日韩"];
        NSArray *idArr = @[@"1",@"2",@"3",@"6",@"8",@"9"];
        for (int i=0;i<titleArr.count;i++){
//            id,website_id,name,value,is_delete(2:删除)
            [sqlTool insertTable:@"category" element:@"website_id,name,value" value:[NSString stringWithFormat:@"1,\"%@\",\"%@\"", titleArr[(NSUInteger) i], idArr[(NSUInteger) i]]];
        }
        [self endProgress];
    } failure:^{
        // 创建数据库失败
        [self alertWithTitle:@"创建数据库失败"];
    }];
}

- (void)setNav {
    UIBarButtonItem *user = [[UIBarButtonItem alloc] initWithTitle:@"用户" style:UIBarButtonItemStylePlain target:self action:@selector(userBtnClick)];
    self.navigationItem.rightBarButtonItem = user;
}

- (void)userBtnClick {
    UserViewController *VC = [[UserViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)makeUI {
    self.mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH - (TOP_HEIGHT) - 45) style:UITableViewStylePlain];
    [self.view addSubview:self.mainTable];
    self.mainTable.delegate = self;
    self.mainTable.dataSource = self;
    self.mainTable.estimatedRowHeight = 0;
    self.mainTable.estimatedSectionFooterHeight = 0;
    self.mainTable.estimatedSectionHeaderHeight = 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    WebsiteModel *model = self.listArr[(NSUInteger) indexPath.row];
    cell.textLabel.text = model.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ImgListViewController *VC = [[ImgListViewController alloc]init];
    WebsiteModel *model = self.listArr[(NSUInteger) indexPath.row];
    VC.model = model;
    [self.navigationController pushViewController:VC animated:YES];    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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
