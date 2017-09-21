//
//  ViewController.m
//  PushkitDemo
//
//  Created by heweihua on 2017/9/19.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"PushKit";
    
    UIImage* img = [UIImage imageNamed:@"cocopods.jpg"];
    UIImageView* imgview = [[UIImageView alloc] initWithImage:img];
    [self.view addSubview:imgview];
    
    CGFloat pointW = CGRectGetWidth(self.view.frame);
    CGFloat pointH = (pointW* img.size.height)/img.size.width;
    [imgview setFrame:CGRectMake(0, (CGRectGetHeight(self.view.frame) - pointH)/2.f, pointW, pointH)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
