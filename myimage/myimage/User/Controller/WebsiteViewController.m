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
@interface WebsiteViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *mainTable;
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
    self.listArr = @[@"撸女吧",@"撸哥吧",@"24fa",@"趣事百科",@"sxchinesegirlz",@"漂亮网红图"];
    [self.mainTable reloadData];
}

-(UITableView *)mainTable{
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WebSiteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell){
        cell = [[NSBundle mainBundle] loadNibNamed:@"WebSiteTableViewCell" owner:nil options:nil][0];
    }
    cell.titleLab.text = self.listArr[(NSUInteger) indexPath.row];
    cell.switchBtn.on = [self.websiteArr containsObject:self.listArr[(NSUInteger) indexPath.row]] ? YES : NO;
    cell.switchValueChange = ^(BOOL value) {
        if (value){
            // 添加
            [self beginProgressWithTitle:nil];
            SqliteTool *sqlTool = [SqliteTool sharedInstance];
            NSArray *valueArr = @[@"'撸女吧','https://www.lunu8.com',1",
                                  @"'撸哥吧','https://www.lugex.top',2",
                                  @"'24fa','https://www.24fa.cc',3",
                                  @"'趣事百科','https://qq5lk.com',4",
                                  @"'sxchinesegirlz','https://sxchinesegirlz.com',5",
                                  @"'漂亮网红图','http://www.plwht.com',6",
                                  
            ];
            NSArray *allTitleArr = @[
            @[@"撸女",@"撸吧",@"推图",@"亚洲",@"欧美",@"日韩"],
            @[@"欲女",@"撸女",@"亚洲",@"欧美",@"日韩"],
            @[@"美女",@"欧美"],
            @[@"宅福利",@"宅男社",@"撸一管",@"蜜桃社"],
            @[@"nude",@"xiuren"],
            @[@"性感美女",@"精品套图",@"高清套图",@"无圣光"]
            ];
            NSArray *allIdArr = @[
            @[@"1",@"2",@"5",@"6",@"8",@"9"],
            @[@"1",@"2",@"6",@"8",@"9"],
            @[@"49",@"71"],
            @[@"zhaifuli/list_2_",@"zhainanshe/list_4_",@"luyilu/list_5_",@"MiiTao/list_12_"],
            @[@"nude",@"xiuren"],
            @[@"1",@"18",@"24",@"25"]
            ];
            [sqlTool insertTable:@"website"
                         element:@"name,url,value"
                           value:valueArr[indexPath.row]
                           where:nil];
            NSArray *titleArr = allTitleArr[indexPath.row];
            NSArray *idArr = allIdArr[indexPath.row];
            for (NSUInteger i=0; i<titleArr.count; i++) {
                [sqlTool insertTable:@"category"
                             element:@"website_id,name,value"
                               value:[NSString stringWithFormat:@"%ld,'%@','%@'", (long)indexPath.row+1,titleArr[i], idArr[i]] where:nil];
            }
            [self alertWithTitle:@"添加成功"];
            [self endProgress];
        }else{
            // 删除
            SqliteTool *sqlTool = [SqliteTool sharedInstance];
            // FIXEME:需要删除三个表中的相关数据,联表删除
            if([sqlTool deleteDataFromTable:@"website"
                                      where:[NSString stringWithFormat:@"name = '%@'",self.listArr[(NSUInteger) indexPath.row]]]
               &&
               [sqlTool deleteDataFromTable:@"category"
                                      where:[NSString stringWithFormat:@"website_id = %ld",indexPath.row+1]]
               &&
               [sqlTool deleteDataFromTable:@"article" where:[NSString stringWithFormat:@"website_id = %ld",indexPath.row+1]]
               &&
               [sqlTool deleteDataFromTable:@"image" where:[NSString stringWithFormat:@"website_id = %ld",indexPath.row+1]]){
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
