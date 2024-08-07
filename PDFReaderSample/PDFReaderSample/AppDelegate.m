//
//  AppDelegate.m
//  PDFReaderSample
//
//  Created by 李沛倬 on 2018/3/5.
//  Copyright © 2018年 pep. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self networkStatusMonitor];    // 监控网络变化
    [self initRJReadSDK];
    
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        [appearance setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.redColor,
        NSFontAttributeName:[UIFont systemFontOfSize:20]}];
        appearance.backgroundColor = UIColor.grayColor;
        appearance.shadowColor = UIColor.clearColor;

        [UINavigationBar appearance].scrollEdgeAppearance = appearance;

        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].tintColor = UIColor.greenColor;
    }
    return YES;
}


/** 初始化人教点读SDK */
- (void)initRJReadSDK {
    
    [PRSDKManager configServerMode:YES];
    [PRSDKManager setAppKey:kAppKey_debug]; // 测试key
    [PRSDKManager setLogSwitch:YES]; // 日志打印开
    [PRSDKManager setEvaluateEngineType:PREvaluateEngineTypeXunFei];    // 配置评测引擎类型
    
    // 使用其他测评引擎用到
//    [PRSDKManager setEvaluateEngineType:PREvaluateEngineTypeOther];
//    [ThirdSpeechEvaluatorTool shareInstance];// 初始化测评引擎
  
}


- (void)applicationWillResignActive:(UIApplication *)application {

}


- (void)applicationDidEnterBackground:(UIApplication *)application {

}


- (void)applicationWillEnterForeground:(UIApplication *)application {

}


- (void)applicationDidBecomeActive:(UIApplication *)application {

}


- (void)applicationWillTerminate:(UIApplication *)application {

}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return self.window.rootViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void)networkStatusMonitor {
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSString *message = @"";
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusNotReachable: {
                message = @"网络连接中断";
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                message = @"正在使用WiFi网络";
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                message = @"正在使用移动网络";
                break;
            }
        }
        
        NSLog(@"%@", message);
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
}


@end
