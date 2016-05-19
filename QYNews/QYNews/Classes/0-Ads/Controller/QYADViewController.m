//
//  QYADViewController.m
//  QYNews
//
//  Created by 赵清岩 on 16/5/18.
//  Copyright © 2016年 QingYan. All rights reserved.
//

#import "QYADViewController.h"
#import <DALabeledCircularProgressView.h>
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+WebCache.h>
#import <MJExtension/MJExtension.h>


#import "ADSModel.h"
@interface QYADViewController ()
/** 底层的View*/
@property (weak, nonatomic) IBOutlet DACircularProgressView *jumpView;

/**相当于跳转按钮 */
@property (weak, nonatomic) IBOutlet UIImageView *jumpImageView;


@property (weak, nonatomic) IBOutlet UIImageView *adImageView;

/** 添加定时器*/
@property (nonatomic, weak) NSTimer *timer;

/** 模型数组*/
@property (nonatomic, strong) NSArray *arrayADSModels;

/** 判断网络状态*/
@property (nonatomic ,strong) AFNetworkReachabilityManager *reach;
//下载大图还是小图
@property (nonatomic, assign) int smallOrBig;
//广告数组中广告的个数
@property (nonatomic, assign) int count;
@end

@implementation QYADViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.adImageView.alpha = 0.6;
   
    [self setupJumpView];
    
    [self addGestureForJumpView];
    
    [self afnReachabilityStatus];
    
    [self getADSData];
 
    
 
}

//判断网路状态
-(void)afnReachabilityStatus
{
    //1.通过网络监测管理者监听状态的改变
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        /*
         AFNetworkReachabilityStatusUnknown          = -1,  未知
         AFNetworkReachabilityStatusNotReachable     = 0,   没有网络
         AFNetworkReachabilityStatusReachableViaWWAN = 1,   3G|4G
         AFNetworkReachabilityStatusReachableViaWiFi = 2,   WIFI
         */
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                
                self.smallOrBig = 0;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G&4G");
                self.smallOrBig = 1;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                break;
            default:
                break;
        }
        
    }];
    
    //2.开始监听
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)downADImage {
    NSLog(@"%s", __func__);
    ADSModel * adsModel = self.arrayADSModels[self.count -1];
//    NSLog(@"%@",adsModel);
    NSString *str = adsModel.res_url[self.smallOrBig];
    
//    NSLog(@"%@", str);
    NSURL *imageUrl = [NSURL URLWithString:str];
    
    [self.adImageView sd_setImageWithURL:imageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //初始化定时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timerChange) userInfo:nil repeats:YES];
        [self addGestureForImageView];
    }];
    
}

- (void)getADSData {

    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    NSString *urlStr = @"http://g1.163.com/madr?app=7A16FBB6&platform=ios&category=startup&location=1&timestamp=1463574395&uid=EZ3bZWDXmKdsK4nvCc35nzQ2vepP8dHuuCzCcnnzO4TdLKMVVmoLH57C5zx4xXs5CLgLiyHkYTicat5IQ3kbn6j%2F6Fcs6ZEuKwJs9MxexaRd0rQ7KzR2yeoxDZQ1p%2B%2BKj71vMujod8QkPkSNwPPWf1nOd4r%2B%2BrOYREpJGxR%2B55W7IZcTIe9oZiPO0eEqwl8XnsZy9YCyAxkmOeVaAx6rIrYSxzNyScfX0sGWMuW0E%2BI5ZT4mLJ5O10ZcPuPpkY%2BvGBjs6gQOHkdYFmKuKt7%2BKpoulJT53J%2B73v9HKoWLHVZqDV9ri5y21HOwgZBzp6ZJ";
    
    [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"%@", responseObject);
        
        [responseObject writeToFile:@"/Users/QingYan/Desktop/data.plist" atomically:YES];
        NSArray *adsArray = responseObject[@"ads"];
        
        self.arrayADSModels = [ADSModel mj_objectArrayWithKeyValuesArray:adsArray];
        
        self.count = self.arrayADSModels.count;
        NSLog(@"%@", self.arrayADSModels);
        [self downADImage];
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];

}
//为广告图片添加手势
- (void)addGestureForImageView{
    self.adImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(linkToWebView)];
    
    [self.adImageView addGestureRecognizer:tap];
    
}

- (void)linkToWebView {
    ADSModel * adsModel = self.arrayADSModels[self.count -1];
    NSString *urlStr = adsModel.action_params[@"link_url"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (!url) return;
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
        [[UIApplication sharedApplication] openURL:url];
        
        
    }

}
- (void)addGestureForJumpView{
    self.jumpImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpClick:)];
    
    [self.jumpImageView addGestureRecognizer:tap];

}
- (void)setupJumpView{

    self.jumpView.roundedCorners = NO;
    
    self.jumpView.progressTintColor = [UIColor redColor];
   
    self.jumpView.clockwiseProgress = NO;
    self.jumpView.progress = 1.0;
}

- (void)timerChange
{
    static int i = 40;
    
    self.jumpView.progress = i * 0.025;
    
    if (i <= 0) {
        [self jumpClick:nil];
    }
    i--;

}

- (void)jumpClick:(UIButton *)sender
{
    NSLog(@"%s", __func__);
}


- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;

}


@end
