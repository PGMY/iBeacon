//
//  PeripheralViewController.m
//  iBeacon
//
//  Created by PGMY on 2016/10/20.
//  Copyright © 2016年 PGMY. All rights reserved.
//

#import "PeripheralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "Define.h"

@interface PeripheralViewController () <CBPeripheralManagerDelegate>

// - Property ------------------------------------------------------------------
// UI
@property (nonatomic,strong) UILabel *statusLabel;
//
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CBPeripheralManager *peripheralManager;


@end

@implementation PeripheralViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:1 green:0.8 blue:0.8 alpha:1];
    self.navigationController.title = @"Peripheral";
    
    // UI
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    _statusLabel.text = @"NONE";
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_statusLabel];
    
    //
    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:SERVICE_UUID];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        [self startAdvertising];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        [self sendLocalNotificationForMessage:[NSString stringWithFormat:@"%@", error]];
        _statusLabel.text = [NSString stringWithFormat:@"%@", error];
    } else {
        [self sendLocalNotificationForMessage:@"Start Advertising"];
        _statusLabel.text = @"Start Advertising";
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSString *message;
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            message = @"PoweredOff";
            break;
        case CBPeripheralManagerStatePoweredOn:
            message = @"PoweredOn";
            [self startAdvertising];
            break;
        case CBPeripheralManagerStateResetting:
            message = @"Resetting";
            break;
        case CBPeripheralManagerStateUnauthorized:
            message = @"Unauthorized";
            break;
        case CBPeripheralManagerStateUnknown:
            message = @"Unknown";
            break;
        case CBPeripheralManagerStateUnsupported:
            message = @"Unsupported";
            break;
            
        default:
            break;
    }
    
    [self sendLocalNotificationForMessage:[@"PeripheralManager did update state: " stringByAppendingString:message]];
}

#pragma mark - Private methods

- (void)startAdvertising
{
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                                           major:1
                                                                           minor:2
                                                                      identifier:@"jp.classmethod.testregion"];
    NSDictionary *beaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    [self.peripheralManager startAdvertising:beaconPeripheralData];
}

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
