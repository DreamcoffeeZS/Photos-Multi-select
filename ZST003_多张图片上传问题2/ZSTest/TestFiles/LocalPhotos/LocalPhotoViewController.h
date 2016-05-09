//
//  LocalPhotoViewController.h
//  ZSTest
//
//  Created by zhoushuai on 16/3/29.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import <UIKit/UIKit.h>

//代理方法：其他界面实现该方法，可以获取到选中的图片
@protocol ChooseLoaclPhotos <NSObject>

- (void)getSelectedLocalPhotos:(NSArray *)array;

@end



@interface LocalPhotoViewController : UIViewController
//从上个界面进入时，已经选中的图片
@property(nonatomic,assign)NSInteger existCount;

//最大可以选择的图片
@property(nonatomic,assign)NSInteger maxSelectCount;

@property(nonatomic,assign)id<ChooseLoaclPhotos> delegate;

@end
