//
//  LocalPhotoViewController.m
//  ZSTest
//
//  Created by zhoushuai on 16/3/29.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "LocalPhotoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PhotoViewCell.h"

@interface LocalPhotoViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)UIView *bottomView;

//存放ALAsset
@property(nonatomic,strong)NSMutableArray *dataSource;
//存放photo
@property(nonatomic,strong)NSMutableArray *selectedPhotos;
//存放photo路径
@property(nonatomic,strong)NSMutableArray *selectedPhotoUrls;


//必须持有ALAssetsLibrary
@property(nonatomic,strong)ALAssetsLibrary *alassetsLibrary;

//展示图片的大小
@property(nonatomic,assign)CGFloat imgWidth;
//小于9.0的系统使用普通缩略图
@property(nonatomic,assign)BOOL needThumbnail;

@end

@implementation LocalPhotoViewController

#pragma mark - 视图生命周期及控件加载
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //判断显示那种缩略图
    //低于9.0系统的使用普通缩略图
    CGFloat version = [[UIDevice currentDevice].systemVersion floatValue];
    if (version <9.0) {
        _needThumbnail = YES;
    }else{
        _needThumbnail = NO;
    }
    
    //最大可以选中的个数,这里是测试值
    if(!(_maxSelectCount >0)){
        //默认选10张
        _maxSelectCount = 10;
    }
    
    //添加视图：集合视图和底部选中信息视图
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    
    //从本地加载图片资源
    [self getLoaclPhotos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 获取数据
- (void)getLoaclPhotos{
    [self.dataSource removeAllObjects];
    //遍历所有文件夹
    [self.alassetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            //可以通过ValueProperty获取相册Group的信息
            //[self printGourpInfo:group];
            //通过文件夹来获取所有的ALAsset类型的图片或者视频
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    //可以通过ValueProperty获取相册ALAsset的信息
                    //[self printALAssetInfo:result];
                    //-----得到ALAsset
                    [self.dataSource addObject:result];
                }
            }];
         }
        [self.collectionView reloadData];
    } failureBlock:^(NSError *error) {
        //
    }];
    
}


//从本地图片对象中获取图片，用于显示
- (UIImage *)getImageFromALAsset:(ALAsset *)alasset{
    CGImageRef imgRef ;
    if (_needThumbnail) {
        imgRef = alasset.thumbnail;
    }else{
        imgRef = alasset.aspectRatioThumbnail;
    }
    return [UIImage imageWithCGImage:imgRef];
}



#pragma mark - UICollectionViewDataSource
//返回单元格个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"PhotoViewCellID";
    PhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    ALAsset *alasset = _dataSource[indexPath.row];
    
    if (indexPath.row <self.dataSource.count) {
        cell.image  = [self getImageFromALAsset:alasset];
    }
    //判别当前cell上图片是否被选中
    NSString *url = [alasset valueForProperty:ALAssetPropertyAssetURL];
    BOOL imgExist = ([self.selectedPhotoUrls indexOfObject:url] == NSNotFound);
    cell.selectedImgView.hidden = imgExist;
    return cell;
}


