//
//  StatsForSessionViewController.h
//  Live Poker Stats
//
//  Created by Denis Senichkin on 3/1/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionStats.h"

@interface StatsForSessionViewController : UIViewController
{
    AppDelegate *appDelegate;
    SessionStats *curSessionStats;
}

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UITextField *noOfHandsField;
@property (weak, nonatomic) IBOutlet UITextField *noOfHandsWon;
@property (weak, nonatomic) IBOutlet UITextField *noOfHandsLost;
@property (weak, nonatomic) IBOutlet UITextField *biggestPotWon;
@property (weak, nonatomic) IBOutlet UITextField *biggestPotLost;

- (void)setCurStat:(SessionStats*)value;


@end
