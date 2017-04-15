//
//  ViewController.m
//  HWJBannerView
//
//  Created by wenjie hua on 2017/4/16.
//  Copyright © 2017年 JC. All rights reserved.
//

#import "ViewController.h"
#import "BannerView.h"

@interface ViewController ()<BannerViewDelegate>
//@property (weak, nonatomic) IBOutlet BannerView *vBanner;

@property (nonatomic, strong) BannerView *vBanner;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.vBanner startRolling];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.vBanner stopRolling];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.vBanner];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.vBanner.frame = CGRectMake(0, 64, self.view.frame.size.width, 150);
}


- (void)dealloc{
    [self.vBanner stopRolling];
}

#pragma mark - BannerViewDelegate Methods
- (void)bannerView:(BannerView *)bannerView tapIndex:(NSInteger)index {
    NSLog(@"点击了第%ld张",(long)index);
}

- (void)bannerView:(BannerView *)bannerView scrollShowPageIndex:(NSInteger)index {
    NSLog(@"滚动到了第%ld张",(long)index);
}

#pragma mark - setter / getter方法
- (BannerView *)vBanner {
    if (!_vBanner) {
        _vBanner = [[BannerView alloc] initWithClass:NSClassFromString(@"PageImageView")];
        [_vBanner setDatas:@[@"1",@"2",@"3",@"4",@"5",@"6"]];
        _vBanner.bannerViewDelegate = self;
    }
    return _vBanner;
}

@end
