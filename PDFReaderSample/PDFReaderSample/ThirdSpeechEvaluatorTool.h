//
//  ThirdSpeechEvaluatorTool.h
//  PDFReaderSample
//
//  Created by iMac_pephan on 2020/9/24.
//  Copyright © 2020 pep. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThirdSpeechEvaluatorTool : NSObject


+ (instancetype)shareInstance;

- (void)cancelRecord;
     
- (void)startRecordWithText:(NSString *)textString savePath:(NSString *)wavPath;;

- (void)stopRecord;

@end

NS_ASSUME_NONNULL_END
