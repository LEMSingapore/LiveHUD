//
//  PlayersNotesViewController.m
//  Live Poker Stats
//
//  Created by Denis Senichkin on 2/28/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "PlayersNotesViewController.h"
#import "SettingsViewController.h"
#import "StatsForSessionViewController.h"
#import "HandsViewController.h"
#import <QuartzCore/QuartzCore.h>

#define CELL_DEFAULT_HEIGHT 320

@interface PlayersNotesViewController ()

@end

@implementation PlayersNotesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        appDelegate = [AppDelegate sharedAppDelegate];
        allPlayers = [appDelegate.dataManager getAllPlayersNamesSortedByName:NO];
        
        NSUInteger index = [[allPlayers valueForKey:@"playerName"] indexOfObject:EMPTY_PLAYER_NAME];
        if (index < [allPlayers count])
        {
            NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:allPlayers];
            [temp removeObjectAtIndex:index];
            
            allPlayers = temp;
        }
        
        notesVC = [[NotesViewController alloc] initWithNibName:@"NotesViewController" bundle:nil];
        notesVC.delegate = self;
        
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
        rowsPerPage = 8;
    }
    else
    {
        rowsPerPage = 6;
    }
    
    NSInteger count = 0;
    if ([allPlayers count] == 0)
    {
        count = 1;
    }
    else
    {
        count = [allPlayers count]/rowsPerPage;
        
        if ([allPlayers count]%rowsPerPage !=0)
        {
            count++;
        }
    }
    
    self.pageControl.numberOfPages = count;
    
    notesVC.view.frame  = self.view.frame;
    [self.view addSubview:notesVC.view];
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
    if ([allPlayers count] == 0)
    {
        return 0;
    }
    
    NSInteger count = [allPlayers count]/rowsPerPage;
    
    if ([allPlayers count]%rowsPerPage !=0)
    {
        count++;
    }
    
    return  count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"indexPath = %@", indexPath);
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for(UIView *view in cell.contentView.subviews)
    {
            [view removeFromSuperview];
    }
    
    NSInteger count = [allPlayers count]/rowsPerPage;
    if ([allPlayers count]%rowsPerPage !=0)
    {
        count++;
    }
    
    if (indexPath.row < count)
    {
        NSInteger yOffset = 10;
        NSInteger onePieceHeight = 50;
        
        for (int i = 0; i < rowsPerPage; i++)
        {
            if (indexPath.row*rowsPerPage+i >= [allPlayers count])
            {
                break;
            }
            
            Player *curPlayer = [allPlayers objectAtIndex:indexPath.row*rowsPerPage+i];
            if (curPlayer != NULL)
            {
                UITextField *backLabel = [[UITextField alloc] initWithFrame:CGRectMake(0, yOffset-5, 320, onePieceHeight-10)];
                backLabel.borderStyle = UITextBorderStyleRoundedRect;
                backLabel.backgroundColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.8];
                backLabel.userInteractionEnabled = NO;
                backLabel.alpha = 1;
                [cell.contentView addSubview:backLabel];
                
                UITextField *playerName = [[UITextField alloc] initWithFrame:CGRectMake(15, yOffset, 160, 30)];
                playerName.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18];playerName.textColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
                playerName.textAlignment = NSTextAlignmentLeft;
                playerName.borderStyle = UITextBorderStyleNone;playerName.backgroundColor = [UIColor clearColor];
                playerName.userInteractionEnabled = NO;
                [cell.contentView addSubview:playerName];
                
                UIButton *checkBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                checkBoxBtn.frame = CGRectMake(220, yOffset, 80, 30);
                checkBoxBtn.backgroundColor = [UIColor clearColor];
                checkBoxBtn.tag = indexPath.row*rowsPerPage+i;
                checkBoxBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:14];
                [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"topMenuBtnBkg.png"] forState:UIControlStateNormal];
                [checkBoxBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                /*if (curPlayer.playerNotes == NULL || curPlayer.playerNotes.length == 0)
                {
                    [checkBoxBtn setTitle:@"Add a note" forState:UIControlStateNormal];
                }
                else
                {
                    [checkBoxBtn setTitle:@"Review a note" forState:UIControlStateNormal];
                }*/
                [checkBoxBtn setTitle:@"Notes" forState:UIControlStateNormal];
                
                [cell.contentView addSubview:checkBoxBtn];
                
                yOffset += onePieceHeight;
                
                NSString *strString1 = [NSString stringWithFormat:@"%@", curPlayer.playerName];
                
                playerName.text = strString1;
            }
        }
    }
    
    //self.pageControl.currentPage = indexPath.row;

    //rotate cell
    cell.transform = CGAffineTransformMakeRotation(90*M_PI/180.0);
    
    return cell;
}

#pragma mark - sessionBtnClicked Clicked
- (void)btnClicked:(UIButton*)sender
{
    NSInteger playerPosition = sender.tag;
    Player *curPlayer = [allPlayers objectAtIndex:playerPosition];
    [notesVC showWithPlayer:curPlayer animated:YES];
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

#pragma mark - Notes delegates
- (void)menuWillHide:(BOOL)animated
{
    if (animated && [allPlayers count] > 0 && rowsPerPage>0)
    {
        [self.myTableView reloadData];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
