//
//  BannerView.h
//  HWJBannerView
//
//  Created by wenjie hua on 2017/4/16.
//  Copyright © 2017年 JC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewDelegate.h"

@class BannerView;

@protocol BannerViewDelegate <NSObject>

@optional
- (void)bannerView:(BannerView *)bannerView tapIndex:(NSInteger)index;
- (void)bannerView:(BannerView *)bannerView scrollShowPageIndex:(NSInteger)index;

@end

IB_DESIGNABLE

@interface BannerView : UIScrollView
@property (nonatomic, assign) CGFloat rollingInterval;
@property (nonatomic, copy) IBInspectable NSString *PageClassName;
@property (nonatomic, weak) id<BannerViewDelegate> bannerViewDelegate;

/**
 唯一支持初始化方法
 */
- (instancetype)initWithClass:(Class<PageViewDelegate>)aClass;

- (void)setDatas:(NSArray *)datas;

- (void)startRolling;
- (void)stopRolling;

@end
