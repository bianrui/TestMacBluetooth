//
//  ViewController.m
//  testMacBluetooth
//
//  Created by bianruifeng on 2017/5/8.
//  Copyright © 2017年 bianruifeng. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<
CBCentralManagerDelegate,
NSTableViewDataSource,
NSTableViewDelegate>
@property (nonatomic, strong) CBCentralManager *centerManager;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSTableView *tableView;
@end



@implementation ViewController
{
    NSButton *_startBtn;
    NSButton *_endBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 一般使用第二种，简单粗暴自带代理
    //    self.centerManager = [[CBCentralManager alloc] init];
    self.centerManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // 这个....初始化特定的中心，可能与后台使用有关，确实不了解，请告知，谢谢；
    //    self.centerManager = [[CBCentralManager alloc] initWithDelegate:self
    //                                                              queue:nil
    //                                                            options:@{CBCentralManagerOptionShowPowerAlertKey:@(YES),
    //                                                                      CBCentralManagerOptionRestoreIdentifierKey:@"UUID"}];
    
    
    
    
    
    
    //删除按钮
    _startBtn = [[NSButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-100, 30, 70, 25)];
    _startBtn.title = @"开始";
    _startBtn.wantsLayer = YES;
    _startBtn.layer.cornerRadius = 3.0f;
    _startBtn.layer.borderColor = [NSColor lightGrayColor].CGColor;
    [_startBtn setTarget:self];
    _startBtn.action = @selector(startScan);
    [self.view addSubview:_startBtn];
    
    //添加按钮
    _endBtn = [[NSButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-100, 80, 70, 25)];
    _endBtn.title = @"停止";
    _endBtn.wantsLayer = YES;
    _endBtn.layer.cornerRadius = 3.0f;
    _endBtn.layer.borderColor = [NSColor lightGrayColor].CGColor;
    [_endBtn setTarget:self];
    _endBtn.action = @selector(stopScan);
    [self.view addSubview:_endBtn];
    
    
    
    
    
    
    // 1.0.创建卷轴视图
    NSScrollView *scrollView    = [[NSScrollView alloc] init];
    // 1.1.有(显示)垂直滚动条
    scrollView.hasVerticalScroller  = YES;
    // 1.2.设置frame并自动布局
    //        scrollView.frame            = self.view.bounds;
    scrollView.frame            = CGRectMake(10, 0, 300, 500);
    //    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    scrollView.autoresizingMask = NSViewWidthSizable;
    // 1.3.添加到self.view
    [self.view addSubview:scrollView];
    
    // 2.0.创建表视图
    self.tableView      = [[NSTableView alloc] init];
    self.tableView.frame             = self.view.bounds;
    // 2.1.设置代理和数据源
    self.tableView.delegate          = self;
    self.tableView.dataSource        = self;
    // 2.2.设置为ScrollView的documentView
    scrollView.contentView.documentView = self.tableView;
    
    // 3.0.创建表列
    NSTableColumn *columen1     = [[NSTableColumn alloc] initWithIdentifier:@"columen1"];
    // 3.1.设置最小的宽度
    columen1.minWidth           = 150.0;
    // 3.2.允许用户调整宽度
    columen1.resizingMask       = NSTableColumnUserResizingMask;
    // 3.3.添加到表视图
    [self.tableView addTableColumn:columen1];
    
    
    
}
- (void)startScan
{
    // 条件扫描 设备
    //    [self.centerManager scanForPeripheralsWithServices:nil options:nil];
    
    [self sacnNearPerpherals];
}

