//
//  ReviewSessionsViewController.m
//  Live Poker Stats
//
//  Created by Denis Senichkin on 2/28/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "ReviewSessionsViewController.h"
#import "SettingsViewController.h"
#import "StatsForSessionViewController.h"
#import "HandsViewController.h"
#import <QuartzCore/QuartzCore.h>

#define CELL_DEFAULT_HEIGHT 320

@interface ReviewSessionsViewController ()

@end

@implementation ReviewSessionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        appDelegate = [AppDelegate sharedAppDelegate];
        allSessions = [appDelegate.dataManager getAllSessions];
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
    [self setMyTableView:nil];
    [self setPageControl:nil];
    [self setStatsForSessionBtn:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statsForSessionBtn.layer.cornerRadius = 5;//half of the width
    self.statsForSessionBtn.layer.borderColor = [UIColor grayColor].CGColor;
    self.statsForSessionBtn.layer.borderWidth = 1.0f;
    
    self.myTableView.backgroundColor = [UIColor clearColor];
    self.myTableView.transform = CGAffineTransformMakeRotation(-90*M_PI/180.0);
    self.myTableView.showsHorizontalScrollIndicator = FALSE;
    self.myTableView.showsVerticalScrollIndicator = FALSE;
    
    if (IS_IPHONE_5)
    {
        rowsPerPage = 6;
    }
    else
    {
        rowsPerPage = 5;
    }
    
    NSInteger count = 0;
    
    if ([allSessions count] == 0)
    {
        count = 1;
    }
    else
    {
        count = [allSessions count]/rowsPerPage;
        
        if ([allSessions count]%rowsPerPage !=0)
        {
            count++;
        }
    }
    
    self.pageControl.numberOfPages = count;
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - PageControl stuff
- (IBAction)changePage:(id)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0];
    [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageHeight = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    //NSLog(@"scrollViewDidScroll page = %d", page);
    
    self.pageControl.currentPage = page;
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:page inSection:0];
    //[self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

/*- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat pageHeight = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    NSLog(@"scrollViewDidEndDragging page = %d", page);
    
    //self.pageControl.currentPage = page;
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:page inSection:0];
    //[self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}*/


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([allSessions count] == 0)
    {
        return 0;
    }
    
    NSInteger count = [allSessions count]/rowsPerPage;
    
    if ([allSessions count]%rowsPerPage !=0)
    {
        count++;
    }
    
    return  count;
}

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath = %@", indexPath);
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath = %@", indexPath);
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    for(UIView *view in cell.contentView.subviews)
    {
            [view removeFromSuperview];
    }
    
    NSInteger count = [allSessions count]/rowsPerPage;
    if ([allSessions count]%rowsPerPage !=0)
    {
        count++;
    }
    
    if (indexPath.row < count)
    {
        NSInteger yOffset = 10;
        NSInteger onePieceHeight = 60;
        
        for (int i = 0; i < rowsPerPage; i++)
        {
            if (indexPath.row*rowsPerPage+i >= [allSessions count])
            {
                break;
            }
            
            Session *curSession = [allSessions objectAtIndex:indexPath.row*rowsPerPage+i];
            if (curSession != NULL)
            {
                UITextField *backLabel = [[UITextField alloc] initWithFrame:CGRectMake(0, yOffset-5, 320, onePieceHeight-10)];
                backLabel.borderStyle = UITextBorderStyleRoundedRect;backLabel.userInteractionEnabled = NO;
                backLabel.backgroundColor = [UIColor colorWithRed:54/255.0 green:54/255.0 blue:54/255.0 alpha:0.7];
                backLabel.alpha = 1;
                [cell.contentView addSubview:backLabel];
                
                UITextField *dateField = [[UITextField alloc] initWithFrame:CGRectMake(0, yOffset, 140, 20)];
                dateField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:11];dateField.textColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
                dateField.textAlignment = NSTextAlignmentLeft;dateField.userInteractionEnabled = NO;
                dateField.borderStyle = UITextBorderStyleRoundedRect;dateField.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:dateField];
                
                UITextField *bbField = [[UITextField alloc] initWithFrame:CGRectMake(0, yOffset + 20, 140, 20)];
                bbField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:11];bbField.textColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
                bbField.textAlignment = NSTextAlignmentLeft;bbField.userInteractionEnabled = NO;
                bbField.borderStyle = UITextBorderStyleRoundedRect;bbField.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:bbField];
                
                UITextField *handsField = [[UITextField alloc] initWithFrame:CGRectMake(140, yOffset, 140, 20)];
                handsField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:11];handsField.textColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
                handsField.textAlignment = NSTextAlignmentLeft;handsField.userInteractionEnabled = NO;
                handsField.borderStyle = UITextBorderStyleRoundedRect;handsField.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:handsField];
                
                UITextField *locationField = [[UITextField alloc] initWithFrame:CGRectMake(140, yOffset + 20, 140, 20)];
                locationField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:11];locationField.textColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
                locationField.textAlignment = NSTextAlignmentLeft;locationField.userInteractionEnabled = NO;
                locationField.borderStyle = UITextBorderStyleRoundedRect;locationField.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:locationField];
                
                UIButton *checkBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                checkBoxBtn.frame = CGRectMake(0, yOffset, 280, onePieceHeight-15);
                checkBoxBtn.backgroundColor = [UIColor clearColor];
                checkBoxBtn.tag = indexPath.row*rowsPerPage+i;
                [checkBoxBtn addTarget:self action:@selector(sessionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:checkBoxBtn];
                
                UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                deleteBtn.frame = CGRectMake(285, yOffset + 5, 32, 32);
                deleteBtn.backgroundColor = [UIColor clearColor];
                deleteBtn.tag = indexPath.row*rowsPerPage+i;
                [deleteBtn setBackgroundImage:[UIImage imageNamed:@"deleteBtnBkg.png"] forState:UIControlStateNormal];
                [deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:deleteBtn];
                
                yOffset += onePieceHeight;
                
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                NSLocale *tmpLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                [df setLocale:tmpLocale];
                [df setDateFormat:@"MM/dd/yyyy hh:mm a"];
                NSString *dateStr = [df stringFromDate:curSession.sessionDate];
                
                NSString *dateTextString = [NSString stringWithFormat:@"DATE: %@", dateStr];
                NSString *bbTextString = [NSString stringWithFormat:@"BB WON: %0.2f BB", [curSession.sessionBBwon floatValue]];
                NSString *locationTextString = [NSString stringWithFormat:@"PLACE: %@", curSession.sessionLocation];
                NSString *noOfHandsTextString = [NSString stringWithFormat:@"NO. OF HANDS: %@", [curSession.sessionNumOfHands stringValue]];
                
                dateField.text = dateTextString;
                bbField.text = bbTextString;
                locationField.text = locationTextString;
                handsField.text = noOfHandsTextString;
                
            }
        }
    }
    
    //self.pageControl.currentPage = indexPath.row;

    //rotate cell
    cell.transform = CGAffineTransformMakeRotation(90*M_PI/180.0);
    
    return cell;
}

