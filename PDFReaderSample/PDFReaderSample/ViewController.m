//
//  ViewController.m
//  PDFReaderSample
//
//  Created by 李沛倬 on 2018/3/5.
//  Copyright © 2018年 pep. All rights reserved.
//

#import "ViewController.h"
#import "DeviceListViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSMutableArray<Device *> *deviceList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self userAuth];    // 用户鉴权
    
//    [self createAppMonitorView];
    
//    NSArray<NSString *> *ary = @[@"0", @"1", @"2", @"3", @"4", @"5"];
//    NSArray *result = [self permutation:ary];
//
//    NSLog(@"\n %@", [result componentsJoinedByString:@", "]);
}



- (void)userAuth {
    [self.indicatorView startAnimating];
    
    [PRSDKManager userAuthWithUserID:kSampleUserID successBlock:^(id response) {
        [self.indicatorView stopAnimating];
        
        if ([response isKindOfClass:NSDictionary.class] && [response[@"errcode"] intValue] == 110) {
            
            NSArray<Device *> *devices = [NSArray yy_modelArrayWithClass:Device.class json:response[@"devlist"]];
            self.deviceList = devices.mutableCopy;
            
            if (devices.count >= 6) {   // 已绑定设备达到上限，自动push解绑设备页
                [self pushIntoDeviceListViewController];
            }
            
        } else {
            
            NSLog(@"%@", response);
        }
        
    } failBlock:^(NSError *error) {
        [self.indicatorView stopAnimating];

        NSLog(@"%@", error);
    }];
}
- (IBAction)clickBtn:(id)sender {
    NSArray<PRBookGradeModel *> *arr =  [PRSDKManager getBooklist];
    
    PRBookModel *model=  [PRSDKManager getBookItemWithBookID:@"1311001201192"];
    NSLog(@"");
}


// MARK: - Action

- (void)pushIntoDeviceListViewController {
    
    DeviceListViewController *deviceListVC = (DeviceListViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle] instantiateViewControllerWithIdentifier:@"DeviceListVC"];
    deviceListVC.datasource = self.deviceList;
    
    [self.navigationController pushViewController:deviceListVC animated:true];
}



// MARK: - Segue


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    return !(self.deviceList.count == 0);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"DeviceList"] && [segue.destinationViewController isKindOfClass:DeviceListViewController.class]) {
        DeviceListViewController *deviceListVC = (DeviceListViewController *)segue.destinationViewController;
        
        deviceListVC.datasource = self.deviceList;
    }
    
}



// MARK: - UI

- (void)createAppMonitorView {
    
#ifdef DEBUG
    RKAPPMonitorView *monitorView = [[RKAPPMonitorView alloc] initWithOrigin:CGPointMake(10, 100)];
    [[UIApplication sharedApplication].delegate.window addSubview:monitorView];
#else
#endif
    
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.color = UIColor.darkGrayColor;
        
        [self.view addSubview:indicatorView];
        
        [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(indicatorView.superview);
            make.width.height.equalTo(@60);
        }];
        
        _indicatorView = indicatorView;
    }
    
    return _indicatorView;
}


// MARK: - Status Bar

- (BOOL)prefersStatusBarHidden {
    return false;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}



// MARK: - Test Method

/** 求一个数组的排列 */
- (NSArray<NSString *> *)permutation:(NSArray<NSString *> *)ary {
    
    NSInteger sum = 1;
    for (NSInteger i = ary.count; i > 1; i--) { sum *= i; }
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:sum];
    
    
    for (NSString *header in ary) {
        if (ary.count == 1) { return ary; }
        
        NSMutableArray *mAry = ary.mutableCopy;
        [mAry removeObject:header];
        
        NSArray<NSString *> *temp = [self permutation:mAry];
        
        for (NSString *element in temp) {
            NSString *string = [NSString stringWithFormat:@"%@%@", header, element];
            
            [result addObject:string];
        }
    }
    
    return result;
}


@end










