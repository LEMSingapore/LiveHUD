//
//  HomePageViewController.m
//  Poker Live
//
//  Created by Denis Senichkin on 2/13/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "HomePageViewController.h"
#import "SettingsViewController.h"
#import "BoardViewController.h"
#import "BoardLandscapeViewController.h"
#import "ReviewSessionsViewController.h"
#import "PlayersNotesViewController.h"
#import "StoreViewController.h"


@interface HomePageViewController ()

@end

@implementation HomePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setStartBtn:nil];
    [self setConfigBtn:nil];
    [self setReviewBtn:nil];
    [self setBkgView:nil];
    [self setPlayersNotesBtn:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *imageViewName;
    if (IS_IPHONE_5)
    {
        imageViewName = [UIImage imageNamed:@"SplashScreen-568h@2x.png"];
    }
    else
    {
        imageViewName = [UIImage imageNamed:@"SplashScreen@2x.png"];
    }
    
    self.bkgView.image = imageViewName;
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Orientation
//@todo here
//-(BOOL)shouldAutorotate
//{
//    return NO;
//}

//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationPortrait;
//}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (IBAction)startBtnClicked:(id)sender
{
    Settings *settings = [[AppDelegate sharedAppDelegate].dataManager getSettingsEntry];
    
    if ([settings getSettingsIsChanged])
    {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [[AppDelegate sharedAppDelegate] changeShowModalVCFlag:YES];
        BoardLandscapeViewController *vc = [[BoardLandscapeViewController alloc] init];
        [[AppDelegate sharedAppDelegate].navigationController presentViewController:vc animated:YES completion:nil];
    }
    else
    {
        SettingsViewController *vc = [[SettingsViewController alloc] init];
        [[AppDelegate sharedAppDelegate].navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)configureBtnClicked:(id)sender
{
    SettingsViewController *vc = [[SettingsViewController alloc] init];
    [[AppDelegate sharedAppDelegate].navigationController pushViewController:vc animated:YES];
}

- (IBAction)reviewBtnClicked:(id)sender
{
    ReviewSessionsViewController *vc = [[ReviewSessionsViewController alloc] init];
    [[AppDelegate sharedAppDelegate].navigationController pushViewController:vc animated:YES];
}

- (IBAction)playersNotesBtnClicked:(id)sender
{
    PlayersNotesViewController *vc = [[PlayersNotesViewController alloc] init];
    [[AppDelegate sharedAppDelegate].navigationController pushViewController:vc animated:YES];
}

- (IBAction)storeBtnClicked:(id)sender
{
    StoreViewController *vc = [[StoreViewController alloc] init];
    [[AppDelegate sharedAppDelegate].navigationController pushViewController:vc animated:YES];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
