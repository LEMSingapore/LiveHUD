//
//  StatsForSessionViewController.m
//  Live Poker Stats
//
//  Created by Denis Senichkin on 3/1/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "StatsForSessionViewController.h"
#import "SettingsViewController.h"

@interface StatsForSessionViewController ()

@end

@implementation StatsForSessionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = [AppDelegate sharedAppDelegate];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackBtn:nil];
    [self setSettingsBtn:nil];
    [self setNoOfHandsField:nil];
    [self setNoOfHandsWon:nil];
    [self setNoOfHandsLost:nil];
    [self setBiggestPotWon:nil];
    [self setBiggestPotLost:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.noOfHandsField.transform = CGAffineTransformMakeRotation(-2*M_PI/180.0);
    self.noOfHandsWon.transform = CGAffineTransformMakeRotation(2*M_PI/180.0);
    self.noOfHandsLost.transform = CGAffineTransformMakeRotation(-2*M_PI/180.0);
    
    self.biggestPotWon.transform = CGAffineTransformMakeRotation(-2*M_PI/180.0);
    self.biggestPotLost.transform = CGAffineTransformMakeRotation(-2*M_PI/180.0);
}

- (void)setCurStat:(SessionStats*)value
{
    curSessionStats = value;
    
    NSString *handsPlayedTextString = [NSString stringWithFormat:@"NO OF HANDS PLAYED: %@", [curSessionStats.statsHandsPlayed stringValue]];
    NSString *handsWonTextString = [NSString stringWithFormat:@"NO OF HANDS WON: %@", [curSessionStats.statsHandsWon stringValue]];
    
    NSInteger handsLost = [curSessionStats.statsHandsPlayed integerValue]-[curSessionStats.statsHandsWon integerValue];
    
    NSString *handsLostTextString = [NSString stringWithFormat:@"NO OF HANDS LOST: %@", [NSNumber numberWithInteger: handsLost]];
    
    NSString *potWonTextString = [NSString stringWithFormat:@"BIGGEST POP WON: %@", [curSessionStats.statsBiggestPotWon stringValue]];
    NSString *potLostTextString = [NSString stringWithFormat:@"BIGGEST POT LOST: %@", [curSessionStats.statsBiggestPotLost stringValue]];
    
    self.noOfHandsField.text = handsPlayedTextString;
    self.noOfHandsWon.text = handsWonTextString;
    self.noOfHandsLost.text = handsLostTextString;
    
    self.biggestPotWon.text = potWonTextString;
    self.biggestPotLost.text = potLostTextString;
}

- (IBAction)backBtnClicked:(id)sender
{
    [appDelegate.navigationController popViewControllerAnimated:YES];
}


- (IBAction)settingsBtnClicked:(id)sender
{
    SettingsViewController *vc = [[SettingsViewController alloc] init];
    [[AppDelegate sharedAppDelegate].navigationController pushViewController:vc animated:YES];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
