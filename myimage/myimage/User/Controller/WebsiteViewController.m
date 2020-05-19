//
//  WebsiteViewController.m
//  myimage
//
//  Created by liuqingyuan on 2020/1/6.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//
//

#import "WebsiteViewController.h"
#import "WebSiteTableViewCell.h"
@interface WebsiteViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain)UITableView *mainTable;
@property (nonatomic, copy)NSArray *listArr;
@property (nonatomic, strong)NSMutableArray *websiteArr;

@end

@implementation WebsiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listArr = @[];
    self.websiteArr = [[NSMutableArray alloc] init];
    [self setNav];
    [self makeUI];
    [self getData];
}

-(void)setNav{
    self.navigationItem.title = @"站点管理";
}

-(void)getData{
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    NSMutableArray *webArr = [sqlTool selectDataFromTable:@"website" where:@"is_delete = 1" field:@"*" Class:[WebsiteModel class]];
    for(WebsiteModel *model  in webArr){
        [self.websiteArr addObject:model.name];
    }
    self.listArr = @[@"撸女吧",@"撸哥吧",@"24fa"];
    [self.mainTable reloadData];
}

-(void)makeUI{
    self.mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, screenW, screenH - (TOP_HEIGHT) - 45) style:UITableViewStylePlain];
    [self.view addSubview:self.mainTable];
    self.mainTable.delegate = self;
    self.mainTable.dataSource = self;
    self.mainTable.estimatedRowHeight = 0;
    self.mainTable.estimatedSectionFooterHeight = 0;
    self.mainTable.estimatedSectionHeaderHeight = 0;
    [self.mainTable registerNib:[UINib nibWithNibName:@"WebSiteTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WebSiteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell){
        cell = [[NSBundle mainBundle] loadNibNamed:@"WebSiteTableViewCell" owner:nil options:nil][0];
    }
    cell.titleLab.text = self.listArr[indexPath.row];
    cell.switchBtn.on = [self.websiteArr containsObject:self.listArr[(NSUInteger) indexPath.row]] ? YES : NO;
    cell.switchValueChange = ^(BOOL value) {
        if (value){
            // 添加
            [self beginProgressWithTitle:nil];
            SqliteTool *sqlTool = [SqliteTool sharedInstance];
            switch (indexPath.row){
                case 0:{
                    //        id，name,url(网站地址)，is_delete(2:删除)
                    [sqlTool insertTable:@"website" element:@"name,url,value" value:@"\"撸女吧\",\"https://www.lunu8.com\",1"];
                    // 插入分类数据
                    NSArray *titleArr = @[@"撸女",@"撸吧",@"推图",@"亚洲",@"欧美",@"日韩"];
                    NSArray *idArr = @[@"1",@"2",@"3",@"6",@"8",@"9"];
                    for (int i=0;i<titleArr.count;i++){
//            id,website_id,name,value,is_delete(2:删除)
                        [sqlTool insertTable:@"category" element:@"website_id,name,value" value:[NSString stringWithFormat:@"1,\"%@\",\"%@\"", titleArr[(NSUInteger) i], idArr[(NSUInteger) i]]];
                    }
                    [self alertWithTitle:@"添加成功"];
                }
                    break;
                case 1:{
                    [sqlTool insertTable:@"website" element:@"name,url,value" value:@"\"撸哥吧\",\"https://www.lugex.top\",2"];
                    // 插入分类数据
                    NSArray *titleArr = @[@"欲女",@"撸女",@"亚洲",@"欧美",@"日韩"];
                    NSArray *idArr = @[@"1",@"2",@"6",@"8",@"9"];
                    for (int i=0;i<titleArr.count;i++){
//            id,website_id,name,value,is_delete(2:删除)
                        [sqlTool insertTable:@"category" element:@"website_id,name,value" value:[NSString stringWithFormat:@"2,\"%@\",\"%@\"", titleArr[(NSUInteger) i], idArr[(NSUInteger) i]]];
                    }
                    [self alertWithTitle:@"添加成功"];
                }
                    break;
                case 2:{
                    [sqlTool insertTable:@"website" element:@"name,url,value" value:@"\"24fa\",\"https://www.24fa.cc\",3"];
                    NSArray *titleArr = @[@"美女",@"欧美"];
                    NSArray *idArr = @[@"49",@"71"];
                    for (int i = 0; i < titleArr.count; ++i) {
                        [sqlTool insertTable:@"category" element:@"website_id,name,value" value:[NSString stringWithFormat:@"3,\"%@\",\"%@\"", titleArr[(NSUInteger) i], idArr[(NSUInteger) i]]];
                    }
                    [self alertWithTitle:@"添加成功"];
                }
                    break;
                default:
                    break;
            }
            [self endProgress];
        }else{
            // 删除
            SqliteTool *sqlTool = [SqliteTool sharedInstance];
            // FIXEME:需要删除三个表中的相关数据,方案一：联表删除  方案二：递归删除
            if([sqlTool deleteDataFromTable:@"website" where:[NSString stringWithFormat:@"name = \"%@\"",self.listArr[(NSUInteger) indexPath.row]]]){
                [self.websiteArr removeAllObjects];
                [self alertWithTitle:@"删除成功"];
                [self getData];
            } else{
                [self alertWithTitle:@"删除失败"];
            }
        }
    };
    return cell;
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
