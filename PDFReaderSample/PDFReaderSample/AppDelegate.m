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
    
    return YES;
}


/** 初始化人教点读SDK */
- (void)initRJReadSDK {
    
#if DEBUG
    [PRSDKManager configServerMode:true];  // 测试环境: 正测环境目前仅以AppKey来区分，此处均传true
    [PRSDKManager setAppKey:kAppKey_debug]; // 测试key
    [PRSDKManager setLogSwitch:true]; // 日志打印开
    [PRSDKManager setEvaluateEngineType:PREvaluateEngineTypeYiQi];    // 配置评测引擎类型
#else
    [PRSDKManager configServerMode:true];  // 正式环境: 正测环境目前仅以AppKey来区分，此处均传true
    [PRSDKManager setAppKey:kAppKey_release]; // 正式key
    [PRSDKManager setLogSwitch:false]; // 日志打印关
#endif
    
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
