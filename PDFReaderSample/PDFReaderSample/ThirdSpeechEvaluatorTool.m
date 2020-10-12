//
//  ThirdSpeechEvaluatorTool.m
//  PDFReaderSample
//
//  Created by iMac_pephan on 2020/9/24.
//  Copyright © 2020 pep. All rights reserved.
//

#import "ThirdSpeechEvaluatorTool.h"
 
@interface ThirdSpeechEvaluatorTool ()<PRThirdSpeechEvaluationEngineDelegate>

@property (nonatomic, weak) PREvaluationEngine *evaluationEngine;

@property (nonatomic, strong) NSString *wavPath;



@end


@implementation ThirdSpeechEvaluatorTool


+ (instancetype)shareInstance {
    static ThirdSpeechEvaluatorTool *evaluator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        evaluator = [[ThirdSpeechEvaluatorTool alloc] init];
    });
        
    return evaluator;
}




- (instancetype)init{
    self = [super init];
    if (self) {
        _evaluationEngine = [PREvaluationEngine shareInstance];
        _evaluationEngine.thirdSpeechEvaluatorDelegate = self;
    }
    return self;
}


// 开始测评
- (void)startRecordWithText:(NSString *)textString savePath:(nonnull NSString *)wavPath{
     // 根据测评文本开始进行测评
    // ...
    
    _wavPath = wavPath;
    [_evaluationEngine.delegate onBeginOfSpeech];
}
// 结束测评
- (void)stopRecord{
    
//    PREvaluateResult *prResult = [[PREvaluateResult alloc] init];
//    prResult.score = 88;
//    [_evaluationEngine.delegate followResult:prResult];

    // 正常测评完成时 保存测评录音文件到wavPath地址 并实现以下方法
    if ([_evaluationEngine.delegate respondsToSelector:@selector(offlinePath:)]) {
        [_evaluationEngine.delegate offlinePath:self.wavPath];
    }
    if ([_evaluationEngine.delegate respondsToSelector:@selector(onEndOfSpeech)]) {
        [_evaluationEngine.delegate onEndOfSpeech];
    }

}
// 取消测评
- (void)cancelRecord{
    // ...
    [_evaluationEngine.delegate onCancel];
}

// 音量的回调

//    if ([_evaluationEngine.delegate respondsToSelector:@selector(recordVolume:)]) {
//        [_evaluationEngine.delegate recordVolume:3.5];
//    }

// 测评结果回调
- (void)getResult:(PREvaluateResult *)result{
    // ...
    PREvaluateSentenceResult *sentence = [[PREvaluateSentenceResult alloc] init];
    sentence.content = @"Good morning!";
    sentence.score = 30;

    PREvaluateResult *prResult = [[PREvaluateResult alloc] init];
    prResult.score = 78;
    prResult.begin = 0;
    prResult.end = 0;
    prResult.code = 0;
    prResult.content = @"Good morning! I'm Miss Wu. What's your name?";
    prResult.sentences = @[sentence,sentence,sentence];
    
    // 根据测评结果实现该方法
    if ([_evaluationEngine.delegate respondsToSelector:@selector(followResult:)]) {
        [_evaluationEngine.delegate followResult:prResult];
    }
    // 如果测评发生错误 回调该方法
//    if ([_evaluationEngine.delegate respondsToSelector:@selector(onErrorWithErrorCode:errorType:errorMessage:)]) {
//        [_evaluationEngine.delegate onErrorWithErrorCode:0 errorType:0 errorMessage:@"测评错误"];
//    }
}
@end
