//
//  PageImageView.m
//  HWJBannerView
//
//  Created by wenjie hua on 2017/4/16.
//  Copyright © 2017年 JC. All rights reserved.
//

#import "PageImageView.h"

@implementation PageImageView
#pragma mark - PageViewDelegateMethod
- (void)reloadData:(id)data{
    if ([data isKindOfClass:[NSString class]]) {
        [self setImage:[UIImage imageNamed:data]];
    }
}
@end
