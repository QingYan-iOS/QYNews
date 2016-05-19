//
//  ADSModel.h
//  QYNews
//
//  Created by 赵清岩 on 16/5/19.
//  Copyright © 2016年 QingYan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADSModel : NSObject

/** 点击广告图片跳转的URL*/
@property (nonatomic, strong) NSDictionary *action_params;

/** 广告图片数组*/
@property (nonatomic, strong) NSArray *res_url;


@end
