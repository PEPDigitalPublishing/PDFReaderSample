//
//  Device.h
//  PDFReaderSample
//
//  Created by 李沛倬 on 2018/10/25.
//  Copyright © 2018 pep. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Device : NSObject

/// 设备ID: iOS平台为UDID
@property (nonatomic, copy) NSString *dev_id;
/// 绑定该设备的时间, 格式为：2017-08-09 18:01:38
@property (nonatomic, copy) NSString *create_time;
/// 设备名称，例如：My iPhone6s
@property (nonatomic, copy) NSString *dev_name;

@end

NS_ASSUME_NONNULL_END
