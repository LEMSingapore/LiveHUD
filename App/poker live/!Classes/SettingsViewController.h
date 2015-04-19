//
//  SettingsViewController.h
//  Poker Live
//
//  Created by Denis Senichkin on 2/13/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddLocationViewController.h"
#import "PickerVC.h"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    PickerVC *pickerVC;
    AddLocationViewController *addLocVC;
    Settings *settings;
    AppDelegate *appDelegate;
    
    NSMutableArray *players;
    NSInteger CELL_DEFAULT_HEIGHT;
    
    NSMutableArray *playersNames;
    NSMutableArray *playersStacks;
}

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *numberBtn;
@property (weak, nonatomic) IBOutlet UIButton *structureBtn;
@property (weak, nonatomic) IBOutlet UITextField *numberText;
@property (weak, nonatomic) IBOutlet UITextField *betText;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextField *locationPlaceField;
@property (weak, nonatomic) IBOutlet UIButton *locationPlaceBtn;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@end
