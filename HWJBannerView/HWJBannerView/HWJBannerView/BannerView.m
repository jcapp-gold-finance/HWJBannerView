//
//  BannerView.m
//  HWJBannerView
//
//  Created by wenjie hua on 2017/4/16.
//  Copyright © 2017年 JC. All rights reserved.
//

#import "BannerView.h"
@interface BannerView()<UIScrollViewDelegate>

typedef NS_ENUM(NSInteger, BannerViewDirection) {
    BannerViewDirectionUnknow,
    BannerViewDirectionLeft,
    BannerViewDirectionRight
};

#define kSelf_width self.frame.size.width
#define kSelf_height self.frame.size.height

@property (nonatomic, assign) Class PageClass;
@property (nonatomic, strong) UIView<PageViewDelegate> * vPageCurrent;
@property (nonatomic, strong) UIView<PageViewDelegate> * vPageOther;

/** 滚动方向 */
@property (nonatomic, assign) BannerViewDirection direction;

@property (nonatomic, strong) NSArray *arrData;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) BOOL hadLayout;

@end

@implementation BannerView

- (instancetype)initWithClass:(Class)aClass{
    self = [super init];
    if (self) {        
        if([aClass isSubclassOfClass:[UIView<PageViewDelegate> class]]){
            self.PageClass = aClass;
        }else{
            NSLog(@"Warning Use BannerView");
            return nil;
        }
        [self setUIs];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    if (self.PageClassName.length > 0 && [NSClassFromString(self.PageClassName) isSubclassOfClass:[UIView<PageViewDelegate> class]]) {
        self.PageClass = NSClassFromString(self.PageClassName);
        [self setUIs];
    }else{
        NSLog(@"Warning Use BannerView");
    }
}

- (void)setUIs{
    self.pagingEnabled = YES;
    self.delegate = self;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    self.contentSize = CGSizeMake(width * 3, height);
    [self addSubview:self.vPageCurrent];
    [self addSubview:self.vPageOther];
    
    self.currentPage = 0;
    self.direction = BannerViewDirectionUnknow;
    [self setContentOffset:CGPointMake(width, 0) animated:NO];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.hadLayout) {
        return;
    }
    
    self.contentSize = CGSizeMake(kSelf_width * 3, kSelf_height);
    self.vPageCurrent.frame = CGRectMake(kSelf_width, 0, kSelf_width, kSelf_height);
    self.vPageOther.frame = CGRectMake(0, 0, kSelf_width, kSelf_height);
    [self setContentOffset:CGPointMake(kSelf_width, 0) animated:NO];
    
    self.hadLayout = YES;
}

#pragma mark - Public Methods
- (void)setDatas:(NSArray *)datas{
    if (datas.count == 0) {
        NSLog(@"Warning Use BannerView");
        return;
    }
    
    [self setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:NO];
    self.arrData = datas;
    if (datas.count == 1) {
        self.scrollEnabled = NO;
    }else{
        self.scrollEnabled = YES;
    }
    
    [self updateDatas];
}
#pragma mark - Private Methods
- (void)updateDatas{
    if (self.arrData.count > 0) {
        id dataCurrent = [self.arrData objectAtIndex:self.currentPage];
        [self.vPageCurrent reloadData:dataCurrent];
        [self setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:NO];
    }
}

- (UITapGestureRecognizer *)createTapGestureRecognizer{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    return tapGestureRecognizer;
}

- (NSInteger)pageNum:(NSInteger)oldPageNum{
    if (oldPageNum < 0) {
        return self.arrData.count - 1;
    }
    if (oldPageNum > self.arrData.count - 1) {
        return 0;
    }
    return oldPageNum;
}

- (void)doRolling{
    [self setContentOffset:CGPointMake(self.bounds.size.width * 2, 0) animated:YES];
}

#pragma mark - Event Methods
- (void)currentPageTapAction{
    NSInteger currentPage = self.currentPage;
    if (self.bannerViewDelegate && [self.bannerViewDelegate respondsToSelector:@selector(bannerView:tapIndex:)]) {
        [self.bannerViewDelegate bannerView:self tapIndex:currentPage];
    }
}

#pragma mark - Timer Methods
-(void)startRolling {
    [self.timer setFireDate:[NSDate dateWithTimeInterval:self.rollingInterval sinceDate:[NSDate date]]];
}

-(void)stopRolling {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)pauseRolling {
    [self.timer setFireDate:[NSDate distantFuture]];
}

