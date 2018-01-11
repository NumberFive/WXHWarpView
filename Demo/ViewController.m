//
//  ViewController.m
//  Demo
//
//  Created by Jerry on 2018/1/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "ViewController.h"
#import "WXHWarpView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WXHWarpView *warpView = [[WXHWarpView alloc] init];
    [self.view addSubview:warpView];
}

@end
