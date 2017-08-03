//
//  TestViewViewController.h
//  DNCaughtExceptionDemo
//
//  Created by ucsmy on 2017/8/3.
//  Copyright © 2017年 ucsmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TestVCDelegate <NSObject>
@optional
- (void)testMethod;
@end

@interface TestViewViewController : UIViewController
@property (nonatomic , strong) id<TestVCDelegate> delegate;
@end
