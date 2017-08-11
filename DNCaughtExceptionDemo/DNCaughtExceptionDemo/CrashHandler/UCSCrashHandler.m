//
//  UCSCrashHandler.m
//  DNCaughtExceptionDemo
//
//  Created by ucsmy on 2017/7/20.
//  Copyright © 2017年 ucsmy. All rights reserved.
//

#import "UCSCrashHandler.h"
#import <UIKit/UIKit.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString *const UncaughtExceptionHandlerSignalExceptionName=@"UncaughtExceptionHandlerSignalExceptionName";
NSString *const UncaughtExceptionHandlerSignalKey=@"UncaughtExceptionHandlerSignalKey";
NSString *const UncaughtExceptionHandlerAddressesKey=@"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t exceptionMaximum = 10;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 10;//指明报告多少条调用堆栈信息
@interface UCSCrashHandler ()<UIAlertViewDelegate>
// 获取堆栈信息，返回符号化之后的数组
+(NSArray*)backtrace;

// 处理异常,包括未被捕获的以及信号异常
-(void)handleException:(NSException*)exception;

@end
@implementation UCSCrashHandler

+ (NSArray*)backtrace
{
    void *callStack[128];//堆栈方法数组
    /**
     该函数用于获取当前线程的调用堆栈，获取的信息将被存储在buffer中，它是一个指针列表。参数size用来指定buffer中可以保存多少个指针元素。函数返回值是实际获取的指针个数，最大不超过size的大小。
     */
    int frames=backtrace(callStack, 128);
    
    /**
     backtrace_symbols将从backtrace函数中获取的信息转化为字符串数组。参数buffer应该是从backtrace函数获取的指针数组，size是该数组中的元素个数（backtrace的返回值）。函数返回值是一个指向字符串数组的指针,它的大小同buffer相同.每个字符串包含了一个相对于buffer中对应元素的可打印信息.它包括函数名，函数的偏移地址,和实际的返回地址
     */
    char **strs = backtrace_symbols(callStack, frames);
    
    NSMutableArray *systembolsBackTrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i<UncaughtExceptionHandlerReportAddressCount; i++) {
        [systembolsBackTrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return systembolsBackTrace;
}

- (void)handleException:(NSException *)exception
{
    NSString *message=[NSString stringWithFormat:@"异常报告:\n异常名称：%@\n异常原因：%@\n其他信息：%@\n",
                       [exception name],
                       [exception reason],
                       [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"抱歉，程序出现了异常" message:message delegate:self cancelButtonTitle:@"退出" otherButtonTitles:nil, nil];
    alert.delegate = self;
    [alert show];
    ///////////////
    CFRunLoopRef runLoop=CFRunLoopGetCurrent();
    CFArrayRef allModes=CFRunLoopCopyAllModes(runLoop);
    NSArray *arr=(__bridge NSArray *)allModes;
    while (!self.dismissed) {
        // 当接收到异常处理消息的时候，让程序开始runloop，防止程序死亡。
        for (NSString *mode in arr) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    CFRelease(allModes);
    // 当点击弹出视图的Cancel按钮哦,isDimissed ＝ YES,上边的循环跳出
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL , SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE , SIG_DFL);
    signal(SIGBUS , SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    signal(SIGHUP , SIG_DFL);
    signal(SIGINT , SIG_DFL);
    signal(SIGQUIT, SIG_DFL);
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }
    else
    {
        [exception raise];
    }
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    if (anIndex == 0)
    {
        self.dismissed = YES;
    }
}

@end

void HandleUnCaughtException(NSException*exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount>exceptionMaximum) return;
    NSArray *callStack = [UCSCrashHandler backtrace];
    NSMutableDictionary *userinfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userinfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    UCSCrashHandler *unCaughtExceptionHandler=[[UCSCrashHandler alloc] init];
    
    NSException *uncaughtException=[NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userinfo];
    
    [unCaughtExceptionHandler performSelectorOnMainThread:@selector(handleException:) withObject:uncaughtException waitUntilDone:YES];
    
}

void HandleSingal(int singal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount>exceptionMaximum) return;
    NSMutableDictionary *userinfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:singal] forKey:UncaughtExceptionHandlerSignalKey];
    NSArray *callBack = [UCSCrashHandler backtrace];
    [userinfo setObject:callBack forKey:UncaughtExceptionHandlerAddressesKey];
    
    UCSCrashHandler *unCaughtExceptionHandler=[[UCSCrashHandler alloc] init];
    
    NSException *singalException=[NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName reason:[NSString stringWithFormat:@"singal %d was raised",singal] userInfo:userinfo];
    
    [unCaughtExceptionHandler performSelectorOnMainThread:@selector(handleException:) withObject:singalException waitUntilDone:YES];
}

void InstallUnCaughtExceptionHandler(void)
{
    NSSetUncaughtExceptionHandler(&HandleUnCaughtException); //设置未捕获的异常处理

    // 设置信号类型的异常处理
    signal(SIGABRT, HandleSingal);
    signal(SIGILL, HandleSingal);
    signal(SIGSEGV, HandleSingal);
    signal(SIGFPE, HandleSingal);
    signal(SIGBUS, HandleSingal);
    signal(SIGPIPE, HandleSingal);
    signal(SIGHUP, HandleSingal);
    signal(SIGINT, HandleSingal);
    signal(SIGQUIT, HandleSingal);
}


