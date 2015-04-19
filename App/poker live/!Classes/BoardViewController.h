//
//  BoardViewController.h
//  Poker Live
//
//  Created by Denis Senichkin on 2/14/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoubleComponentInPickerViewViewController.h"
#import "PickerVC.h"
#import "Session.h"
#import "SessionStats.h"
#import "CardsPickerVC.h"

@interface BoardViewController : UIViewController <CardsPickerVCDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DoubleComponentInPickerViewViewControllerDelegate, PickerVCDelegate>
{
    AppDelegate *appDelegate;
    Settings *settings;
    NSMutableDictionary *players;
    DoubleComponentInPickerViewViewController *doublePicker;
    PickerVC *pickerVC;
    CardsPickerVC *cardsPickerVC;
    
    NSInteger currentBU;
    NSInteger potSize;
    NSInteger currentMaxBet;
    NSInteger CELL_DEFAULT_HEIGHT;
    
    NSInteger startHeroMoney;
    BOOL heroInvestMoney;
    
    BOOL recalcStats;
    BOOL calcPlayerStats;
    
    Session *curSession;
    Hand *curHand;
}

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextField *betTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *potSizeField;

@property (weak, nonatomic) IBOutlet UIButton *card1;
@property (weak, nonatomic) IBOutlet UIButton *card2;
@property (weak, nonatomic) IBOutlet UIButton *card3;
@property (weak, nonatomic) IBOutlet UIButton *card4;
@property (weak, nonatomic) IBOutlet UIButton *card5;
@property (weak, nonatomic) IBOutlet UIButton *flopBtn;
@property (weak, nonatomic) IBOutlet UIButton *foldBtn;
@property (weak, nonatomic) IBOutlet UIButton *dealBtn;
@property (weak, nonatomic) IBOutlet UIButton *winnerBtn;
@property (weak, nonatomic) IBOutlet UIButton *betRaiseBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;

- (void)recalculatePotSize;
- (void)showBUSelectPicker;
- (void)makeSBAndBBBets;
- (void)clearPlayerBets;

- (void)calcPlayerStats;

- (void)showPickerWithTitleAndTag:(NSString*)title tag:(NSInteger)tag;


-(BOOL)ifPreflopStage;

-(BOOL)ifPlayerIsSB:(NSInteger)position;
-(BOOL)ifPlayerIsBB:(NSInteger)position;

@end
