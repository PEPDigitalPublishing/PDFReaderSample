//
//  NavigationController.m
//  PDFReaderSample
//
//  Created by 李沛倬 on 2018/6/21.
//  Copyright © 2018年 pep. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

}


// MARK: - Status Bar

- (BOOL)prefersStatusBarHidden {
    return self.topViewController.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

@end
