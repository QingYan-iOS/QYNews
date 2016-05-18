//
//  QYADViewController.m
//  QYNews
//
//  Created by 赵清岩 on 16/5/18.
//  Copyright © 2016年 QingYan. All rights reserved.
//

#import "QYADViewController.h"
#import <DALabeledCircularProgressView.h>
@interface QYADViewController ()
/** 底层的View*/
@property (weak, nonatomic) IBOutlet DACircularProgressView *jumpView;

/**相当于跳转按钮 */
@property (weak, nonatomic) IBOutlet UIImageView *jumpImageView;


/** 添加定时器*/
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation QYADViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupJumpView];
    
    [self addGesture];
    
    //初始化定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerChange) userInfo:nil repeats:YES];
    
    
 
}


- (void)addGesture{
    self.jumpImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpClick:)];
    
    [self.jumpImageView addGestureRecognizer:tap];

}
- (void)setupJumpView{

    self.jumpView.roundedCorners = NO;
    
    self.jumpView.progressTintColor = [UIColor redColor];
    
    self.jumpView.progress = 1.0;
}

- (void)timerChange
{
    static int i = 400;
    
    self.jumpView.progress = i * 0.0025;
    
    if (i <= 0) {
        [self jumpClick:nil];
    }
    i--;

}

- (void)jumpClick:(UIButton *)sender
{
    NSLog(@"%s", __func__);
}





@end