//调整间距：针对于collectionView的边距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{

    return UIEdgeInsetsMake(5,5,5, 5);
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoViewCell *cell = (PhotoViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.selectedImgView.hidden) {
        //图片没有被选中
        if(self.existCount +self.selectedPhotos.count >_maxSelectCount-1){
            //选择图片超过上限
            NSLog(@"图片超过上限");
            return;
        }
        cell.selectedImgView.hidden = NO;
        ALAsset *asset=self.dataSource[indexPath.row];
        //保存选中的图片和地址
        [self.selectedPhotos addObject:asset];
        [self.selectedPhotoUrls addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
        
    }else{
        //取消图片的被选中状态
        cell.selectedImgView.hidden = YES;
        ALAsset *asset=self.dataSource[indexPath.row];
        NSString *url=[asset valueForProperty:ALAssetPropertyAssetURL];
        //移除ALAsset
        for (ALAsset *a in self.dataSource) {
            NSString *tempUrl=[a valueForProperty:ALAssetPropertyAssetURL];
            if([url isEqual:tempUrl])
            {
                [self.selectedPhotos removeObject:a];
                break;
            }
         }
        //移除图片路径
        [self.selectedPhotoUrls removeObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
    }
    
    //重置选择信息
    UILabel *infoLabel = [_bottomView viewWithTag:100];
    if(self.selectedPhotos.count==0)
    {
        infoLabel.text=@"请选择照片";
    }
    else{
        infoLabel.text=[NSString stringWithFormat:@"已经选择%lu张照片",self.selectedPhotoUrls.count];
    }
}



#pragma mark - 事件点击
//确认选择图片，回到原来界面
- (void)sureBtnClick:(UIButton *)btn{
    //代码对象获取选中的图片
    if ([self.delegate respondsToSelector:@selector(getSelectedLocalPhotos:)]) {
        [self.delegate getSelectedLocalPhotos:self.selectedPhotos];
    }
    NSLog(@"%@",self.selectedPhotos);
    //返回界面
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - 辅助方法
- (void)printGourpInfo:(ALAssetsGroup *)group{
    /*
     ALAssetsGroupPropertyName:关键字对应相册名字的property
     ALAssetsGroupPropertyType:关键字对应相册类型的property
     ALAssetsGroupPropertyPersistentID：关键字对应相册存储id的property
     ALAssetsGroupPropertyURL：关键字对应相册存储位置地址的property
     */
    NSLog(@"相册分割线---------------");
    NSLog(@"ALAssetsGroupPropertyName:%@",[group valueForProperty:ALAssetsGroupPropertyName]);
    NSLog(@"ALAssetsGroupPropertyType:%@",[group valueForProperty:ALAssetsGroupPropertyType]);
    NSLog(@"ALAssetsGroupPropertyType:%@",[group valueForProperty:ALAssetsGroupPropertyName]);
    NSLog(@"ALAssetsGroupPropertyPersistentID:%@",[group valueForProperty:ALAssetsGroupPropertyPersistentID]);
    NSLog(@"ALAssetsGroupPropertyURL:%@",[group valueForProperty:ALAssetsGroupPropertyURL]);
}

- (void)printALAssetInfo:(ALAsset *)result{
    /*
     ALAssetPropertyLocation:对应asset的地理位置信息
     ALAssetPropertyDuration:type为视频的话，对应视频的时长
     ALAssetPropertyDate:对应asset的创建时间
     ALAssetPropertyRepresentations:对应asset的描述信息
     ALAssetPropertyAssetURL:对应asset的url路径- ......
     */
    NSLog(@"ALAssetPropertyLocation:%@",[result valueForProperty:ALAssetPropertyLocation]);
    //如果资源是视频，查看视频的时长
    NSLog(@"ALAssetPropertyDuration:%@",[result valueForProperty:ALAssetPropertyDuration]);
    //查看资源的方向，图片的旋转方向
    NSLog(@"ALAssetPropertyOrientation:%@",[result valueForProperty:ALAssetPropertyOrientation]);
    //查看资源的创建时间
    NSLog(@"ALAssetPropertyDate:%@",[result valueForProperty:ALAssetPropertyDate]);
    //查看资源的描述信息
    NSLog(@"ALAssetPropertyRepresentations:%@",[result valueForProperty:ALAssetPropertyRepresentations]);
    
    NSLog(@"ALAssetPropertyURLs:%@",[result valueForProperty:ALAssetPropertyURLs]);
    //查看资源的url路径
    NSLog(@"ALAssetPropertyAssetURL:%@",[result valueForProperty:ALAssetPropertyAssetURL]);
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
        _imgWidth = (kDeviceWidth - 5 *4)/3;
        flowLayout.itemSize = CGSizeMake(_imgWidth, _imgWidth);
        //创建集合视图
        CGRect collectionViewRect = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight - 64 - 50);
        _collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor  = [UIColor whiteColor];
        
        //注册单元格
        [_collectionView registerClass:[PhotoViewCell class] forCellWithReuseIdentifier:@"PhotoViewCellID"];
    }
    return _collectionView;
}

//底部视图
- (UIView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(5, kDeviceHeight - 64 - 50, kDeviceWidth -10, 50)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        //选择图片的提示信息
        UILabel *chooInfoLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth -10 -80, 50)];
        chooInfoLable.textAlignment = NSTextAlignmentLeft;
        chooInfoLable.tag = 100;
        chooInfoLable.text = @"请选择图片";
        [_bottomView addSubview:chooInfoLable];
        
        //确定按钮，返回原来界面
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kDeviceWidth -10 -80, 0, 80, 50)];
        [btn setTitle:@"确认" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btn addTarget: self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btn];
    }
    return _bottomView;
}


//存放ALAsset的数组
- (NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}


- (NSMutableArray *)selectedPhotos{
    if (_selectedPhotos == nil) {
        _selectedPhotos = [NSMutableArray array];
    }
    return _selectedPhotos;
}
//被选中图片的地址
- (NSMutableArray *)selectedPhotoUrls{
    if (_selectedPhotoUrls == nil) {
        _selectedPhotoUrls = [NSMutableArray array];
    }
    return _selectedPhotoUrls;
}

//ALAssetsLibrary
- (ALAssetsLibrary *)alassetsLibrary{
    //ALAssetsLibrary库是iOS4之后可用的，但从最新的官方文档来看，iOS9之后这个库被废弃了，
    //当然有些功能还是可以用的，但是官方建议使用他们提供的Photos Framework
    if(_alassetsLibrary == nil){
        _alassetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    return _alassetsLibrary;
}


@end
