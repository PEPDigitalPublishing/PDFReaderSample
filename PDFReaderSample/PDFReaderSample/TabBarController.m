//
//  TabBarController.m
//  PDFReaderSample
//
//  Created by 李沛倬 on 2018/10/24.
//  Copyright © 2018 pep. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

}


/**
 人教点读SDK内部对于状态栏的「隐藏与显示」及「风格控制」采用以下方式实现，请对接方务必采用相同方式实现，否则将可能在某些页面出现UI适配问题。
 实现步骤：
 1. 在Info.plist中添加「View controller-based status bar appearance」字段，并将value设置为「YES」
 2. 在window.rootViewController中添加如下代码。
    若window.rootViewController为TabBarVC，则直接拷贝以下代码；
    若为其他类型VC，则需要按照以下代码的思路，一步一步将「prefersStatusBarHidden」和「preferredStatusBarStyle」传递给屏幕最上方显示的VC，让其实现对这些状态的控制。
 */
// MARK: - Status Bar

- (BOOL)prefersStatusBarHidden {
    return self.selectedViewController.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.selectedViewController.preferredStatusBarStyle;
}

@end
