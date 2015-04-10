//
//  ViewController.m
//  Bluetooth test
//
//  Created by Katia Moreira on 15/03/2015.
//  Copyright (c) 2015 Katia Moreira. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Start up the CBCentralManager
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    [self.sendTextField setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    [super viewWillDisappear:animated];
}

- (IBAction)connectButtonPressed:(id)sender
{
    [self.sendTextField resignFirstResponder];
    
    switch (self.state) {
        case IDLE:
            self.state = SCANNING;
            
            NSLog(@"Started scan ...");
            [self.connectButton setTitle:@"Scanning ..." forState:UIControlStateNormal];
            
            [self.centralManager scanForPeripheralsWithServices:@[UARTPeripheral.uartServiceUUID] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO]}];
            break;
            
        case SCANNING:
            self.state = IDLE;
            
            NSLog(@"Stopped scan");
            [self.connectButton setTitle:@"Connexion" forState:UIControlStateNormal];
            
            [self.centralManager stopScan];
            break;
            
        case CONNECTED:
            NSLog(@"Disconnect peripheral %@", self.currentPeripheral.peripheral.name);
            [self.centralManager cancelPeripheralConnection:self.currentPeripheral.peripheral];
            break;
    }
}

- (IBAction)sendTextFieldEditingChanged:(id)sender {
    if (self.sendTextField.text.length > 20)
    {
        [self.sendTextField setBackgroundColor:[UIColor redColor]];
    }
    else
    {
        [self.sendTextField setBackgroundColor:[UIColor whiteColor]];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self sendButtonPressed:textField];
    return YES;
}

- (IBAction)sendButtonPressed:(id)sender {
    [self.sendTextField resignFirstResponder];
    
    if (self.sendTextField.text.length == 0)
    {
        return;
    }
    
    NSDictionary *dict = @{@"BlogName" : @3,
                           @"BlogDomain" : @4};
    
    NSError *error = nil;
    NSData *json;
    
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        // Serialize the dictionary
        json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        
        // If no errors, let's view the JSON
        if (json != nil && error == nil)
        {
            NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            NSLog(@"JSON: %@", jsonString);
            
            // Set data length limit at 20
            NSUInteger dataLength = jsonString.length;
            int limit = 20;
            
            // Below limit, send as-it
            if (dataLength <= limit) {
                [self.currentPeripheral writeString:jsonString];
            }
            // Above limit, send in lengths <= 20 bytes
            else {
                [self.currentPeripheral writeString:@"START"];
                int len = (int)dataLength;
                for (int i = 0; i < dataLength; i += limit)
                {
                    NSRange ran;
                    if (len >= limit) {
                        len -= limit;
                        ran = NSMakeRange(i, limit);
                    }
                    else {
                        ran = NSMakeRange(i, len);
                    }
                    
                    NSString *res = [jsonString substringWithRange:ran];
                    [self.currentPeripheral writeString:res];
                }
                [self.currentPeripheral writeString:@"END"];
            }
        }
    }

    [self.currentPeripheral writeString:self.sendTextField.text];
}

- (void) didReadHardwareRevisionString:(NSString *)string
{
//    [self addTextToConsole:[NSString stringWithFormat:@"Hardware revision: %@", string] dataType:LOGGING];
}
- (void) didReceiveData:(NSString *)string
{
    NSLog(@"%@", string);
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        [self.connectButton setEnabled:YES];
    }
    
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Did discover peripheral %@", peripheral.name);
    [self.centralManager stopScan];
    
    self.currentPeripheral = [[UARTPeripheral alloc] initWithPeripheral:peripheral delegate:self];
    
    [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect peripheral %@", peripheral.name);
    
    self.state = CONNECTED;
    [self.connectButton setTitle:@"Déconnexion" forState:UIControlStateNormal];
    [self.sendButton setUserInteractionEnabled:YES];
    [self.sendTextField setUserInteractionEnabled:YES];
    
    if ([self.currentPeripheral.peripheral isEqual:peripheral])
    {
        [self.currentPeripheral didConnect];
    }
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Did disconnect peripheral %@", peripheral.name);
    
    self.state = IDLE;
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.sendButton setUserInteractionEnabled:NO];
    [self.sendTextField setUserInteractionEnabled:NO];
    
    if ([self.currentPeripheral.peripheral isEqual:peripheral])
    {
        [self.currentPeripheral didDisconnect];
    }
}

@end
