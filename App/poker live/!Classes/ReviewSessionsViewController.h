//
//  ReviewSessionsViewController.h
//  Live Poker Stats
//
//  Created by Denis Senichkin on 2/28/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewSessionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    AppDelegate *appDelegate;
    NSArray *allSessions;
    
    NSInteger rowsPerPage;
}

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIButton *statsForSessionBtn;

@end
