//
//  DeviceListViewController.m
//  PDFReaderSample
//
//  Created by 李沛倬 on 2018/10/25.
//  Copyright © 2018 pep. All rights reserved.
//

#import "DeviceListViewController.h"

@interface DeviceListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] init];
}


// MARK: - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Device *device = self.datasource[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell"];
    cell.textLabel.text = device.dev_name;
    cell.detailTextLabel.text = device.create_time;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.datasource.count < 6) { return nil; }

    UIView *headerView = [[UIView alloc] init];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = [UIFont systemFontOfSize:MIN(18, 17 * UIScreen.mainScreen.bounds.size.width / 375)];
    textLabel.numberOfLines = 0;
    textLabel.text = @"当前账号绑定设备已达到6台的上限，您可以从下面的列表中解绑部分设备，否则您可能无法正常使用人教点读提供的服务。";

    [headerView addSubview:textLabel];

    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.centerX.equalTo(textLabel.superview);
        make.width.equalTo(textLabel.superview).offset(-30);
    }];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.datasource.count < 6 ? 0 : 80;
}

// MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    Device *device = self.datasource[indexPath.row];
    
    if ([[PRSDKManager currentDeviceUUID] isEqualToString:device.dev_id]) {
        NSLog(@"不能解绑本机！");
        return;
    }
    
    [self showAlertWithTitle:@"确定要解绑这个设备吗？" Message:device.dev_name sureButtonTitle:@"确定" cancelButtonTitle:@"取消" sureHandle:^{
        
        [self unbindDeviceWithDeviceID:device];
        
    } cancelHandle:^{
        
    }];

}


// MARK: - Action

- (void)showAlertWithTitle:(NSString *)title
                   Message:(NSString *)message
           sureButtonTitle:(NSString *)sureTitle
         cancelButtonTitle:(NSString *)cancelTitle
                sureHandle:(void (^ __nullable)(void))sureHandle
              cancelHandle:(void (^ __nullable)(void))cancelHandle {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sureHandle) { sureHandle(); }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelHandle) { cancelHandle(); }
    }];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (void)unbindDeviceWithDeviceID:(Device *)device {
    
    [PRSDKManager unbindDeviceWithUserID:kSampleUserID deviceIDs:@[device.dev_id] successBlock:^(id response) {
        
        if ([response isKindOfClass:NSDictionary.class] && [response[@"errcode"] integerValue] == 110) {
            NSLog(@"解绑成功!");
            
            [self.datasource removeObject:device];
            [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            NSLog(@"%@", response);
        }
        
    } failBlock:^(NSError *error) {
        NSLog(@"解绑失败！");
    }];
    
}




@end
