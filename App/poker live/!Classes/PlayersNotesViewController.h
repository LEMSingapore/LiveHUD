//
//  PlayersNotesViewController.h
//  Live Poker Stats
//
//  Created by Denis Senichkin on 2/28/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesViewController.h"

@interface PlayersNotesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, NotesViewControllerDelegate>
{
    AppDelegate *appDelegate;
    NSArray *allPlayers;
    
    NSInteger rowsPerPage;
    NotesViewController *notesVC;
}

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIButton *statsForSessionBtn;

@end
