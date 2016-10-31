//
//  ViewController.m
//  iBeacon
//
//  Created by PGMY on 2016/10/20.
//  Copyright © 2016年 PGMY. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
#import "CentralViewController.h"
#import "PeripheralViewController.h"

@interface ViewController ()

@property (nonatomic,strong) UIButton *scanButton;
@property (nonatomic,strong) UIButton *centralButton;
@property (nonatomic,strong) UIButton *peripheralButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scanButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 100)];
    _scanButton.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:0.8 alpha:1];
    [_scanButton setTitle:@"Scan" forState:UIControlStateNormal];
    [_scanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_scanButton addTarget:self action:@selector(pushScanViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_scanButton];
    
    _centralButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 64+100, self.view.frame.size.width, self.view.frame.size.height/2 - 32 - 50)];
    _centralButton.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:1 alpha:1];
    [_centralButton setTitle:@"Central" forState:UIControlStateNormal];
    [_centralButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_centralButton addTarget:self action:@selector(pushCentralViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_centralButton];
    
    _peripheralButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2 +32+50, self.view.frame.size.width, self.view.frame.size.height/2 - 32 - 50)];
    _peripheralButton.backgroundColor = [UIColor colorWithRed:1 green:0.8 blue:0.8 alpha:1];
    [_peripheralButton setTitle:@"Peripheral" forState:UIControlStateNormal];
    [_peripheralButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_peripheralButton addTarget:self action:@selector(pushPeripheralViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_peripheralButton];
}

- (void)pushScanViewController:(UIButton*)button {
    ScanViewController *vc = [[ScanViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)pushCentralViewController:(UIButton*)button {
    CentralViewController *vc = [[CentralViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushPeripheralViewController:(UIButton*)button {
    PeripheralViewController *vc = [[PeripheralViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
