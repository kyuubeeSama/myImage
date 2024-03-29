//
//  LocalImgViewController.m
//  myimage
//
//  Created by Galaxy on 2020/11/18.
//  Copyright © 2020 liuqingyuan. All rights reserved.
//

#import "LocalImgViewController.h"
#import "ImgCollectionViewCell.h"
#import "ImgCollectModel.h"
#import "EditBottomView.h"
@interface LocalImgViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *listArr;
@property(nonatomic, assign) BOOL is_edit;
@property(nonatomic,strong)EditBottomView *bottomView;
@property(nonatomic,strong)NSMutableArray *chooseArr;

@end

@implementation LocalImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listArr = [[NSMutableArray alloc]init];
    self.chooseArr = [[NSMutableArray alloc]init];
    self.is_edit = NO;
    [self setNav];
    [self getData];
}

//collectionview 图片列表，点击打开展示
//带编辑功能，可以多图删除

-(void)setNav{
    // TODO:编辑按钮，选中开始编辑。状态分为编辑=>完成
//    编辑状态下，collection图片右上加选中框，选中图片，图片位置做内敛
//    底部横幅，左侧添加全选按钮，右侧添加删除按钮
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editBtnClick:)];
//    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)editBtnClick:(UIBarButtonItem *)buttonItem{
    self.is_edit = !self.is_edit;
    if (self.is_edit){
        buttonItem.title = @"完成";
        self.bottomView.hidden = NO;
    } else{
        buttonItem.title = @"编辑";
        self.bottomView.hidden = YES;
    }
    [self.collectionView reloadData];
}

-(void)getData{
    self.listArr = [[[FileTool alloc]init]getLocalImage];
    [self.collectionView reloadData];
}

-(EditBottomView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[EditBottomView alloc]init];
        [self.view addSubview:_bottomView];
        _bottomView.hidden = YES;
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            make.height.mas_equalTo(40);
        }];
        WeakSelf(self)
        _bottomView.allBlock = ^{
          // 全选
            for (QYFileModel *model in weakself.listArr) {
                model.choose = YES;
            }
            [weakself.collectionView reloadData];
        };
        _bottomView.deleteBlock = ^{
          //删除选中的图片
            for (QYFileModel *model in weakself.listArr) {
                if (model.choose) {
                    [FileTool deleteLocalFileWithPath:model.filePath];
                }
            }
        };
    }
    return _bottomView;
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, screenW, screenH) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor systemBackgroundColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"ImgCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"imgCell"];
        [self.view addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.view);
        }];
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImgCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imgCell" forIndexPath:indexPath];
    QYFileModel *model = self.listArr[(NSUInteger) indexPath.row];
    [cell.contentImg sd_setImageWithURL:[NSURL fileURLWithPath:model.filePath] placeholderImage:[UIImage imageNamed:@"placeholder1"]];
    cell.chooseBtn.hidden = !self.is_edit;
    WeakSelf(cell)
    cell.chooseBlock = ^{
        model.choose = !model.choose;
        if (model.choose) {
            [weakcell.chooseBtn setImage:[UIImage systemImageNamed:@"circle.fill"] forState:UIControlStateNormal];
        }else{
            [weakcell.chooseBtn setImage:[UIImage systemImageNamed:@"circle"] forState:UIControlStateNormal];
        };
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QYFileModel *model = self.listArr[(NSUInteger) indexPath.row];
    GKPhoto *photo = [[GKPhoto alloc]init];
    photo.url = [NSURL fileURLWithPath:model.filePath];
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:@[photo] currentIndex:0];
    browser.showStyle = GKPhotoBrowserShowStyleZoom;
    [browser showFromVC:self];
    
    UIStackView *stackView = [[UIStackView alloc]init];
    stackView.spacing = 20;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    [browser.contentView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.bottom.equalTo(browser.contentView.mas_safeAreaLayoutGuideBottom).offset(-40);
    }];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stackView addArrangedSubview:saveBtn];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveBtn.bounds = CGRectMake(0, 0, 60, 30);
    [[saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:model.filePath]];
            [FileTool saveImgWithImageData:data result:^(BOOL success, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error){
                        [self alertWithTitle:@"相册保存失败"];
                    }else{
                        [self alertWithTitle:@"相册保存成功"];
                    }
                });
            }];
        });
    }];
    
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stackView addArrangedSubview:deleteBtn];
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteBtn.bounds = CGRectMake(0, 0, 60, 30);
    [[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        // 删除本地图片
        if ([FileTool deleteLocalFileWithPath:model.filePath]) {
            [self alertWithTitle:@"删除文件成功"];
            [browser dismiss];
            [self getData];
        }else{
            [self alertWithTitle:@"删除失败"];
        }
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(screenW / 3-10, screenW / 3 * 48 / 32);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
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