-(void)resumeRolling {
    [self.timer setFireDate:[NSDate dateWithTimeInterval:self.rollingInterval sinceDate:[NSDate date]]];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self pauseRolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self resumeRolling];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /** 判断一下此时是向右滚动还是向左滚动，根据设想，停止时的scrollView显示的内容永远是中间，那么scrollView.contentOffset.x 应该永远是 scrollView.frame.size.width，这里就是kSelf_width。那么在动的时候通过scrollView.contentOffset.x 就可以知道是向哪个方向滚动
     
     性能优化：1. 该方法在滚动过程中重复调用，向左向右滑动其实在改变时赋值即可，后续无需判断？  ——>利用self.scrollDirection进方向判断来优化操作次数
     2._otherImageView 反复调用 setFrame 和 setImage 方法，是否会有损性能？ ——>利用self.scrollDirection进方向判断来优化操作次数
     */
    if (scrollView.contentOffset.x > kSelf_width) {
        
        if (self.direction == BannerViewDirectionUnknow || self.direction == BannerViewDirectionLeft) {
            NSLog(@"向右滚动");
            
            // 向右滚动则要把另一张图片放在右边
            self.vPageOther.frame = CGRectMake(self.vPageCurrent.frame.origin.x + kSelf_width, 0, kSelf_width, kSelf_height);
            
            // 同时给这个imageView上图片
            if (self.currentPage == self.arrData.count - 1) {
                [self.vPageOther reloadData:self.arrData[0]];
            } else {
                [self.vPageOther reloadData:self.arrData[self.currentPage + 1]];
            }
            
            self.direction = BannerViewDirectionRight;
        }
    } else if (scrollView.contentOffset.x < kSelf_width) {
        
        if (self.direction == BannerViewDirectionUnknow || self.direction == BannerViewDirectionRight) {
            NSLog(@"向左滚动");
            
            // 同理向左
            self.vPageOther.frame = CGRectMake(self.vPageCurrent.frame.origin.x - kSelf_width, 0, kSelf_width, kSelf_height);
            if (self.currentPage == 0) {
                [self.vPageOther reloadData:self.arrData[self.arrData.count - 1]];
            } else {
                [self.vPageOther reloadData:self.arrData[self.currentPage - 1]];
            }
            
            self.direction = BannerViewDirectionLeft;
        }
    } else {
        self.direction = BannerViewDirectionUnknow;
    }
    
    // 重置图像，就是把otherImageView拉到中间全部显示的时候，赶紧换currentImageView来显示，即把scrollView.contentOffset.x 又设置到原来的位置，那么_currentImageView又能够全部显示了，但是_currentImageView显示的上一张/下一张的图片，需要替换成当前图片。进入该判断次数不多
    if (scrollView.contentOffset.x >= kSelf_width * 2) {
        NSLog(@"向右越界");
        if (self.currentPage == self.arrData.count - 1) {
            self.currentPage = 0;
        } else {
            self.currentPage++;
        }
        [self.vPageCurrent reloadData:self.arrData[self.currentPage]];
        scrollView.contentOffset = CGPointMake(kSelf_width, 0);
        
    } else if (scrollView.contentOffset.x <= 0) {
        NSLog(@"向左越界");
        if (self.currentPage == 0) {
            self.currentPage = self.arrData.count - 1;
        } else {
            self.currentPage--;
        }
        [self.vPageCurrent reloadData:self.arrData[self.currentPage]];
        scrollView.contentOffset = CGPointMake(kSelf_width, 0);
        
    }
}

#pragma mark - setter and getter Methods
- (UIView<PageViewDelegate> *)vPageOther {
    if (_vPageOther == nil) {
        _vPageOther = [[self.PageClass alloc] init];
    }
    return _vPageOther;
}

- (UIView<PageViewDelegate> *)vPageCurrent{
    if (_vPageCurrent == nil) {
        _vPageCurrent = [[self.PageClass alloc] init];
        UITapGestureRecognizer *tapGestureRecognizer = [self createTapGestureRecognizer];
        [tapGestureRecognizer addTarget:self action:@selector(currentPageTapAction)];
        [_vPageCurrent addGestureRecognizer:tapGestureRecognizer];
        _vPageCurrent.userInteractionEnabled = YES;
    }
    return _vPageCurrent;
}


- (void)setCurrentPage:(NSInteger)currentPage{
    NSLog(@"%ld--%ld",(long)currentPage,(long)_currentPage);
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        if (self.bannerViewDelegate && [self.bannerViewDelegate respondsToSelector:@selector(bannerView:scrollShowPageIndex:)]) {
            [self.bannerViewDelegate bannerView:self scrollShowPageIndex:currentPage];
        }
    }
}

- (CGFloat)rollingInterval{
    if (_rollingInterval == 0) {
        return 3;
    }
    return _rollingInterval;
}

- (NSTimer *)timer{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.rollingInterval target:self selector:@selector(doRolling) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}
@end
