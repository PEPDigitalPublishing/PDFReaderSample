platform :ios, '11.0'
use_frameworks!
install! 'cocoapods', :disable_input_output_paths => true
workspace 'PEPReaderDemo.xcworkspace'
install! 'cocoapods', :disable_input_output_paths => true
def common_pods

    pod 'SSZipArchive'
    # 非一起作业使用这两行
    pod 'PEPiFlyMSC', :git => 'https://github.com/PEPDigitalPublishing/PEPiFlyMSC.git'
    
    pod 'PEPReaderSDK', :git => 'https://github.com/PEPDigitalPublishing/PEPReaderSDK.git'
    
    pod 'FLAnimatedImage', '~> 1.0'

    # 一起作业使用这两行
#    pod 'PEPReaderSDK_YiQi', :git => 'https://github.com/PEPDigitalPublishing/PEPReaderSDK_YiQi.git'
#    pod 'YIQISpeechEngine', :git => 'https://gitee.com/guxiong/YIQISpeechEngine.git'
#    pod 'iosMath'
#    pod 'MZTimerLabel'
end



target 'PDFReaderSample' do
    project 'PDFReaderSample/PDFReaderSample.xcodeproj'
    
    common_pods
    
    # 可选依赖
    pod 'RKAPPMonitorView'

end