- (void)stopScan
{
    // 判断 并 停止扫描
    [self.centerManager stopScan];
    NSLog(@"停止扫描周围的设备");
    //    if ([self.centerManager isScanning]) {
    //        [self.centerManager stopScan];
    //    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"扫描到一个设备设备：%@",peripheral.name);
    // RSSI 是设备信号强度
    // advertisementData 设备广告标识
    // 一般把新扫描到的设备添加到一个数组中，并更新列表
    
    if (peripheral.name) {
        [self.array addObject:peripheral.name];
        [self.tableView reloadData];
    }
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    /*
     CBCentralManagerStateUnknown = 0,
     CBCentralManagerStateResetting,
     CBCentralManagerStateUnsupported,
     CBCentralManagerStateUnauthorized,
     CBCentralManagerStatePoweredOff,
     CBCentralManagerStatePoweredOn,
     */
    // 在初始化 CBCentralManager 的时候会打开设备，只有当设备正确打开后才能使用
    
    switch (central.state){
            
        case CBCentralManagerStateUnknown:        // 蓝牙已打开，开始扫描外设
            
            NSLog(@"蓝牙已打开，开始扫描外设");
            
            // 开始扫描周围的设备，自定义方法
            [self sacnNearPerpherals];
            
            break;
            
        case CBCentralManagerStateResetting:
            
            NSLog(@"您的设备不支持蓝牙或蓝牙 4.0");
            
            break;
            
        case CBCentralManagerStateUnsupported:
            
            NSLog(@"未授权打开蓝牙");
            
            break;
            
        case CBCentralManagerStateUnauthorized:       // 蓝牙未打开，系统会自动提示打开，所以不用自行提示
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
            
        case CBCentralManagerStatePoweredOff:       // 蓝牙未打开，系统会自动提示打开，所以不用自行提示
            NSLog(@"CBCentralManagerStatePoweredOff");
            break;
            
        case CBCentralManagerStatePoweredOn:       // 蓝牙未打开，系统会自动提示打开，所以不用自行提示
            NSLog(@"CBCentralManagerStatePoweredOn");
            [self sacnNearPerpherals];
            break;
        default:
            break;
    }
}
//{
//    if (central.state == CBCentralManagerStatePoweredOn) {
//        // 蓝牙打开，则开始搜索
//        NSLog(@"蓝牙 打开 则开始搜索");
//    } else {
//        NSLog(@"蓝牙 异常");
//    }
//}
//

// 开始扫描周围的设备，自定义方法
- (void)sacnNearPerpherals {
    
    NSLog(@"开始扫描周围的设备");
    
    /*
     * 第一个参数为 Services 的 UUID（外设端的 UUID)，nil 为扫描周围所有的外设。
     * 第二参数的 CBCentralManagerScanOptionAllowDuplicatesKey 为已发现的设备是否重复扫描，YES 同一设备会多次回调。nil 时默认为 NO。
     */
    [self.centerManager scanForPeripheralsWithServices:nil
                                               options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

//// 注意，这个代理有毒，可能与后台蓝牙有关
//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
//
//}


#pragma mark - NSTableViewDelegate
// 设置行数
- (NSInteger)numberOfRowsInTableView:(NSTableView* )tableView{
    
    return self.array.count;
}

// 设置行高
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 30;
}

// 设置Cell
- (NSView *)tableView:(NSTableView* )tableView viewForTableColumn:(NSTableColumn* )tableColumn row:(NSInteger)row{
    
    // 1.0.创建一个Cell
    NSTextField *view   = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 30)];
    view.bordered       = NO;
    view.editable       = NO;
    
    //    // 1.1.判断是哪一列
    //    if ([tableColumn.identifier isEqualToString:@"columen1"]) {
    //        view.stringValue    = [NSString stringWithFormat:@"第1列的第%ld个Cell",row + 1];
    //    }else if ([tableColumn.identifier isEqualToString:@"columen2"]) {
    //        view.stringValue    = [NSString stringWithFormat:@"第2列的第%ld个Cell",row + 1];
    //    }else {
    //        view.stringValue    = [NSString stringWithFormat:@"不知道哪列的第%ld个Cell",row + 1];
    //    }
    NSString *name = self.array[row];
    view.stringValue = name;
    return view;
}


- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView // 能否选中表格的行，返回NO则不能选中表格的每行数据
{
    return YES;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    NSLog(@"选中了 %ld",row);
    return YES;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(nullable NSTableColumn *)tableColumn
{
    NSLog(@"tableColumn %@",tableColumn);
    return YES;
}
- (void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn//鼠标左键按下响应事件函
{
    NSLog(@"mouseDownInHeaderOfTableColumn");
}
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn //鼠标左键按下响应事件函数
{
    NSLog(@"didClickTableColumn");
}


#pragma mark - Geter

-(NSMutableArray *)array
{
    if (!_array) {
        _array = [NSMutableArray arrayWithCapacity:2];
    }
    return _array;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}


@end
