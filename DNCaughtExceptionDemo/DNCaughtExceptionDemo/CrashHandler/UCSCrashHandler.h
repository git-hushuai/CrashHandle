//
//  UCSCrashHandler.h
//  DNCaughtExceptionDemo
//
//  Created by ucsmy on 2017/7/20.
//  Copyright © 2017年 ucsmy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCSCrashHandler : NSObject
@property (nonatomic ,assign) BOOL dismissed;
@end


/**
 处理未捕获的异常

 @param exception 捕获的异常
 */
void HandleUnCaughtException(NSException *exception);

/**
 处理信号类型的异常

 @param singal 信号类型值
 */
void HandleSingal(int singal);

/**
 注册两种类型的Crash的处理函数
 */
void InstallUnCaughtExceptionHandler(void);

