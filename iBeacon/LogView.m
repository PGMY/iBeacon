//
//  LogView.m
//  iBeacon
//
//  Created by PGMY on 2016/10/21.
//  Copyright © 2016年 PGMY. All rights reserved.
//

#import "LogView.h"


@interface LogView ()

// - Property ------------------------------------------------------------------
// UI
@property (nonatomic,strong) UITableView *logTableView;

@end

@implementation LogView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ){
        _logTableView = [[UITableView alloc] initWithFrame:frame];
    }
    return self;
}

@end
