//
//  BoardLandscapeViewController.h
//  Live Poker Stats
//
//  Created by Denis Senichkin on 3/5/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollViewExtended.h"
#import "DoubleComponentInPickerViewViewController.h"
#import "PickerVC.h"
#import "CardsPickerVC.h"
#import "AddLocationViewController.h"

#import "Session.h"
#import "SessionStats.h"

#import "NotesViewController.h"

@interface BoardLandscapeViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, DoubleComponentInPickerViewViewControllerDelegate, PickerVCDelegate, AddLocationViewControllerDelegate>
{
    AppDelegate *appDelegate;
    Settings *settings;
    
    NSMutableArray *players;
    
    DoubleComponentInPickerViewViewController *doublePicker;
    PickerVC *pickerVC;
    CardsPickerVC *cardsPickerVC;
    AddLocationViewController *addPlayersVC;
    
    NotesViewController *notesVC;
    
    NSInteger currentBU;
    float potSize;
    float currentMaxBet;
    NSInteger CELL_DEFAULT_HEIGHT;
    
    NSInteger startHeroMoney;
    BOOL heroInvestMoney;
    
    BOOL recalcStats;
    BOOL calcPlayerStats;
    
    Session *curSession;
    Hand *curHand;
    
    NSInteger previousPlayer;
    
    NSInteger playerPositionStatsCalculated;
    
    NSArray *cardAngles;
    NSArray *cardFrames;
    NSArray *statsLabelsFrames;
    NSArray *dealerBtnFrames;
    
    CGSize scrollInitialSize;
    
    NSInteger curMenuPlayerPosition;
    
    BOOL addRemovePlayersMode;
}

@property (weak, nonatomic) IBOutlet UITextField *allBets;

@property (weak, nonatomic) IBOutlet UITextField *menuStatsExtendedField;
@property (weak, nonatomic) IBOutlet UIImageView *menuStatsExtendedBkg;

- (void)makeBetForPlayer:(Player*)curPlayer newPlayerBet:(float)newPlayerBet;

- (NSInteger)firstPlayerInTradePosition;
- (NSInteger)currentPlayersCount;
- (NSInteger)firstNonEmptyPlayerPosition;
- (NSInteger)playerPositionForName:(NSString*)playerName;
- (float)getPreviousPlayerBetSize:(NSInteger)currentPlayerPosistion;
- (Player*)getPreviousPlayer:(NSInteger)currentPlayerPosistion;

- (void)showPlayerPickers;

- (void)setObjectsFrames;
- (void)addStatsBackgroundImages;

- (void)clearPlayerBets;
- (void)clearPlayerTotalBets;

-(void)recalculateALLbet;

- (void)changePlayerBetsToZero;
- (void)clearPlayerFolds;

- (void)newDealRoutine;

- (Player*)getPlayerWithIndex:(NSInteger)index;

- (void)showMenuWithPlayerInfo:(Player*)curPlayer;
- (void)showMenuForCurrentRoundTrade;
- (void)hideMenu;
- (void)autoFocusOnLabel:(UILabel*)statsLabel;

- (void)calcPlayerStats;
//- (void)recalculatePotSize:(float)oldBet newBet:(float)newBet;
- (void)recalculatePotSize;

- (void)setButtonsFrames:(BOOL)transformFrame;
- (void)setButtonsStyles;
- (void)createPlayersArray:(BOOL)checkSettings;

- (void)showPickerWithTitleAndTag:(NSString*)title tag:(NSInteger)tag;
- (void)showBUSelectPicker;

-(BOOL)ifPreflopStage;
-(BOOL)ifPlayerIsSB:(NSInteger)position;
-(BOOL)ifPlayerIsBB:(NSInteger)position;

- (void)refreshPlayersInfo;
- (void)refreshBULabelBorder;
- (void)resfreshMaxBetValue;
- (void)refreshCurStatsLabelBorder;

- (void)transformCardsToStartedPositions;
- (void)transformCardsToRotatedPositions;

- (void)betActionStatistic:(Player*)curPlayer;

- (void)changeAllStatsFieldsAlpha:(float)alpha;


- (BOOL)ifAddRemovePlayersModeEnabled;
- (void)addRemovePlayersModeChange:(BOOL)enable;


