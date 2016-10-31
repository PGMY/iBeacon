//
//  CentralViewController.m
//  iBeacon
//
//  Created by PGMY on 2016/10/20.
//  Copyright © 2016年 PGMY. All rights reserved.
//

#import "CentralViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Define.h"

@interface CentralViewController () <CLLocationManagerDelegate>

// - Property ------------------------------------------------------------------
// UI
@property (nonatomic,strong) UILabel *statusLabel;
@property (nonatomic,strong) UILabel *rangeLabel;
@property (nonatomic,strong) UILabel *determineLabel;
// iBeacon
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;


@end

@implementation CentralViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:1 alpha:1];
    self.navigationController.title = @"Central";
    
    // UI
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    _statusLabel.text = @"NONE";
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_statusLabel];
    
    _rangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, self.view.frame.size.width, 50)];
    _rangeLabel.text = @"NONE";
    _rangeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_rangeLabel];
    
    _determineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, 50)];
    _determineLabel.text = @"NONE";
    _determineLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_determineLabel];
    
    // iBeacon
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        self.locationManager = [CLLocationManager new];
        if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        self.locationManager.delegate = self;
        
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:SERVICE_UUID];
        
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:SERVICE_IDENTIFER];
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Start Monitoring Region"];
    _statusLabel.text = @"Start Monitoring Region";
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Enter Region"];
    _statusLabel.text = @"Enter Region";
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
    _statusLabel.text = @"Exit Region";
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        
        NSString *rangeMessage;
        
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"Range Immediate: ";
                break;
            case CLProximityNear:
                rangeMessage = @"Range Near: ";
                break;
            case CLProximityFar:
                rangeMessage = @"Range Far: ";
                break;
            default:
                rangeMessage = @"Range Unknown: ";
                break;
        }
        
        NSString *message = [NSString stringWithFormat:@"major:%@, minor:%@, accuracy:%f, rssi:%ld",
                             nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, (long)nearestBeacon.rssi];
        [self sendLocalNotificationForMessage:[rangeMessage stringByAppendingString:message]];
        _rangeLabel.text = message;
        _statusLabel.text = rangeMessage;
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
    _statusLabel.text = @"Exit Region (Fail)";
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    
    NSString *determineMessage;
    
    switch (state) {
        case CLRegionStateInside: // リージョン内にいる
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            }
            determineMessage = @"region inside";
            break;
        case CLRegionStateOutside:
            determineMessage = @"region outside";
            break;
        case CLRegionStateUnknown:
            determineMessage = @"region unknown";
        default:
            break;
    }
    _determineLabel.text = determineMessage;
}

#pragma mark - Private methods

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


@end
