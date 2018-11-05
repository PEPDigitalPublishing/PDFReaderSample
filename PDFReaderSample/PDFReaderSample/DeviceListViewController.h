//
//  DeviceListViewController.h
//  PDFReaderSample
//
//  Created by 李沛倬 on 2018/10/25.
//  Copyright © 2018 pep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceListViewController : UIViewController

@property (nonatomic, strong) NSMutableArray<Device *> *datasource;


@end

NS_ASSUME_NONNULL_END