@property (weak, nonatomic) IBOutlet UIButton *addNote;

@property (weak, nonatomic) IBOutlet UIButton *dealBtn;
@property (weak, nonatomic) IBOutlet UIButton *winnerBtn;
@property (weak, nonatomic) IBOutlet UIButton *flopBtn;

@property (strong, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UITextField *betTextFiled;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *card1;
@property (weak, nonatomic) IBOutlet UIButton *card2;
@property (weak, nonatomic) IBOutlet UIButton *card3;
@property (weak, nonatomic) IBOutlet UIButton *card4;
@property (weak, nonatomic) IBOutlet UIButton *card5;

@property (weak, nonatomic) IBOutlet UITextField *potSizeField;
@property (weak, nonatomic) IBOutlet UIScrollViewExtended *contentView;
@property (weak, nonatomic) IBOutlet UIView *boardView;
@property (weak, nonatomic) IBOutlet UIImageView *boardImageView;
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UILabel *statsTextField0;
@property (weak, nonatomic) IBOutlet UILabel *statsTextField1;
@property (weak, nonatomic) IBOutlet UILabel *statsTextField2;
@property (weak, nonatomic) IBOutlet UILabel *statsTextField3;
@property (weak, nonatomic) IBOutlet UILabel *statsTextField4;
@property (weak, nonatomic) IBOutlet UILabel *statsTextField5;
@property (weak, nonatomic) IBOutlet UILabel *statsTextField6;

@property (weak, nonatomic) IBOutlet UILabel *statsTextField7;
@property (weak, nonatomic) IBOutlet UILabel *statsTextField8;
@property (weak, nonatomic) IBOutlet UILabel *statsTextField9;

@property (weak, nonatomic) IBOutlet UIButton *menuNextPlayerBtn;

@property (weak, nonatomic) IBOutlet UIButton *dealerBtn;

@property (weak, nonatomic) IBOutlet UIButton *card01;
@property (weak, nonatomic) IBOutlet UIButton *card02;
@property (weak, nonatomic) IBOutlet UIButton *card11;
@property (weak, nonatomic) IBOutlet UIButton *card12;
@property (weak, nonatomic) IBOutlet UIButton *card21;
@property (weak, nonatomic) IBOutlet UIButton *card22;
@property (weak, nonatomic) IBOutlet UIButton *card31;
@property (weak, nonatomic) IBOutlet UIButton *card32;
@property (weak, nonatomic) IBOutlet UIButton *card41;
@property (weak, nonatomic) IBOutlet UIButton *card42;
@property (weak, nonatomic) IBOutlet UIButton *card51;
@property (weak, nonatomic) IBOutlet UIButton *card52;
@property (weak, nonatomic) IBOutlet UIButton *card61;
@property (weak, nonatomic) IBOutlet UIButton *card62;
@property (weak, nonatomic) IBOutlet UIButton *card71;
@property (weak, nonatomic) IBOutlet UIButton *card72;
@property (weak, nonatomic) IBOutlet UIButton *card81;
@property (weak, nonatomic) IBOutlet UIButton *card82;
@property (weak, nonatomic) IBOutlet UIButton *card91;
@property (weak, nonatomic) IBOutlet UIButton *card92;

@property (weak, nonatomic) IBOutlet UITextField *menuNameField;
@property (weak, nonatomic) IBOutlet UITextField *menuStackField;
@property (weak, nonatomic) IBOutlet UITextField *menuStatsField;
@property (weak, nonatomic) IBOutlet UIButton *menuHide;

@property (weak, nonatomic) IBOutlet UIButton *betRaiseBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (weak, nonatomic) IBOutlet UIButton *foldBtn;
@property (weak, nonatomic) IBOutlet UIButton *raiseBtn;

@property (weak, nonatomic) IBOutlet UITextField *menuBetField;

@property (weak, nonatomic) IBOutlet UISlider *betSlider;

@property (weak, nonatomic) IBOutlet UIButton *betFirstBtn;
@property (weak, nonatomic) IBOutlet UIButton *betSecondBtn;
@property (weak, nonatomic) IBOutlet UIButton *betThirdBtn;
@property (weak, nonatomic) IBOutlet UIButton *betFourthBtn;


@end
