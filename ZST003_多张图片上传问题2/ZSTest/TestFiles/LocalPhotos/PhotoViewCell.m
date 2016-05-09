//
//  PhotoViewCell.m
//  ZSTest
//
//  Created by zhoushuai on 16/3/29.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "PhotoViewCell.h"

@implementation PhotoViewCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //
        [self _initViews];
        
    }
    return self;
}

//初始化视图组件
- (void)_initViews{
    _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imgView.backgroundColor = [UIColor orangeColor];
    //按照比例铺满
    [_imgView  setContentMode:UIViewContentModeScaleAspectFill];
    //多余部分裁剪掉
    _imgView.layer.masksToBounds = YES;

    [self.contentView addSubview:_imgView];
    
    //被选中
    _selectedImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    _selectedImgView.image = [UIImage imageNamed:@"selectedImg"];
    _selectedImgView.hidden = YES;
    [self.contentView addSubview:_selectedImgView];
    
    
}


//数据源

- (void)setImage:(UIImage *)image{
    if (_image != image) {
        _image = image;
        [self setNeedsLayout];
    }
}

//重新布局
- (void)layoutSubviews{
    [super layoutSubviews];
    _imgView.image = _image;
}

@end
