//
//  HandsViewController.h
//  Live Poker Stats
//
//  Created by Denis Senichkin on 3/1/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "Hand.h"

@interface HandsViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    AppDelegate *appDelegate;
    NSArray *allHands;
    
    NSInteger rowsPerPage;
    Session *CurSession;
}

- (void)setHandsArray:(Session*)curSession;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *sessionBtn;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *statsForSessionBtn;

- (IBAction)changePage:(id)sender;

@end
