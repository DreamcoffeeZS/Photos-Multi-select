//
//  PhotoViewCell.h
//  ZSTest
//
//  Created by zhoushuai on 16/3/29.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewCell : UICollectionViewCell

//需要显示的图片
@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)UIImage *image;

//显示被选中
@property(nonatomic,strong)UIImageView *selectedImgView;

@end
