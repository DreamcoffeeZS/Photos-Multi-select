//
//  TestViewController.m
//  Test
//
//  Created by zhoushuai on 16/3/7.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "TestViewController.h"
#import "LocalPhotoViewController.h"
#import "PhotoViewCell.h"
#import "PhotoModel.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface TestViewController ()<ChooseLoaclPhotos>

@property(nonatomic,strong)NSMutableArray *localPhotos;
@property(nonatomic,strong)UIView *headView;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"选择多张图片";
    self.navigationController.navigationBar.translucent = NO;
    
    [self.view addSubview:self.collectionView];
    
    
    //_maxSelectCount = 20;
    //_minSelectCount = 5;
    
}




#pragma mark - collection代理方法
//返回单元格个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.localPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"PhotoViewCellID";
    PhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    PhotoModel *model = _localPhotos[indexPath.row];
    cell.selectedImgView.hidden = YES;
    cell.image = model.image;
     return cell;
}


//调整间距：针对于collectionView的边距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(5,5,5, 5);
}

//设置顶部的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
     return CGSizeMake(kDeviceWidth, 60);
}

//返回头视图，类似headerView和FootView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headViewID" forIndexPath:indexPath];
    [reusableView addSubview:self.headView];
    return reusableView;
}


#pragma mark - 实现代理获取图片

- (void)getSelectedLocalPhotos:(NSArray *)array{
    if (array ||array.count >0) {
        for (int i = 0; i<array.count; i++) {
        
            ALAsset *alasset = array[i];
            CGImageRef posterImageRef= [[alasset defaultRepresentation] fullScreenImage];
            UIImage *image = [UIImage imageWithCGImage:posterImageRef];
            //图片对象
            PhotoModel *photoModel = [[PhotoModel alloc] init];
            photoModel.image = image;
            photoModel.imgLocalUrl = [alasset valueForProperty:ALAssetPropertyAssetURL];
            //加入本地图片数组
            [self.localPhotos addObject:photoModel];
        }
        [self.collectionView reloadData];
    }
}



#pragma mark - 时间处理
//进入图片多选
- (void)chooseLocalPhotosBtnClick:(id)sender {
    LocalPhotoViewController *localPhotoVC = [[LocalPhotoViewController alloc] init];
    localPhotoVC.delegate = self;
    //已经选中张数
    localPhotoVC.existCount = self.localPhotos.count;
    //最多能选中张数
    localPhotoVC.maxSelectCount = 10;
    [self.navigationController pushViewController:localPhotoVC animated:YES];
}




#pragma mark - set/get方法
//集合视图
- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        //设置间距
        flowLayout.minimumInteritemSpacing = 5;
        flowLayout.minimumLineSpacing = 5;
        //每个单元格的大小
        _imgWidth = (kDeviceWidth - 5 *5)/4;
        flowLayout.itemSize = CGSizeMake(_imgWidth, _imgWidth);
        //创建集合视图
        CGRect rect = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight);
        CGRect collectionViewRect = rect;
        _collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor  = [UIColor whiteColor];
        
        //注册单元格
        [_collectionView registerClass:[PhotoViewCell class] forCellWithReuseIdentifier:@"PhotoViewCellID"];
        //注册头视图
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headViewID"];
        
    }
    return _collectionView;
}


//集合视图头视图
- (UIView *)headView{
    if (_headView == nil) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, 60)];
        UIButton *chooseBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 5, kDeviceWidth - 30*2, 50)];
        
        [chooseBtn setTitle:@"选择图片" forState:UIControlStateNormal];
        [chooseBtn addTarget:self action:@selector(chooseLocalPhotosBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        chooseBtn.layer.cornerRadius = 5;
        chooseBtn.layer.masksToBounds = YES;
        chooseBtn.backgroundColor = [UIColor purpleColor];
        [_headView addSubview:chooseBtn];
    }
    return _headView;
}


//本地选中图片
- (NSMutableArray *)localPhotos{
    if (_localPhotos == nil) {
        _localPhotos = [NSMutableArray array];
    }
    return _localPhotos;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
