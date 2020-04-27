//
//  WebsiteViewController.m
//  myimage
//
//  Created by liuqingyuan on 2020/1/6.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//
// TODO:已经添加的站点，标记为已添加，并增加侧滑删除站点功能。

#import "WebsiteViewController.h"

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
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.listArr[(NSUInteger) indexPath.row];
    cell.detailTextLabel.text = [self.websiteArr containsObject:self.listArr[(NSUInteger) indexPath.row]] ? @"已添加" : @"添加";
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    // FIXEME:需要删除三个表中的相关数据,方案一：联表删除  方案二：递归删除
    if([sqlTool deleteDataFromTable:@"website" where:[NSString stringWithFormat:@"name = \"%@\"",self.listArr[(NSUInteger) indexPath.row]]]){
        [self alertWithTitle:@"删除成功"];
        [self getData];
    } else{
        [self alertWithTitle:@"删除失败"];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 添加站点
    if(![self.websiteArr containsObject:self.listArr[(NSUInteger) indexPath.row]]){
        [self beginProgressWithTitle:nil];
        SqliteTool *sqlTool = [SqliteTool sharedInstance];
        switch (indexPath.row){
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
                [sqlTool insertTable:@"website" element:@"name,url,value" value:@"\"24fa\",\"https://www.24fa.top/\",3"];
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
        [self alertWithTitle:@"已添加"];
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
