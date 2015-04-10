//
//  ViewController.h
//  Bluetooth test
//
//  Created by Katia Moreira on 15/03/2015.
//  Copyright (c) 2015 Katia Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UARTPeripheral.h"

typedef enum
{
    IDLE = 0,
    SCANNING,
    CONNECTED,
} ConnectionState;

@interface ViewController : UIViewController <UITextFieldDelegate, CBCentralManagerDelegate, UARTPeripheralDelegate>

@property (strong, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) IBOutlet UITextField *sendTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;
@property (nonatomic) ConnectionState               state;
@property (strong, nonatomic) UARTPeripheral        *currentPeripheral;

- (IBAction)connectButtonPressed:(id)sender;
- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)sendTextFieldEditingChanged:(id)sender;

@end

