//
//  HandsViewController.m
//  Live Poker Stats
//
//  Created by Denis Senichkin on 3/1/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "HandsViewController.h"
#import "SettingsViewController.h"
#import "StatsForSessionViewController.h"
#import <QuartzCore/QuartzCore.h>

#define CELL_DEFAULT_HEIGHT 320

@interface HandsViewController ()

@end

@implementation HandsViewController

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
    [self setSessionBtn:nil];
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
        rowsPerPage = 7;
    }
    else
    {
        rowsPerPage = 5;
    }
    
    NSInteger count = 0;
    
    if ([allHands count] == 0)
    {
        count = 1;
    }
    else
    {
        count = [allHands count]/rowsPerPage;
        
        if ([allHands count]%rowsPerPage !=0)
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

- (void)setHandsArray:(Session*)curSession
{
    NSMutableArray *hands = [NSMutableArray new];
    
    CurSession = curSession;
    
    [hands addObjectsFromArray:[curSession.hands allObjects]];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"handNumber" ascending:YES];
    [hands sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    allHands = hands;
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


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([allHands count] == 0)
    {
        return 0;
    }
    
    NSInteger count = [allHands count]/rowsPerPage;
    
    if ([allHands count]%rowsPerPage !=0)
    {
        count++;
    }
    
    return  count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    NSInteger count = [allHands count]/rowsPerPage;
    if ([allHands count]%rowsPerPage !=0)
    {
        count++;
    }
    
    if (indexPath.row < count)
    {
        NSInteger yOffset = 10;
        NSInteger onePieceHeight = 35;
        
        for (int i = 0; i < rowsPerPage; i++)
        {
            if (indexPath.row*rowsPerPage+i >= [allHands count])
            {
                break;
            }
            
            Hand *curHand = [allHands objectAtIndex:indexPath.row*rowsPerPage+i];
            if (curHand != NULL)
            {
                /*UITextField *backLabel = [[UITextField alloc] initWithFrame:CGRectMake(0, yOffset-5, 320, onePieceHeight-10)];
                backLabel.borderStyle = UITextBorderStyleRoundedRect;
                backLabel.backgroundColor = [UIColor colorWithRed:54/255.0 green:54/255.0 blue:54/255.0 alpha:1];
                backLabel.alpha = 0.6;
                [cell.contentView addSubview:backLabel];*/
                
                UIImageView *separator= [[UIImageView alloc] initWithFrame:CGRectMake(40, yOffset, 15, 15)];
                separator.image = [UIImage imageNamed:@"greenBallBkg.png"];
                [cell.contentView addSubview:separator];
                
                UITextField *handField = [[UITextField alloc] initWithFrame:CGRectMake(60, yOffset, 160, 20)];
                handField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:12];handField.textColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
                handField.textAlignment = NSTextAlignmentLeft;handField.userInteractionEnabled = NO;
                handField.borderStyle = UITextBorderStyleNone;handField.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:handField];
                
                yOffset += onePieceHeight;
                
                NSString *handFieldTextString = [NSString stringWithFormat:@"%@ (%0.2f BB)", curHand.handName, [curHand.handBBwon floatValue]];
                handField.text = handFieldTextString;
                
            }
        }
    }
    
    //self.pageControl.currentPage = indexPath.row;
    
    //rotate cell
    cell.transform = CGAffineTransformMakeRotation(90*M_PI/180.0);
    
    return cell;
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

- (IBAction)statsForSessionBtnClicked:(id)sender
{
    StatsForSessionViewController *vc = [[StatsForSessionViewController alloc] init];
    [[AppDelegate sharedAppDelegate].navigationController pushViewController:vc animated:YES];
    [vc setCurStat:CurSession.sessionStats];

}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