#pragma mark - Delete btn clicked
- (void)deleteBtnClicked:(UIButton*)sender
{
    Session *curSession = [allSessions objectAtIndex:sender.tag];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSLocale *tmpLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [df setLocale:tmpLocale];
    [df setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSString *dateStr = [df stringFromDate:curSession.sessionDate];
    
    NSString *str = [NSString stringWithFormat:@"Delete session with date\n%@?", dateStr];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:str delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    alert.tag = sender.tag;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *title = [[alertView buttonTitleAtIndex:buttonIndex] lowercaseString];
    if ([title isEqualToString:@"delete"])
    {
        NSInteger tag = alertView.tag;
        
        if (tag < [allSessions count])
        {
            Session *curSession = [allSessions objectAtIndex:tag];
            
            if (curSession != NULL)
            {
                [appDelegate.dataManager.managedObjectContext deleteObject:curSession];
                allSessions = [appDelegate.dataManager getAllSessions];
                [self.myTableView reloadData];
                
                if (IS_IPHONE_5)
                    rowsPerPage = 6;
                else
                    rowsPerPage = 5;
                NSInteger count = 0;
                if ([allSessions count] == 0)
                {
                    count = 1;
                }
                else
                {
                    count = [allSessions count]/rowsPerPage;
                    
                    if ([allSessions count]%rowsPerPage !=0)
                    {
                        count++;
                    }
                }
                self.pageControl.numberOfPages = count;
            }
        }
    }
}


#pragma mark - sessionBtnClicked Clicked
- (void)sessionBtnClicked:(UIButton*)sender
{
    HandsViewController *vc = [[HandsViewController alloc] init];
    Session *curSession = [allSessions objectAtIndex:sender.tag];
    if (curSession!=NULL)
    {
        [vc setHandsArray:curSession];
    }
    [[AppDelegate sharedAppDelegate].navigationController pushViewController:vc animated:YES];
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return CELL_DEFAULT_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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

- (IBAction)statsForSessionBtnClicked:(id)sender
{
    StatsForSessionViewController *vc = [[StatsForSessionViewController alloc] init];
    [[AppDelegate sharedAppDelegate].navigationController pushViewController:vc animated:YES];
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
