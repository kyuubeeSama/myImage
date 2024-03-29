//
//  ImgListViewController.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//  TODO:替换控件为AsyncDisplayKit控件。数据数组，减少重复访问


#import "ImgListViewController.h"
#import "CategoryModel.h"
#import "SearchResultViewController.h"
#import "ImgCategoryListViewController.h"

@interface ImgListViewController ()<UISearchBarDelegate,JXCategoryViewDelegate,JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) NSMutableArray *titleArr;

@property (nonatomic, strong) JXCategoryTitleView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

// 类型数组
@property(nonatomic, copy) NSArray *categoryArr;
@property(nonatomic,assign) NSInteger pageNum;
@property(nonatomic,assign) BOOL isJump;

@end

@implementation ImgListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNav];
    [self makeUI];
}

- (void)setNav {
    self.navigationItem.title = self.model.name;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"跳页" style:UIBarButtonItemStylePlain target:self action:@selector(jumpPage)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)jumpPage{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"跳页" message:@"请输入跳转页码" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textfild = alert.textFields.firstObject;
        self.pageNum = [textfild.text integerValue];
        self.isJump = YES;
        [self.categoryView reloadData];
    }];
    [alert addAction:sureAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入页码";
        if (self.pageNum != 0) {
            textField.text = [NSString stringWithFormat:@"%ld",self.pageNum];
        }
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)makeUI {
    // 搜索UI
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, TOP_HEIGHT+10, screenW, 40)];
    [self.view addSubview:searchBar];
    searchBar.backgroundImage = [UIImage new];
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    
    // 类别UI
    self.titleArr = [[NSMutableArray alloc] init];
    SqliteTool *sqlTool = [SqliteTool sharedInstance];
    self.categoryArr = [sqlTool selectDataFromTable:@"category"
                                              where:[NSString stringWithFormat:@"website_id = %d and is_delete = 1", self.model.value]
                                              field:@"*"
                                            orderby:@""
                                              Class:[CategoryModel class]];
    for (CategoryModel *model in self.categoryArr){
        [self.titleArr addObject:model.name];
    }
    [self createCategoryView];
}

-(void)createCategoryView{
    self.categoryView = [[JXCategoryTitleView alloc] init];
    [self.view addSubview:self.categoryView];
    self.categoryView.delegate = self;
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.top.equalTo(self.view).offset((TOP_HEIGHT)+50);
    }];
    self.categoryView.titleColorGradientEnabled = YES;
    self.categoryView.titles = self.titleArr;
    self.categoryView.titleColor = [UIColor dm_colorWithLightColor:[UIColor blackColor] darkColor:[UIColor whiteColor]];
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorColor = [UIColor redColor];
    lineView.indicatorWidth = JXCategoryViewAutomaticDimension;
    self.categoryView.indicators = @[lineView];
    
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_CollectionView delegate:self];
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.categoryView.mas_bottom);
    }];
    self.categoryView.listContainer = self.listContainerView;
}

-(NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titleArr.count;
}

-(id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    ImgCategoryListViewController *VC = [[ImgCategoryListViewController alloc] init];
    VC.webModel = self.model;
    VC.pageNum = self.pageNum;
    VC.categoryModel = self.categoryArr[index];
    VC.isJump = self.isJump;
    return VC;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    // 开始搜索
    NSLog(@"搜索");
    [searchBar endEditing:YES];
    // 跳转到搜索结果页面
    SearchResultViewController *VC = [[SearchResultViewController alloc]init];
    VC.model = self.model;
    VC.keyword = searchBar.text;
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar endEditing:YES];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = @"";
}

@end
