//
//  ScanViewController.m
//  iBeacon
//
//  Created by PGMY on 2016/10/21.
//  Copyright © 2016年 PGMY. All rights reserved.
//

#import "ScanViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "Define.h"

#pragma mark - BluetoothInfo

@implementation BluetoothInfo
@end

#pragma mark - BluetoothInfoTableViewCell
@implementation BluetoothInfoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if ( self ){
        
    }
    return self;
}

@end

#pragma mark - ScanViewController
@interface ScanViewController () <UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate>

// UI
@property (nonatomic, strong) UITableView *tableView;

// Bluetooth
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong) NSMutableArray *scannedUUIDArray;
@property (nonatomic, strong) NSMutableArray *scannedBluetoothInfoArray;

// Beacon
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSUUID *proximityUUID;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:0.8 alpha:1];
    
    // UI
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[BluetoothInfoTableViewCell class] forCellReuseIdentifier:NSStringFromClass([BluetoothInfoTableViewCell class])];
    [self.view addSubview:_tableView];

    // Bluetooth
//    NSArray *services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:SERVICE_UUID], nil];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    _centralManager.delegate = self;
    _scannedBluetoothInfoArray = [NSMutableArray array];
    _scannedUUIDArray = [NSMutableArray array];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_scannedUUIDArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName = NSStringFromClass([BluetoothInfoTableViewCell class]);
    BluetoothInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    BluetoothInfo *info = _scannedBluetoothInfoArray[indexPath.row];
    cell.textLabel.text = info.uuidString;
    cell.detailTextLabel.text = info.nameString;
    if ( [info.uuidString isEqualToString:SERVICE_UUID] ){
        cell.textLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    if ( info.kind == Bluetooth) {
        cell.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:1 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:1 green:0.8 blue:0.8 alpha:1];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if(central.state == CBCentralManagerStatePoweredOn) {
        // Centralとして機能可能な場合
        // 2: Peripheralのスキャンを開始
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
//    NSLog(@"===================");
//    for (CBService *s in peripheral.services) {
//        NSLog(@"Service found : %@",s.UUID);
//    }
//    NSLog(@"manufacturer data:%@", advertisementData[CBAdvertisementDataManufacturerDataKey]);
//    NSLog(@"DESC >> %@",[advertisementData description]);
    NSString *uuid = [peripheral.identifier UUIDString];
    
    if ( ![_scannedUUIDArray containsObject:uuid] ) {
        BluetoothInfo *info = [[BluetoothInfo alloc] init];
        info.uuidString = uuid;
        info.kind = Bluetooth;
        info.nameString = peripheral.name;
        [_scannedBluetoothInfoArray addObject:info];
        [_scannedUUIDArray addObject:uuid];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([_scannedUUIDArray count] - 1 ) inSection: 0];
        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [_tableView reloadData];
    }
}

#pragma mark - CBPeripheralDelegate

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Start Monitoring Region");
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Enter Region");
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exit Region");
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"===========");
    for (CLBeacon *beacon in beacons) {
        NSLog(@"BEACON >> %@",beacon.proximityUUID);
        NSString *uuid = [beacon.proximityUUID UUIDString];
        if ( ![_scannedUUIDArray containsObject:uuid] ) {
            BluetoothInfo *info = [[BluetoothInfo alloc] init];
            info.uuidString = uuid;
            info.kind = iBeacon;
            info.nameString = [NSString stringWithFormat:@"major:%@ minor:%@",beacon.major,beacon.minor];
            [_scannedBluetoothInfoArray addObject:info];
            [_scannedUUIDArray addObject:uuid];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([_scannedUUIDArray count] - 1 ) inSection: 0];
            [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //        [_tableView reloadData];
        }
    }
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
        NSLog(@"%@",rangeMessage);
        
        NSString *message = [NSString stringWithFormat:@"major:%@, minor:%@, accuracy:%f, rssi:%ld",
                             nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, (long)nearestBeacon.rssi];
        NSLog(@"%@",message);
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Exit Region");
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
    NSLog(@"%@",determineMessage);
}


@end
