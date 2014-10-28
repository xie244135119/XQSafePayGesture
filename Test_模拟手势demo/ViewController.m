//
//  ViewController.m
//  Test_模拟手势demo
//
//  Created by SunSet on 13-12-4.
//  Copyright (c) 2013年 SunSet. All rights reserved.
//

#import "ViewController.h"
#import "GestureRecognizerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*初始化页面*/
-(void)initView
{
    GestureRecognizerView *gesView=[[[GestureRecognizerView alloc]initWithFrame:self.view.bounds]autorelease];
    [self.view addSubview:gesView];
}



@end
