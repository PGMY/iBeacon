//
//  ScanViewController.h
//  iBeacon
//
//  Created by PGMY on 2016/10/21.
//  Copyright © 2016年 PGMY. All rights reserved.
//

#import <UIKit/UIKit.h>

//
typedef enum : NSUInteger {
    Bluetooth,
    iBeacon,
} BluetoothKind;

@interface BluetoothInfo : NSObject
@property (nonatomic, assign) BluetoothKind kind;
@property (nonatomic, strong) NSString *uuidString;
@property (nonatomic, strong) NSString *nameString;
@end

@interface BluetoothInfoTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@end

@interface ScanViewController : UIViewController

@end
