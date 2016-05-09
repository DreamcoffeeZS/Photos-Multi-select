//
//  TestViewController.h
//  Test
//
//  Created by zhoushuai on 16/3/7.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)UICollectionView *collectionView;
//展示图片的大小
@property(nonatomic,assign)CGFloat imgWidth;



//最多和最少选择张数
@property(nonatomic,assign)NSInteger maxSelectCount;
@property(nonatomic,assign)NSInteger minSelectCount;


@end
