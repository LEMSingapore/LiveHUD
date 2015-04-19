//
//  BoardLandscapeViewController.m
//  Live Poker Stats
//
//  Created by Denis Senichkin on 3/5/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "BoardLandscapeViewController.h"
#import <QuartzCore/QuartzCore.h>



#define CUR_LABEL_BORDER 400

#define MENU_TAG_OFFSET 400
#define LABEL_OFFSET 200
#define LABEL_BKG_OFFSET 250
#define CHIP_OFFSET 300
#define BOARD_CARD_OFFSET 101

#define FIRST_CARD_OFFSET 1
#define SECOND_CARD_OFFSET 2

#define PICKER_WINNER 1
#define PICKER_BU 2
#define PICKER_BET_RAISE 3
#define PICKER_CHECK 4
#define PICKER_FOLDED 9
#define ADD_PLAYERS 5

#define CARD_WIDTH 18
#define CARD_HEIGTH 29

#define STATS_WIDTH 94
#define STATS_HEIGTH 42

#define DEALER_BTN_HEIGTH 15
#define DEALER_BTN_WIDTH 15

@interface BoardLandscapeViewController ()

@end

@implementation BoardLandscapeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = [AppDelegate sharedAppDelegate];
        settings = [appDelegate.dataManager getSettingsEntry];
        players = [NSMutableArray new];
        
        doublePicker = [[DoubleComponentInPickerViewViewController alloc] initWithNibName:@"DoubleComponentInPickerViewViewController" bundle:nil];
        doublePicker.delegate = self;

        pickerVC = [[PickerVC alloc] initWithNibName:@"PickerVC" bundle:nil];
        pickerVC.delegate = self;
        
        cardsPickerVC = [[CardsPickerVC alloc] initWithNibName:@"CardsPickerVC" bundle:nil];
        cardsPickerVC.delegate = self;
        
        addPlayersVC = [[AddLocationViewController alloc] init];
        [addPlayersVC setPickerType:PLAYERS_PICKER showHeroName:YES];
        addPlayersVC.delegate = self;
        
        notesVC = [[NotesViewController alloc] initWithNibName:@"NotesViewController" bundle:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:HANDS_UNLIMITED_NAME] != NULL)
    {
        BOOL unlim = [defaults boolForKey:HANDS_UNLIMITED_NAME];
        
        if (unlim)
        {
            self.menuStatsExtendedBkg.hidden = NO;
            self.menuStatsExtendedField.hidden = NO;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    /*for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        //UILabel *statsLabel;
        //statsLabel = (UILabel*)[self.boardView viewWithTag:i+LABEL_OFFSET];
        //NSLog(@"[NSValue valueWithCGRect:CGRectMake(%.0f, %.0f, STATS_WIDTH, STATS_HEIGTH)],", statsLabel.frame.origin.x, statsLabel.frame.origin.y);
        
        UIButton *card1 = (UIButton*)[self.boardView viewWithTag:i*10+FIRST_CARD_OFFSET];
        UIButton *card2 = (UIButton*)[self.boardView viewWithTag:i*10+SECOND_CARD_OFFSET];
        NSLog(@"[NSValue valueWithCGRect:CGRectMake(%.0f, %.0f, CARD_WIDTH, CARD_HEIGTH)],", card1.frame.origin.x, card1.frame.origin.y);
        NSLog(@"[NSValue valueWithCGRect:CGRectMake(%.0f, %.0f, CARD_WIDTH, CARD_HEIGTH)],", card2.frame.origin.x, card2.frame.origin.y);
    }*/
    
    //[self setObjectsFrames];
    //[self setButtonsFrames];
    [self changeAllStatsFieldsAlpha:0];
    [self setObjectsFrames];
    [self addStatsBackgroundImages];
    
    [UIView animateWithDuration:1.2 animations:^
     {
         [self setButtonsFrames:NO];
         [self changeAllStatsFieldsAlpha:1];
     }
     completion:^(BOOL finished)
     {
         
     }];
    
    self.view.frame = CGRectMake(0, 0, appDelegate.window.frame.size.height, appDelegate.window.frame.size.width);
    
    if (IS_IPHONE_5)
    {
        CGRect frame = self.boardImageView.frame;
        //frame.size.width = frame.size.width*1.22;
        frame.size.height = frame.size.height*1;
        frame.origin.x = (self.boardView.frame.size.width - frame.size.width)/2;
        frame.origin.y = (self.boardView.frame.size.height - frame.size.height)/2;
        self.boardImageView.frame = frame;
        
        frame = self.menuView.frame;
        frame.size.width = self.boardView.frame.size.width;
        self.menuView.frame = frame;
    }
    
    [self.contentView setContentSize:CGSizeMake(self.boardView.frame.size.width, self.boardView.frame.size.height)];
    scrollInitialSize = self.contentView.contentSize;
    //self.boardView.frame = CGRectMake(0, 0, self.boardView.frame.size.width, self.boardView.frame.size.height + self.menuView.frame.size.height);
    self.boardView.frame = CGRectMake(0, 0, self.boardView.frame.size.width, self.boardView.frame.size.height);
    
    [self.topView addSubview:self.menuView];
    [self.topView bringSubviewToFront:self.menuView];
    self.menuView.hidden = YES;
    
    doublePicker.view.frame  = self.view.frame;
    [self.view addSubview:doublePicker.view];
    doublePicker.view.hidden = YES;
    
    pickerVC.view.frame  = self.view.frame;
    [self.view addSubview:pickerVC.view];

    cardsPickerVC.view.frame  = self.view.frame;
    [self.view addSubview:cardsPickerVC.view];
    
    addPlayersVC.view.frame  = self.view.frame;
    [self.view addSubview:addPlayersVC.view];
    
    notesVC.view.frame  = self.view.frame;
    [self.view addSubview:notesVC.view];
    
    recalcStats = YES;
    calcPlayerStats = NO;
    currentMaxBet = [settings.settingsMaxLimit integerValue];
    self.potSizeField.text = @"POT: 0";
    self.betTextFiled.text = [settings getMinMaxLimitString];

    [self createPlayersArray:YES];
    [self setButtonsStyles];
    //[self changePlayerBetsToZero];
    [self clearPlayerBets];
    [self clearPlayerFolds];
    
    currentBU = -1;
    
    [self refreshPlayersInfo];
    [self refreshBULabelBorder];
    
    [self addRemovePlayersModeChange:YES];
    //NSLog(@"view = %@, topView = %@", NSStringFromCGRect(self.view.frame), NSStringFromCGRect(self.topView.frame));
    //NSLog(@"boardImageView = %@, boardView = %@", NSStringFromCGRect(self.boardImageView.frame), NSStringFromCGRect(self.boardView.frame));
    //[self.boardImageView setCenter:CGPointMake(self.boardView.frame.size.width / 2, self.boardView.frame.size.height / 2)];
    //NSLog(@"boardImageView = %@", NSStringFromCGRect(self.boardImageView.frame));
}


- (void) keyboardWillShow:(NSNotification *)notification
{
    /*CGSize keyboardSize = [[[notification userInfo]
                            objectForKey:UIKeyboardFrameBeginUserInfoKey]
                           CGRectValue].size;
    
    UIInterfaceOrientation orientation =  [[UIApplication sharedApplication] statusBarOrientation];
    
    CGSize size = self.view.frame.size;
	
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown )
    {
        self.potSizeField.frame = CGRectMake(0, 0, size.width, size.height - keyboardSize.height + 50);
    }
    else
    {
        //Note that the keyboard size is not oriented
        //so use width property instead
        self.potSizeField.frame = CGRectMake(0, 0,size.width, size.height - keyboardSize.width + 50);
    }
     */
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //self.potSizeField.frame = CGRectMake(0, 0,self.view.frame.size.width,self.view.frame.size.height + 25);
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollVieww
{
	return self.boardView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)orientationChanged:(NSNotification *)notification
{
/*    //NSLog(@"[UIDevice currentDevice].orientation = %d", [UIDevice currentDevice].orientation);
    CGFloat radians = atan2f(self.topView.transform.b, self.topView.transform.a);
    CGFloat degrees = radians * (180 / M_PI);
    NSLog(@"degrees = %f", degrees);
  
    
    if ([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight && degrees!= 90)
    {
        [UIView animateWithDuration:0.3 animations:^
         {
             NSLog(@"UIInterfaceOrientationLandscapeRight %@", self.topView);
             self.topView.transform = CGAffineTransformMakeRotation(0*M_PI/180.0);
             self.topView.transform = CGAffineTransformMakeRotation(180*M_PI/180.0);
         }
                         completion:^(BOOL finished)
         {
             //[imageView removeFromSuperview];
         }];
        

    }
    else if ([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft && degrees!=-90)
    {
        [UIView animateWithDuration:0.3 animations:^
         {
             NSLog(@"UIInterfaceOrientationLandscapeLeft %@", self.topView);
             self.topView.transform = CGAffineTransformMakeRotation(0*M_PI/180.0);
             self.topView.transform = CGAffineTransformMakeRotation(-180*M_PI/180.0);
         }
                         completion:^(BOOL finished)
         {
             //[imageView removeFromSuperview];
         }];
    }*/
}

#pragma mark - Initital player work
- (void)createPlayersArray:(BOOL)checkSettings
{
    for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        NSString *playerName;
        UILabel *statsLabel;

        if (i < [settings getNumberOfPlayers])
        {
            NSString *settingsPlayerName = [NSString stringWithFormat:@"settingsPlayer%d", i];
            playerName = [settings valueForKey:settingsPlayerName];
        }

        Player *curPlayer;
        if (playerName != NULL)
        {
            curPlayer  = [appDelegate.dataManager getPlayerByName:playerName];
        }
        else
        {
            playerName = EMPTY_PLAYER_NAME;
            NSString *settingsPlayerName = [NSString stringWithFormat:@"settingsPlayer%d", i];
            [settings setValue:playerName forKey:settingsPlayerName];
            curPlayer  = [appDelegate.dataManager getPlayerByName:playerName];
        }
        
        if (curPlayer != NULL)
        {
            [players addObject:curPlayer];
        }
        
        if (![curPlayer isPlayerIsOpenSeat])
        {
            
            statsLabel = (UILabel*)[self.boardView viewWithTag:i+LABEL_OFFSET];
            statsLabel.hidden = NO;
            
            if (statsLabel != NULL)
            {
                //[[statsLabel layer] setBorderWidth:1.0f];
                //[[statsLabel layer] setBorderColor:[UIColor colorWithRed:85.0/255 green:85.0/255 blue:85.0/255 alpha:0.3].CGColor];
                NSString *strStats = [NSString stringWithFormat:@"%@\n%@ | %@\n%@", curPlayer.playerName, [curPlayer.playerBetSize stringValue], [curPlayer.playerStackSize stringValue], [curPlayer getPlayerStatistic]];
                statsLabel.text = strStats;
            }
            
            curPlayer.playerCard1 = NULL;
            curPlayer.playerCard2 = NULL;
        }
        else
        {
            //statsLabel.backgroundColor = [UIColor colorWithRed:55.0/255 green:55.0/255 blue:55.0/255 alpha:1.0];
            //[[statsLabel layer] setBorderWidth:1.0f];
            //[[statsLabel layer] setBorderColor:[UIColor colorWithRed:85.0/255 green:85.0/255 blue:85.0/255 alpha:1.0].CGColor];
            UIImage *bkgImage = [UIImage imageNamed:@"statOpenSeatBkg.png"];
            UIImageView *statBackground = (UIImageView*)[self.boardView viewWithTag: i+LABEL_BKG_OFFSET];
            statBackground.image = bkgImage;
            
            //statsLabel.text = EMPTY_PLAYER_NAME;
            statsLabel.text = @"";
        }
    }
    
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        
        if (curPlayer != NULL && ![curPlayer isPlayerIsOpenSeat])
        {
            UIButton *card1 = (UIButton*)[self.boardView viewWithTag:i*10+FIRST_CARD_OFFSET];
            card1.hidden = YES;card1.userInteractionEnabled = NO;
            [card1 addTarget:self action:@selector(boardCardClicked:) forControlEvents:UIControlEventTouchUpInside];
            [card1 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
            
            UIButton *card2 = (UIButton*)[self.boardView viewWithTag:i*10+SECOND_CARD_OFFSET];
            card2.hidden = YES;card2.userInteractionEnabled = NO;
            [card2 addTarget:self action:@selector(boardCardClicked:) forControlEvents:UIControlEventTouchUpInside];
            [card2 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
        }
    }
}

- (void)refreshPlayersInfo
{
    for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        UILabel *statsLabel = (UILabel*)[self.boardView viewWithTag: i+LABEL_OFFSET];
        Player *curPlayer = [self getPlayerWithIndex:i];
        
        if (curPlayer != NULL && ![curPlayer isPlayerIsOpenSeat])
        {
            if (statsLabel != NULL)
            {
                NSString *betStr;
                
                if ([curPlayer.playerFoldedCards boolValue])
                {
                    betStr = @"FOLD";
                }
                else if ([curPlayer.playerBetSize floatValue] == 0)
                {
                    //betStr = [curPlayer.playerBetSize stringValue];
                    betStr = @"0";
                }
                else
                {
                    if ([self ifPreflopStage])
                    {
                        betStr = [NSString stringWithFormat:@"%.1f BB", [curPlayer.playerBetSize floatValue]/[settings.settingsMaxLimit floatValue]];
                    }
                    else
                    {
                        betStr = [NSString stringWithFormat:@"%.0f%%", ((float)[curPlayer.playerBetSize floatValue]*100.0)/potSize];
                    }
                }
                
                //statsLabel.backgroundColor = [UIColor colorWithRed:55.0/255 green:55.0/255 blue:55.0/255 alpha:1.0];
                //[[statsLabel layer] setBorderWidth:1.0f];
                //[[statsLabel layer] setBorderColor:[UIColor colorWithRed:85.0/255 green:85.0/255 blue:85.0/255 alpha:1.0].CGColor];
                
                NSString *strStats = [NSString stringWithFormat:@"%@\n%@ | %@\n%@", curPlayer.playerName, betStr, [curPlayer.playerStackSize stringValue], [curPlayer getPlayerStatistic]];
                statsLabel.text = strStats;
                
                UIImage *bkgImage = [UIImage imageNamed:@"statPlayerBkg.png"];
                UIImageView *statBackground = (UIImageView*)[self.boardView viewWithTag:i+LABEL_BKG_OFFSET];
                statBackground.image = bkgImage;
                
                /*if (currentBU >= 0)
                {
                    if ([self ifPlayerIsSB:i])
                    {
                        statsLabel.backgroundColor = [UIColor colorWithRed:1280.0/255 green:80.0/255 blue:180.0/255 alpha:0.5];
                    }
                    
                    if ([self ifPlayerIsBB:i])
                    {
                        statsLabel.backgroundColor = [UIColor colorWithRed:2013.0/255 green:205.0/255 blue:106.0/255 alpha:0.5];
                    }
                }*/
            }
            
            //curPlayer.playerCard1 = NULL;
            //curPlayer.playerCard2 = NULL;
        }
        else
        {
            //statsLabel.backgroundColor = [UIColor colorWithRed:55.0/255 green:55.0/255 blue:55.0/255 alpha:1.0];
            //[[statsLabel layer] setBorderWidth:1.0f];
            //[[statsLabel layer] setBorderColor:[UIColor colorWithRed:85.0/255 green:85.0/255 blue:85.0/255 alpha:1.0].CGColor];
            ///UIImage *bkgImage = [UIImage imageNamed:@"statOpenSeatBkg.png"];
            ///UIImageView *statBackground = (UIImageView*)[self.boardView viewWithTag: i+LABEL_BKG_OFFSET];
            ///statBackground.image = bkgImage;
            
            //statsLabel.text = EMPTY_PLAYER_NAME;
            statsLabel.text = @"";
            
            UIImage *bkgImage = [UIImage imageNamed:@"statOpenSeatBkg.png"];
            UIImageView *statBackground = (UIImageView*)[self.boardView viewWithTag: i+LABEL_BKG_OFFSET];
            statBackground.image = bkgImage;
        }
    }
    
    [self refreshCurStatsLabelBorder];
}

- (void)refreshBULabelBorder
{
    /*if (currentBU >= 0)
    {
        UILabel *statsLabel = (UILabel*)[self.boardView viewWithTag:currentBU+LABEL_OFFSET];
        [[statsLabel layer] setBorderWidth:2.0f];
        [[statsLabel layer] setBorderColor:[UIColor yellowColor].CGColor];
        
        //statsLabel.backgroundColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:0.5];
    }
    */
    

    /*
     CGFloat borderWidth = 4.0;
     [[myView layer] setBorderWidth:borderWidth];
     
     CALayer *mask = [CALayer layer];
     // The mask needs to be filled to mask
     [mask setBackgroundColor:[[UIColor blackColor] CGColor]];
     // Make the masks frame smaller in height
     CGRect maskFrame = CGRectInset([myView bounds], 0, borderWidth);
     // Move the maskFrame to the top
     maskFrame.origin.y = 0;
     [mask setFrame:maskFrame];
     [[myView layer] setMask:mask];
     */
}

- (void)refreshCurStatsLabelBorder
{
    NSInteger curPlayerTag = self.menuView.tag - MENU_TAG_OFFSET;
    
    /*if (curPlayerTag >= 0)
    {
        UILabel *borderLabel = (UILabel*)[self.boardView viewWithTag:CUR_LABEL_BORDER];
        [borderLabel removeFromSuperview];
        
        UILabel *statsLabel = (UILabel*)[self.boardView viewWithTag:curPlayerTag+LABEL_OFFSET];
        borderLabel = [[UILabel alloc] initWithFrame:CGRectMake(statsLabel.frame.origin.x - 3, statsLabel.frame.origin.y - 3, statsLabel.frame.size.width + 6, statsLabel.frame.size.height + 6)];
        borderLabel.backgroundColor = [UIColor colorWithRed:0.0/255 green:255.0/255 blue:0.0/255 alpha:0.1];
        borderLabel.tag = CUR_LABEL_BORDER;
        [[borderLabel layer] setBorderWidth:2.0f];
        [[borderLabel layer] setBorderColor:[UIColor whiteColor].CGColor];
        [self.boardView addSubview:borderLabel];
    }*/
    
    if (curPlayerTag >= 0)
    {
        for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
        {
            Player *curPlayer  = [self getPlayerWithIndex:i];
            
            if (![curPlayer isPlayerIsOpenSeat])
            {
                if (i == curPlayerTag)
                {
                    UIImage *bkgImage = [UIImage imageNamed:@"statPlayerSelectedBkg.png"];
                    UIImageView *statBackground = (UIImageView*)[self.boardView viewWithTag:i+LABEL_BKG_OFFSET];
                    statBackground.image = bkgImage;
                }
                else
                {
                    UIImage *bkgImage = [UIImage imageNamed:@"statPlayerBkg.png"];
                    UIImageView *statBackground = (UIImageView*)[self.boardView viewWithTag:i+LABEL_BKG_OFFSET];
                    statBackground.image = bkgImage;
                }
            }
            /*else
            {
                UIImage *bkgImage = [UIImage imageNamed:@"statOpenSeatBkg.png"];
                UIImageView *statBackground = (UIImageView*)[self.boardView viewWithTag: i+LABEL_BKG_OFFSET];
                statBackground.image = bkgImage;
            }*/
        }
    }
}

#pragma mark - Button Frames
- (void)setButtonsFrames:(BOOL)transformFrame
{
    if (currentBU < [dealerBtnFrames count])
    {
        self.dealerBtn.frame = [[dealerBtnFrames objectAtIndex:currentBU] CGRectValue];
    }
    
    for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        //player cards 1 and 2
        UIButton *card1 = (UIButton*)[self.boardView viewWithTag:i*10+FIRST_CARD_OFFSET];
        UIButton *card2 = (UIButton*)[self.boardView viewWithTag:i*10+SECOND_CARD_OFFSET];
        
        UILabel *label = (UILabel*)[self.boardView viewWithTag:i+LABEL_OFFSET];
        
        //Set frames
        label.hidden = NO;
        //card1.hidden = NO;
        //card2.hidden = NO;
        
        if (i < [statsLabelsFrames count])
        {
            CGRect frame = [[statsLabelsFrames objectAtIndex:i] CGRectValue];
            
            if (IS_IPHONE_5 && transformFrame)
            {
                //frame.origin.x = (float)frame.origin.x * (568.0/480.0);
                frame.origin.x = (float)frame.origin.x * 1.22;
                //label.frame = frame;
            }
            
            label.frame = frame;
            
            UIImageView *statBackground = (UIImageView*)[self.boardView viewWithTag:i+LABEL_BKG_OFFSET];
            if (statBackground!= NULL)
            {
                statBackground.frame = CGRectMake(frame.origin.x-10, frame.origin.y-10, statBackground.frame.size.width, statBackground.frame.size.height);
                statBackground.autoresizingMask = label.autoresizingMask;
                statBackground.hidden = label.hidden;
            }
        }
        
        if (i*2 < [cardFrames count])
        {
            CGRect frame  = [[cardFrames objectAtIndex:i*2] CGRectValue];
            
            if (IS_IPHONE_5 && transformFrame)
            {
                //frame.origin.x = (float)frame.origin.x * (568.0/480.0);
                frame.origin.x = (float)frame.origin.x * 1.22;
                //frame.origin.x = frame.origin.x - 1;
                //frame.origin.y = frame.origin.y - 1;
                //card1.frame = frame;
            }
            
            card1.frame = frame;
        }
        
        if (i*2+1 < [cardFrames count])
        {
            CGRect frame = [[cardFrames objectAtIndex:i*2+1] CGRectValue];
            
            if (IS_IPHONE_5 && transformFrame)
            {
                //frame.origin.x = (float)frame.origin.x * (568.0/480.0);
                frame.origin.x = (float)frame.origin.x * 1.22;
                //frame.origin.x = frame.origin.x + 1;
                //frame.origin.y = frame.origin.y - 1;
                //card2.frame = frame;
            }
            
            card2.frame = frame;
        }
    }
}

#pragma mark - Stats Fields
- (void)changeAllStatsFieldsAlpha:(float)alpha
{

    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
    {
        UILabel *statsLabel = (UILabel*)[self.boardView viewWithTag:i+LABEL_OFFSET];
        statsLabel.alpha = alpha;
        
        UIImageView *statBackground = (UIImageView*)[self.boardView viewWithTag:i+LABEL_BKG_OFFSET];
        if (statBackground != NULL)
        {
            statBackground.alpha = alpha;
        }
    }

}


#pragma mark - Button Styles
- (void)setButtonsStyles
{
    //for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
    for(int i=0; i < 10; i++)
    {
        //board card 1-5
        UIButton *boardCard = (UIButton*)[self.boardView viewWithTag:i+BOARD_CARD_OFFSET];
        boardCard.titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        boardCard.titleLabel.textAlignment = UITextAlignmentCenter;

        //player cards 1 and 2
        UIButton *card1 = (UIButton*)[self.boardView viewWithTag:i*10+FIRST_CARD_OFFSET];
        UIButton *card2 = (UIButton*)[self.boardView viewWithTag:i*10+SECOND_CARD_OFFSET];
        
        card1.titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        card1.titleLabel.textAlignment = UITextAlignmentCenter;
        card2.titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        card2.titleLabel.textAlignment = UITextAlignmentCenter;
        
        UILabel *label = (UILabel*)[self.boardView viewWithTag:i+LABEL_OFFSET];
        //label.backgroundColor = [UIColor colorWithRed:55.0/255 green:55.0/255 blue:55.0/255 alpha:1.0];
        label.backgroundColor = [UIColor clearColor];
        //[[label layer] setBorderWidth:1.0f];
        //[[label layer] setBorderColor:[UIColor colorWithRed:85.0/255 green:85.0/255 blue:85.0/255 alpha:1.0].CGColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chipBtnClicked:)];
        tapGesture.cancelsTouchesInView  = NO;
        [label addGestureRecognizer:tapGesture];
    }
    
    [self transformCardsToRotatedPositions];
}

- (void)addStatsBackgroundImages
{
    //for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
    for(int i=0; i < 10; i++)
    {
        UILabel *label = (UILabel*)[self.boardView viewWithTag:i+LABEL_OFFSET];
        CGRect frame = label.frame;
        
        UIImageView *statBackgroundTmp = (UIImageView*)[self.boardView viewWithTag: i+LABEL_BKG_OFFSET];
        if (statBackgroundTmp != NULL)
        {
            [statBackgroundTmp removeFromSuperview];
        }
        
        UIImage *bkgImage = [UIImage imageNamed:@"statPlayerBkg.png"];
        UIImageView *statBackground = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x-10, frame.origin.y-10, bkgImage.size.width/2, bkgImage.size.height/2)];
        //NSLog(@"statBackground.frame = %@", NSStringFromCGRect(statBackground.frame));
        statBackground.autoresizingMask = label.autoresizingMask;
        statBackground.tag = i + LABEL_BKG_OFFSET;
        //NSLog(@"statBackground.tag = %d", statBackground.tag);
        statBackground.image = bkgImage;
        [self.boardView addSubview:statBackground];
        [self.boardView bringSubviewToFront:label];
        statBackground.hidden = label.hidden;
    }
}

#pragma mark - Orientation
-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (IBAction)backBtnClicked:(id)sender
{
    //[appDelegate.navigationController popViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:@"End Current Session?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *title = [[alertView buttonTitleAtIndex:buttonIndex] lowercaseString];
    if ([title isEqualToString:@"ok"])
    {
        [appDelegate.navigationController popToRootViewControllerAnimated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [appDelegate changeShowModalVCFlag:NO];
        [appDelegate.navigationController dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Board Card Clicked
- (IBAction)boardCardClicked:(UIButton*)sender
{
    /*[doublePicker.mpicker reloadAllComponents];
    doublePicker.view.tag = sender.tag;
    doublePicker.view.hidden = NO;
     */
    
    
    if (self.card4.hidden == YES && sender.tag >= 101 && sender.tag <=105)
    {
        NSArray *savedCards = [NSArray arrayWithObjects:settings.settingsCard1, settings.settingsCard2, settings.settingsCard3, NULL];
        
        settings.settingsCard1 = NULL;
        settings.settingsCard2 = NULL;
        settings.settingsCard3 = NULL;
        
        NSString *allUsedCards = [settings getAllBoardCardsFromPlayersArray:players];
        
        [cardsPickerVC showWithTitle:@"Select three flop cards." lockBackground:YES animated:YES boardCards:allUsedCards];
        [cardsPickerVC setSavedCards:savedCards];
        cardsPickerVC.numberOfCards = 3;
        cardsPickerVC.tag = 101;
        cardsPickerVC.delegate = self;
        
    }
    else if (self.card5.hidden == YES && sender.tag >= 101 && sender.tag <=105)
    {
        NSArray *savedCards = [NSArray arrayWithObjects:settings.settingsCard4, NULL];
        settings.settingsCard4 = NULL;
        
        NSString *allUsedCards = [settings getAllBoardCardsFromPlayersArray:players];
        
        [cardsPickerVC showWithTitle:@"Select one turn card." lockBackground:YES animated:YES boardCards:allUsedCards];
        [cardsPickerVC setSavedCards:savedCards];
        cardsPickerVC.numberOfCards = 1;
        cardsPickerVC.tag = 102;
        cardsPickerVC.delegate = self;
    }
    else if (self.card5.hidden == NO && sender.tag >= 101 && sender.tag <=105)
    {
        NSArray *savedCards = [NSArray arrayWithObjects:settings.settingsCard5, NULL];
        settings.settingsCard5 = NULL;
        
        NSString *allUsedCards = [settings getAllBoardCardsFromPlayersArray:players];
        
        [cardsPickerVC showWithTitle:@"Select one river card." lockBackground:YES animated:YES boardCards:allUsedCards];
        [cardsPickerVC setSavedCards:savedCards];
        cardsPickerVC.numberOfCards = 1;
        cardsPickerVC.tag = 103;
        cardsPickerVC.delegate = self;
    }
    else
    {
        NSInteger playerTag = sender.tag/10;
        Player *curPlayer = [self getPlayerWithIndex:playerTag];
        
        if (curPlayer!= NULL)
        {
            NSString *title = [NSString stringWithFormat:@"Select two cards for %@", curPlayer.playerName];
            
            NSArray *savedCards = [NSArray arrayWithObjects:curPlayer.playerCard1, curPlayer.playerCard2, NULL];
            curPlayer.playerCard1 = NULL;
            curPlayer.playerCard2 = NULL;
            
            NSString *allUsedCards = [settings getAllBoardCardsFromPlayersArray:players];
            
            [cardsPickerVC showWithTitle:title lockBackground:YES animated:YES boardCards:allUsedCards];
            [cardsPickerVC setSavedCards:savedCards];
            cardsPickerVC.numberOfCards = 2;
            cardsPickerVC.tag = sender.tag;
            cardsPickerVC.delegate = self;
        }
    }
}

#pragma mark - CardsVC Delegate Methods
- (void)cardsPickerVCDoneButtonClicked:(CardsPickerVC *)pickerView
{
    NSLog(@"cardsPickerVCDoneButtonClicked = %@", pickerView.cardsLabel.text);
    
    if (pickerView.tag == 101)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        int len=0;
        
        NSString *cardsString = [pickerView getCardsString];
        
        while((len+2)< [cardsString length])
        {
            [array addObject:[cardsString substringWithRange:NSMakeRange(len,2)]];
            len+=2;
        }
        
        [array addObject:[cardsString substringFromIndex:len]];
        
        if ([array count] == 3)
        {
            NSString *cardTitle = [array objectAtIndex:0];
            if (cardTitle.length == 2)
            {
                cardTitle = [NSString stringWithFormat:@"%@\n%@", [cardTitle substringToIndex:1], [cardTitle substringFromIndex:1]];
            }
            
            [self.card1 setTitle:cardTitle forState:UIControlStateNormal];
            [self.card1 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
            settings.settingsCard1 = [array objectAtIndex:0];
            
            cardTitle = [array objectAtIndex:1];
            if (cardTitle.length == 2)
            {
                cardTitle = [NSString stringWithFormat:@"%@\n%@", [cardTitle substringToIndex:1], [cardTitle substringFromIndex:1]];
            }
            
            [self.card2 setTitle:cardTitle forState:UIControlStateNormal];
            [self.card2 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
            settings.settingsCard2 = [array objectAtIndex:1];
            
            cardTitle = [array objectAtIndex:2];
            if (cardTitle.length == 2)
            {
                cardTitle = [NSString stringWithFormat:@"%@\n%@", [cardTitle substringToIndex:1], [cardTitle substringFromIndex:1]];
            }
            
            [self.card3 setTitle:cardTitle forState:UIControlStateNormal];
            [self.card3 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
            
            settings.settingsCard3 = [array objectAtIndex:2];
            
            [appDelegate.dataManager saveCoreData];
        }
    }
    else if (pickerView.tag == 102)
    {
        NSString *cardTitle = [pickerView getCardsString];
        if (cardTitle.length == 2)
        {
            cardTitle = [NSString stringWithFormat:@"%@\n%@", [cardTitle substringToIndex:1], [cardTitle substringFromIndex:1]];
        }
        
        [self.card4 setTitle:cardTitle forState:UIControlStateNormal];
        [self.card4 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
        settings.settingsCard4 = [pickerView getCardsString];
        
        [appDelegate.dataManager saveCoreData];
    }
    else if (pickerView.tag == 103)
    {
        NSString *cardTitle = [pickerView getCardsString];
        if (cardTitle.length == 2)
        {
            cardTitle = [NSString stringWithFormat:@"%@\n%@", [cardTitle substringToIndex:1], [cardTitle substringFromIndex:1]];
        }
        
        [self.card5 setTitle:cardTitle forState:UIControlStateNormal];
        [self.card5 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
        
        settings.settingsCard5 = [pickerView getCardsString];
        
        [appDelegate.dataManager saveCoreData];
    }
    else
    {
        NSInteger playerPos = cardsPickerVC.tag/10;
        
        if (playerPos < [players count])
        {
            Player *curPlayer = [self getPlayerWithIndex:playerPos];
            if (curPlayer != NULL)
            {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                int len=0;
                
                NSString *cardsString = [pickerView getCardsString];
                
                while((len+2) < [cardsString length])
                {
                    [array addObject:[cardsString substringWithRange:NSMakeRange(len,2)]];
                    len+=2;
                }
                
                [array addObject:[cardsString substringFromIndex:len]];
                
                UIButton *card1 = (UIButton*)[self.boardView viewWithTag:playerPos*10+FIRST_CARD_OFFSET];
                UIButton *card2 = (UIButton*)[self.boardView viewWithTag:playerPos*10+SECOND_CARD_OFFSET];
                
                if (card1 != NULL && card2 != NULL)
                {
                    card1.titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
                    card1.titleLabel.textAlignment = UITextAlignmentCenter;
                    [card1 setTitle:[array objectAtIndex:0] forState:UIControlStateNormal];
                    [card1 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
                    
                    card2.titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
                    card2.titleLabel.textAlignment = UITextAlignmentCenter;
                    [card2 setTitle:[array objectAtIndex:1] forState:UIControlStateNormal];
                    [card2 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
                    
                    curPlayer.playerCard1 = [array objectAtIndex:0];
                    curPlayer.playerCard2 = [array objectAtIndex:1];
                    
                    [appDelegate.dataManager saveCoreData];
                }
            }
        }
        
    }
}

- (void)cardsPickerVCCancelButtonClicked:(CardsPickerVC *)pickerView
{
    NSLog(@"cardsPickerVCDoneButtonClicked = %@", pickerView.cardsLabel.text);
    
    if (pickerView.tag == 101)
    {
        NSArray *array = [pickerView getSavedCards];
        
        if ([array count] == 3)
        {
            settings.settingsCard1 = [array objectAtIndex:0];
            settings.settingsCard2 = [array objectAtIndex:1];
            settings.settingsCard3 = [array objectAtIndex:2];
            
            [appDelegate.dataManager saveCoreData];
        }
    }
    else if (pickerView.tag == 102)
    {
        NSArray *array = [pickerView getSavedCards];
        
        if ([array count] == 1)
        {
            settings.settingsCard4 = [array objectAtIndex:0];
            
            [appDelegate.dataManager saveCoreData];
        }
    }
    else if (pickerView.tag == 103)
    {
        NSArray *array = [pickerView getSavedCards];
        
        if ([array count] == 1)
        {
            settings.settingsCard5 = [array objectAtIndex:0];
            
            [appDelegate.dataManager saveCoreData];
        }
    }
    else
    {
        NSInteger playerPos = cardsPickerVC.tag/10;
        
        if (playerPos < [players count])
        {
            Player *curPlayer = [self getPlayerWithIndex:playerPos];
            if (curPlayer != NULL)
            {
                NSArray *array = [pickerView getSavedCards];
                
                if ([array count] == 2)
                {
                    curPlayer.playerCard1 = [array objectAtIndex:0];
                    curPlayer.playerCard2 = [array objectAtIndex:1];
                    
                    [appDelegate.dataManager saveCoreData];
                }
            }
        }
    }
}

#pragma mark - Get player from array
- (Player*)getPlayerWithIndex:(NSInteger)index
{
    if (index < [players count])
    {
        Player *curPlayer = [players objectAtIndex:index];
        if (curPlayer != NULL)
        {
            return curPlayer;
        }
    }
    
    return NULL;
}

#pragma mark - Chip Btn Clicked
- (void)chipBtnClicked:(UIGestureRecognizer *)gestureRecognizer
{
    if (addRemovePlayersMode == NO)
    {
        if (self.menuView.hidden == NO)
        {
            return;
        }
        
        UIView *tappedView = [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view] withEvent:nil];
        
        NSInteger playerTag = tappedView.tag - LABEL_OFFSET;
        
        Player *curPlayer = [self getPlayerWithIndex:playerTag];
        if (curPlayer != NULL && ![curPlayer isPlayerIsOpenSeat])
        {
            self.menuView.tag = playerTag + MENU_TAG_OFFSET;
            [self showMenuWithPlayerInfo:curPlayer];
        }
    }
    else
    {
        UIView *tappedView = [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view] withEvent:nil];
        NSInteger playerTag = tappedView.tag - LABEL_OFFSET;
        
        curMenuPlayerPosition = playerTag;
        
        //addPlayersVC.view.hidden = NO;
        [addPlayersVC setPickerType:PLAYERS_PICKER showHeroName:YES];
        [addPlayersVC showWithTitle:@"" lockBackground:YES animated:YES];
        //[self showPlayerPickers];
    }
}

- (IBAction)menuHideBtnClicked:(id)sender
{
    [self hideMenu];
}

- (void)showMenuWithPlayerInfo:(Player*)curPlayer
{
    NSInteger playerTag = self.menuView.tag - MENU_TAG_OFFSET;
    curMenuPlayerPosition = playerTag;
    
    [self refreshCurStatsLabelBorder];
    
    //notes
    /*if (curPlayer.playerNotes == NULL || curPlayer.playerNotes.length == 0)
    {
        [self.addNote setTitle:@"Add a note" forState:UIControlStateNormal];
    }
    else
    {
        [self.addNote setTitle:@"Review a note" forState:UIControlStateNormal];
    }*/
    
    //bet btn names
    if ([self ifPreflopStage])
    {
        [self.betFirstBtn setTitle:@"2 BB" forState:UIControlStateNormal];
        [self.betSecondBtn setTitle:@"3 BB" forState:UIControlStateNormal];
        [self.betThirdBtn setTitle:@"5 BB" forState:UIControlStateNormal];
        [self.betFourthBtn setTitle:@"7 BB" forState:UIControlStateNormal];
    }
    else
    {
        [self.betFirstBtn setTitle:@"25%" forState:UIControlStateNormal];
        [self.betSecondBtn setTitle:@"50%" forState:UIControlStateNormal];
        [self.betThirdBtn setTitle:@"75%" forState:UIControlStateNormal];
        [self.betFourthBtn setTitle:@"Pot" forState:UIControlStateNormal];
    }
    
    self.menuBetField.enabled = NO;
    self.menuBetField.alpha = 0.5;
    self.betSlider.enabled = NO;
    self.betSlider.alpha = 0.5;
    self.betSlider.value = 0;
    
    float prevPlayerBet = [self getPreviousPlayerBetSize:curMenuPlayerPosition];
    

    
    if ([self ifPreflopStage])
    {
        self.betSlider.minimumValue = currentMaxBet;
        //self.betSlider.maximumValue = currentMaxBet*50;
        self.betSlider.maximumValue = [curPlayer.playerStackSize integerValue];
    }
    else
    {
        if (currentMaxBet == 0)
        {
            self.betSlider.minimumValue = [settings.settingsMaxLimit integerValue];
            //self.betSlider.maximumValue = [settings.settingsMaxLimit integerValue]*50;
            //self.betSlider.maximumValue = potSize + potSize/10;
            self.betSlider.maximumValue = [curPlayer.playerStackSize integerValue];
        }
        else
        {
            self.betSlider.minimumValue = currentMaxBet;
            //self.betSlider.maximumValue = currentMaxBet*50;
            //self.betSlider.maximumValue = currentMaxBet + potSize + ((currentMaxBet + potSize)/10);
            self.betSlider.maximumValue = [curPlayer.playerStackSize integerValue];
        }
    }
    
    self.betSlider.value = self.betSlider.minimumValue;
    
    NSInteger curNonFoldedPlayers = [self currentPlayersCount];
    if (curNonFoldedPlayers < 2 || [curPlayer.playerFoldedCards boolValue])
    {
        self.foldBtn.enabled = NO;
        self.foldBtn.alpha = 0.5;
        
        if ([curPlayer.playerFoldedCards boolValue])
        {
            self.betRaiseBtn.enabled = NO;
            self.betRaiseBtn.alpha = 0.5;
            
            self.checkBtn.enabled = NO;
            self.checkBtn.alpha = 0.5;
            
            self.betFirstBtn.enabled = NO;
            self.betFirstBtn.alpha = 0.5;
            self.betSecondBtn.enabled = NO;
            self.betSecondBtn.alpha = 0.5;
            self.betThirdBtn.enabled = NO;
            self.betThirdBtn.alpha = 0.5;
            self.betFourthBtn.enabled = NO;
            self.betFourthBtn.alpha = 0.5;
        }
    }
    else
    {
        self.foldBtn.enabled = YES;
        self.foldBtn.alpha = 1.0;
        
        self.betRaiseBtn.enabled = YES;
        self.betRaiseBtn.alpha = 1.0;
        
        self.checkBtn.enabled = YES;
        self.checkBtn.alpha = 1.0;
        
        self.betFirstBtn.enabled = YES;
        self.betFirstBtn.alpha = 1.0;
        self.betSecondBtn.enabled = YES;
        self.betSecondBtn.alpha = 1.0;
        self.betThirdBtn.enabled = YES;
        self.betThirdBtn.alpha = 1.0;
        self.betFourthBtn.enabled = YES;
        self.betFourthBtn.alpha = 1.0;
    }
    
    
    if ([self ifPreflopStage])
    {
        if (prevPlayerBet == [curPlayer.playerBetSize floatValue])
        {
            self.checkBtn.enabled = NO;
            self.checkBtn.alpha = 0.5;
        }
    }
    else
    {
        if (currentMaxBet!=0 && prevPlayerBet == [curPlayer.playerBetSize floatValue])
        {
            self.checkBtn.enabled = NO;
            self.checkBtn.alpha = 0.5;
        }
    }
    
    
    self.betFourthBtn.enabled = YES;
    self.betFourthBtn.alpha = 1;
    self.betThirdBtn.enabled = YES;
    self.betThirdBtn.alpha = 1;
    self.betSecondBtn.enabled = YES;
    self.betSecondBtn.alpha = 1;
    self.betFirstBtn.enabled = YES;
    self.betFirstBtn.alpha = 1;
    
    
    //buttons change
    if ([self ifPreflopStage])
    {
        if (currentMaxBet >= 7*[settings.settingsMaxLimit integerValue])
        {
            self.betFourthBtn.enabled = NO;
            self.betFourthBtn.alpha = 0.5;
        }
        
        if (currentMaxBet >= 5*[settings.settingsMaxLimit integerValue])
        {
            self.betThirdBtn.enabled = NO;
            self.betThirdBtn.alpha = 0.5;
        }
        
        if (currentMaxBet >= 3*[settings.settingsMaxLimit integerValue])
        {
            self.betSecondBtn.enabled = NO;
            self.betSecondBtn.alpha = 0.5;
        }
        
        if (currentMaxBet >= 2*[settings.settingsMaxLimit integerValue])
        {
            self.betFirstBtn.enabled = NO;
            self.betFirstBtn.alpha = 0.5;
        }
    }
    else
    {
        if (currentMaxBet >= potSize)
        {
            self.betFourthBtn.enabled = NO;
            self.betFourthBtn.alpha = 0.5;
        }
        
        if (currentMaxBet >= potSize*0.75)
        {
            self.betThirdBtn.enabled = NO;
            self.betThirdBtn.alpha = 0.5;
        }
        
        if (currentMaxBet >= potSize*0.5)
        {
            self.betSecondBtn.enabled = NO;
            self.betSecondBtn.alpha = 0.5;
        }
        
        if (currentMaxBet >= potSize*0.25)
        {
            self.betFirstBtn.enabled = NO;
            self.betFirstBtn.alpha = 0.5;
        }
    }
    
    UILabel *statsLabel = (UILabel*)[self.boardView viewWithTag:playerTag+LABEL_OFFSET];
    
    [self refreshMenuInfo];
    
    if (self.menuView.hidden == YES)
    {
        self.menuView.hidden = NO;
        
        CGRect frame = self.menuView.frame;
        frame.origin.y = self.topView.frame.size.height;
        self.menuView.frame = frame;

        /*
        [self transformCardsToStartedPositions];
        self.boardView.frame = CGRectMake(0, 0, self.boardView.frame.size.width, self.boardView.frame.size.height + self.menuView.frame.size.height);
        [self.contentView setContentSize:CGSizeMake(self.boardView.frame.size.width, self.boardView.frame.size.height)];
        [self transformCardsToRotatedPositions];*/
        
        [UIView animateWithDuration:0.3 animations:^
         {
             //NSLog(@"started self.contentView.zoomScale = %f, contentSize = %@", self.contentView.zoomScale, NSStringFromCGSize(self.contentView.contentSize));
             //[self.contentView setContentSize:CGSizeMake(self.boardView.frame.size.width, self.boardView.frame.size.height)];
             //[self.contentView setContentSize:CGSizeMake(self.contentView.contentSize.width, self.contentView.contentSize.height + (self.menuView.frame.size.height*self.contentView.zoomScale))];
             
             CGRect topFrame = self.contentView.frame;
             topFrame.size.height = self.contentView.bounds.size.height - self.menuView.frame.size.height;
             self.contentView.frame = topFrame;

             CGRect frame = self.menuView.frame;
             frame.origin.y = self.topView.bounds.size.height - self.menuView.frame.size.height;
             self.menuView.frame = frame;
             
             [self autoFocusOnLabel:statsLabel];
         }
         completion:^(BOOL finished)
         {
            
         }];
    }
    else
    {
        [self autoFocusOnLabel:statsLabel];
    }
}

- (void)hideMenu
{
    UILabel *borderLabel = (UILabel*)[self.boardView viewWithTag:CUR_LABEL_BORDER];
    [borderLabel removeFromSuperview];
    
    [self.menuBetField resignFirstResponder];
    
    /*[self transformCardsToStartedPositions];
    self.boardView.frame = CGRectMake(0, 0, self.boardView.frame.size.width, self.boardView.frame.size.height - self.menuView.frame.size.height);
    [self.contentView setContentSize:CGSizeMake(self.boardView.frame.size.width, self.boardView.frame.size.height)];
    [self transformCardsToRotatedPositions];*/

    [UIView animateWithDuration:0.3 animations:^
     {
         //NSLog(@"boardView.frame = %@, bounds = %@, self.contentView.zoomScale = %f, contentSize = %@",
         //NSLog(@"before self.contentView.zoomScale = %f, contentSize = %@", self.contentView.zoomScale, NSStringFromCGSize(self.contentView.contentSize));
         //[self.contentView setContentSize:CGSizeMake(self.boardView.frame.size.width, self.boardView.frame.size.height - (self.menuView.frame.size.height*self.contentView.zoomScale))];
         //NSLog(@"after contentSize = %@, self.menuView.frame.size.height*self.contentView.zoomScale = %f", NSStringFromCGSize(self.contentView.contentSize), self.menuView.frame.size.height*self.contentView.zoomScale);
         CGRect topFrame = self.contentView.frame;
         topFrame.size.height = self.contentView.bounds.size.height + self.menuView.frame.size.height;
         self.contentView.frame = topFrame;

         CGRect frame = self.menuView.frame;
         frame.origin.y = self.topView.frame.size.height;
         self.menuView.frame = frame;
     }
     completion:^(BOOL finished)
     {
         self.menuView.hidden = YES;
     }];
}

- (void)autoFocusOnLabel:(UILabel*)statsLabel
{
    NSInteger zoomValue = self.contentView.zoomScale;
    if (zoomValue <= 3.5)
    {
        NSInteger xOffset = MIN(statsLabel.frame.origin.x*zoomValue, self.contentView.contentSize.width - self.contentView.frame.size.width);
        NSInteger yOffset = MIN(statsLabel.frame.origin.y*zoomValue, self.contentView.contentSize.height - self.contentView.frame.size.height);
        
        if (statsLabel.frame.origin.y < self.contentView.frame.size.height/2 && (self.contentView.contentOffset.y != yOffset || self.contentView.contentOffset.x != xOffset))
        {
            yOffset -= 5*zoomValue;

            if (zoomValue  == 1)
            {
                yOffset = 0;
            }
            
            [self.contentView setContentOffset:CGPointMake(xOffset, yOffset) animated:YES];
        }
        else if (statsLabel.frame.origin.y > self.contentView.frame.size.height/2 && (self.contentView.contentOffset.y != yOffset || self.contentView.contentOffset.x != xOffset))
        {
            yOffset += 5*zoomValue;

            [self.contentView setContentOffset:CGPointMake(xOffset, yOffset) animated:YES];
        }
    }
}

#pragma mark - card frame transform routine
- (void)transformCardsToStartedPositions
{
    for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        UIButton *card1 = (UIButton*)[self.boardView viewWithTag:i*10+FIRST_CARD_OFFSET];
        UIButton *card2 = (UIButton*)[self.boardView viewWithTag:i*10+SECOND_CARD_OFFSET];
        
        card1.transform = CGAffineTransformMakeRotation(0*M_PI/180.0);
        card2.transform = CGAffineTransformMakeRotation(0*M_PI/180.0);
    }
}

- (void)transformCardsToRotatedPositions
{
    return;
    
    for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        UIButton *card1 = (UIButton*)[self.boardView viewWithTag:i*10+FIRST_CARD_OFFSET];
        UIButton *card2 = (UIButton*)[self.boardView viewWithTag:i*10+SECOND_CARD_OFFSET];

        NSNumber *angle = [cardAngles objectAtIndex:i];
        
        card1.transform = CGAffineTransformMakeRotation([angle integerValue]*M_PI/180.0);
        card2.transform = CGAffineTransformMakeRotation([angle integerValue]*M_PI/180.0);
        
    }
}

#pragma mark - Double Picker delegate
- (void)doublePickerViewControllerDoneButtonClicked:(DoubleComponentInPickerViewViewController *)pickerView
{
    NSString *str = [pickerView returnSelectedCard];
    
    if ([str length]>0)
    {
        if (pickerView.view.tag == 101)
        {
            [self.card1 setTitle:str forState:UIControlStateNormal];
            [self.card1.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.card1 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
            
            settings.settingsCard1 = str;
        }
        else if (pickerView.view.tag == 102)
        {
            [self.card2 setTitle:str forState:UIControlStateNormal];
            [self.card2.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.card2 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
            
            settings.settingsCard2 = str;
        }
        else if (pickerView.view.tag == 103)
        {
            [self.card3 setTitle:str forState:UIControlStateNormal];
            [self.card3.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.card3 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
            
            settings.settingsCard3 = str;
        }
        else if (pickerView.view.tag == 104)
        {
            [self.card4 setTitle:str forState:UIControlStateNormal];
            [self.card4.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.card4 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
            
            settings.settingsCard4 = str;
            
        }
        else if (pickerView.view.tag == 105)
        {
            [self.card5 setTitle:str forState:UIControlStateNormal];
            [self.card5.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.card5 setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
            
            settings.settingsCard5 = str;
        }
        else
        {
            UIButton *card = (UIButton*)[self.boardView viewWithTag:pickerView.view.tag];
            //[card.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            
            card.titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            card.titleLabel.textAlignment = UITextAlignmentCenter;
            
            [card setTitle:str forState:UIControlStateNormal];
            [card setBackgroundImage:[UIImage imageNamed:@"CardFace.png"] forState:UIControlStateNormal];
            
            NSInteger playerPos = pickerView.view.tag/10;
            if (playerPos < [players count])
            {
                Player *curPlayer = [self getPlayerWithIndex:playerPos];
                if (curPlayer != NULL)
                {
                    if (pickerView.view.tag % 10 == FIRST_CARD_OFFSET)
                    {
                        curPlayer.playerCard1 = str;
                    }
                    else
                    {
                        curPlayer.playerCard2 = str;
                    }
                }
            }
        }
    }
}

#pragma mark - Check for add/remove player mode
- (BOOL)ifAddRemovePlayersModeEnabled
{
    if ([self.winnerBtn.titleLabel.text isEqualToString:@"Winner"])
    {
        return NO;
    }
    
    return YES;
}

- (void)addRemovePlayersModeChange:(BOOL)enable
{
    if (enable)
    {
        if ([settings.settingsNumberOfPlayers integerValue] != 10)
        {
            [self.winnerBtn setTitle:@"Add seats" forState:UIControlStateNormal];
            self.winnerBtn.enabled = YES;
            self.winnerBtn.userInteractionEnabled = YES;
            self.winnerBtn.alpha = 1.0;
            
            addRemovePlayersMode = YES;
            
            /*for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
            {
                UILabel *statsLabel = (UILabel*)[self.boardView viewWithTag: i+LABEL_OFFSET];
                statsLabel.userInteractionEnabled = YES;
            }*/
        }
        else
        {
            //[self.winnerBtn setTitle:@"Add seats" forState:UIControlStateNormal];
            self.winnerBtn.userInteractionEnabled = NO;
            self.winnerBtn.enabled = NO;
            self.winnerBtn.alpha = 0.5;
            
            addRemovePlayersMode = YES;
            
            /*for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
            {
                UILabel *statsLabel = (UILabel*)[self.boardView viewWithTag: i+LABEL_OFFSET];
                statsLabel.userInteractionEnabled = YES;
            }*/
        }
    }
    else
    {
        [self.winnerBtn setTitle:@"Winner" forState:UIControlStateNormal];
        self.winnerBtn.userInteractionEnabled = YES;
        self.winnerBtn.enabled = YES;
        self.winnerBtn.alpha = 1;
        
        addRemovePlayersMode = NO;
        
        /*for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
        {
            UILabel *statsLabel = (UILabel*)[self.boardView viewWithTag: i+LABEL_OFFSET];
            statsLabel.userInteractionEnabled = NO;
        }*/

    }
}

- (void)hideAllPlayersCards
{
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        
        if (curPlayer != NULL && ![curPlayer isPlayerIsOpenSeat])
        {
            curPlayer.playerCard1 = NULL;
            curPlayer.playerCard2 = NULL;
            
            UIButton *card1 = (UIButton*)[self.boardView viewWithTag:i*10+FIRST_CARD_OFFSET];
            card1.hidden = YES;card1.userInteractionEnabled = NO;
            [card1 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
            [card1 setTitle:@"" forState:UIControlStateNormal];
            
            UIButton *card2 = (UIButton*)[self.boardView viewWithTag:i*10+SECOND_CARD_OFFSET];
            card2.hidden = YES;card2.userInteractionEnabled = NO;
            [card2 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
            [card2 setTitle:@"" forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Winner Btn
- (IBAction)winnerBtnClicked:(id)sender
{
    if (![self ifAddRemovePlayersModeEnabled])
    {
        [self showPickerWithTitleAndTag:@"Select winner" tag:PICKER_WINNER];
    }
    else
    {
        addRemovePlayersMode = YES;
        
        [self hideAllPlayersCards];
        
        if ([settings.settingsNumberOfPlayers integerValue] <= 6)
        {
            for(int i=0; i< (9-[settings.settingsNumberOfPlayers integerValue]); i++)
            {
                Player *tmpPlayer = [appDelegate.dataManager getPlayerByName:EMPTY_PLAYER_NAME];
                [players addObject:tmpPlayer];
            }
            
            [settings changeNumberOfPlayers:9];
            
            //[players removeAllObjects];
            //[self createPlayersArray:NO];
            [self refreshPlayersInfo];
        }
        else
        {
            for(int i=0; i< (10-[settings.settingsNumberOfPlayers integerValue]); i++)
            {
                Player *tmpPlayer = [appDelegate.dataManager getPlayerByName:EMPTY_PLAYER_NAME];
                [players addObject:tmpPlayer];
            }
            
            [settings changeNumberOfPlayers:10];
            [self addRemovePlayersModeChange:YES];
            
            //[players removeAllObjects];
            //[self createPlayersArray:NO];
            [self refreshPlayersInfo];
        }
        
        [self transformCardsToStartedPositions];
        [self setObjectsFrames];
        //[self transformCardsToRotatedPositions];
        
        [UIView animateWithDuration:1.2 animations:^
         {
             [self setButtonsFrames:YES];
             [self changeAllStatsFieldsAlpha:1];
         }
        completion:^(BOOL finished)
         {
             [self transformCardsToRotatedPositions];
         }];
    }
}

#pragma mark - BU pplayer
- (void)showBUSelectPicker
{
    [self showPickerWithTitleAndTag:@"Select BU player" tag:PICKER_BU];
}

- (void)showPlayerPickers
{
    NSArray *allNames = [appDelegate.dataManager getAllPlayersNamesSortedByLastActionTime];
    
    if (allNames == NULL)
    {
        return;
    }

    NSMutableArray *allKeys = [NSMutableArray new];
    
    [allKeys addObject:EMPTY_PLAYER_NAME];
    [allKeys addObjectsFromArray:allNames];
    
	NSArray *components = [[NSArray alloc] initWithObjects:allKeys, nil];
    
    pickerVC.tag = ADD_PLAYERS;
	[pickerVC setData:components];
	[pickerVC selectRowWithIndex:0 inComponent:0 animated:NO];
	
	pickerVC.delegate = self;
	[pickerVC showWithTitle:@"Add/Remove players" lockBackground:YES animated:YES];
}

- (void)showPickerWithTitleAndTag:(NSString*)title tag:(NSInteger)tag
{
    NSMutableArray *allKeys = [NSMutableArray new];
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        if (![curPlayer.playerFoldedCards boolValue] && ![curPlayer isPlayerIsOpenSeat])
        {
            [allKeys addObject:curPlayer.playerName];
        }
    }
    
    if (tag == PICKER_WINNER)
    {
        if ([allKeys count] > 1)
        {
            [allKeys addObject:SPLIT_MSG_STRING];
        }
    }
    
	NSArray *components = [[NSArray alloc] initWithObjects:allKeys, nil];
    
    pickerVC.tag = tag;
	[pickerVC setData:components];
	[pickerVC selectRowWithIndex:0 inComponent:0 animated:NO];
	
	pickerVC.delegate = self;
	[pickerVC showWithTitle:title lockBackground:YES animated:YES];
}

#pragma mark - PickerVC Delegate Methods
- (void)pickerViewControllerDoneButtonClicked:(PickerVC *)pickerView
{
    //NSString *selectedValue = [pickerView getSelectedRowValueInComponent:0];
    switch (pickerVC.tag)
    {
        case PICKER_FOLDED:
        {

        }
            break;
            
        case ADD_PLAYERS:
        {
            NSString *selectedPlayerStr = [pickerView getSelectedRowValueInComponent:0];
            Player *changedPlayer = [appDelegate.dataManager getPlayerByName:selectedPlayerStr];
            NSInteger changedPlayerPosition = [self playerPositionForName:changedPlayer.playerName];
            
            if (curMenuPlayerPosition >= 0 && curMenuPlayerPosition < [players count])
            {
                Player *oldPlayer = [players objectAtIndex:curMenuPlayerPosition];
                if (changedPlayerPosition >= 0 && changedPlayerPosition < [settings getNumberOfPlayersForCurrentCount])
                {
                    [players replaceObjectAtIndex:changedPlayerPosition withObject:oldPlayer];
                }
                
                [players replaceObjectAtIndex:curMenuPlayerPosition withObject:changedPlayer];
                [self refreshPlayersInfo];
            }
        }
            
            break;
    
        case PICKER_WINNER:
        {
            [self recalculatePotSize];
            [self recalculateALLbet];
            
            self.betRaiseBtn.userInteractionEnabled = NO;
            self.betRaiseBtn.alpha = 0.5;
            self.raiseBtn.userInteractionEnabled = NO;
            self.raiseBtn.alpha = 0.5;
            self.checkBtn.userInteractionEnabled = NO;
            self.checkBtn.alpha = 0.5;
            self.flopBtn.userInteractionEnabled = NO;
            self.flopBtn.alpha = 0.5;
            self.foldBtn.userInteractionEnabled = NO;
            self.foldBtn.alpha = 0.5;
            self.winnerBtn.userInteractionEnabled = NO;
            self.winnerBtn.alpha = 0.5;
            
            NSString *selectedPlayerStr = [pickerView getSelectedRowValueInComponent:0];
            Player *curPlayer = [appDelegate.dataManager getPlayerByName:selectedPlayerStr];
            
            //check split case, divide pot between non folded players
            if ([[pickerView getSelectedRowValueInComponent:0] isEqualToString:SPLIT_MSG_STRING])
            {
                NSInteger numOfPlayers = [self currentPlayersCount];
                if (numOfPlayers > 0)
                {
                    NSInteger dividedBetPart = potSize/numOfPlayers;
                    
                    for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
                    {
                        Player *tmpPlayer = [self getPlayerWithIndex:i];
                        if (![tmpPlayer isPlayerIsOpenSeat] || ![tmpPlayer.playerFoldedCards boolValue])
                        {
                            [tmpPlayer changeStackSize:(tmpPlayer.playerStackSize.floatValue+dividedBetPart)];
                            
                            if ([tmpPlayer.playerName isEqualToString:settings.settingsHeroName])
                            {
                                curPlayer = [appDelegate.dataManager getPlayerByName:settings.settingsHeroName];
                            }
                        }
                    }
                }
            }
            else
            {
                [curPlayer changeStackSize:(curPlayer.playerStackSize.floatValue+potSize)];
            }
            
            //Change Session stats
            Player *heroPlayer  = [appDelegate.dataManager getPlayerByName:settings.settingsHeroName];
            NSInteger curHeroMoney = [heroPlayer.playerStackSize integerValue];
            float BB = [settings.settingsMaxLimit floatValue];
            
            if (curSession != NULL)
            {
                [curSession changeSessionBBwon:(float)(curHeroMoney-startHeroMoney)/BB replace:YES];
            }
            
            if ([curPlayer.playerName isEqualToString:heroPlayer.playerName] && curSession != NULL)
            {
                NSLog(@"hero win %f, %f", potSize, (float)(curHeroMoney-startHeroMoney)/BB);
                [curSession.sessionStats changeBiggestPotWon:potSize/BB];
                [curSession.sessionStats changeStatsHandsWon:1];
                
                NSInteger curHeroBet = [heroPlayer.playerBetSize integerValue];
                if (curHand != NULL && curHeroBet > 0)
                {
                    [curHand changeSessionBBwon:(float)curHeroBet/BB replace:YES];
                }
            }
            else if (curSession != NULL)
            {
                NSLog(@"hero lost %f, %f", potSize, (float)(curHeroMoney-startHeroMoney)/BB);
                if ([heroPlayer.playerBetSize integerValue] > 0 || heroInvestMoney)
                {
                    [curSession.sessionStats changeBiggestPotLost:potSize/BB];
                }
                
                NSInteger curHeroBet = [heroPlayer.playerBetSize integerValue];
                if (curHand != NULL && curHeroBet > 0)
                {
                    [curHand changeSessionBBwon:-(float)curHeroBet/BB replace:YES];
                }
            }
            //Change Session stats
            
            
            for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
            {
                Player *curPlayer = [self getPlayerWithIndex:i];
                [curPlayer clearBetSize];
                [curPlayer changePlayerHands:1];
                
                //?????
                /*if ([curPlayer.playerName isEqualToString:selectedPlayerStr])
                {
                    selectedIndex = i;
                    break;
                }*/
            }
            
            NSInteger selectedIndex = [self playerPositionForName:selectedPlayerStr];
            
            //if player was BB and all other player folded -- +1 to player walks
            if ([self ifPlayerIsBB:selectedIndex])
            {
                BOOL allFolded = YES;
                
                for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
                {
                    if (i == selectedIndex)
                        continue;
                    
                    Player *curPlayer = [self getPlayerWithIndex:i];
                    
                    if (![curPlayer.playerFoldedCards boolValue] && ![curPlayer isPlayerIsOpenSeat])
                    {
                        allFolded = NO;
                        break;
                    }
                }
                
                if (allFolded)
                {
                    Player *curPlayer = [self getPlayerWithIndex:selectedIndex];
                    //[curPlayer changePlayerWalks:1];
                    [curPlayer addToPlayerAllAction:WALK];
                    NSLog(@"%@ walks+1", curPlayer.playerName);
                }
            }
            
            [appDelegate.dataManager saveCoreData];
            
            [self calcPlayerStats];
            
            potSize = 0;
            self.potSizeField.text = @"POT: 0";
            
            recalcStats = YES;
            
            
            self.dealBtn.userInteractionEnabled = YES;
            self.dealBtn.alpha = 1;
            
            [self clearPlayerBets];
            [self refreshPlayersInfo];
            [self refreshBULabelBorder];
            
            [self hideMenu];
            
            [self addRemovePlayersModeChange:YES];
        }
            break;
            
        case PICKER_BU:
        {
            self.dealerBtn.hidden = NO;

            NSString *selectedPlayer = [pickerView getSelectedRowValueInComponent:0];
            NSInteger selectedIndex = [self playerPositionForName:selectedPlayer];
            currentBU = selectedIndex;
            [self newDealRoutine];
            //[self makeSBAndBBBets];
            //[self refreshPlayersInfo];
            //[self refreshBULabelBorder];
        }
            break;
            
        case PICKER_CHECK:
        {
            return;
        }
            break;
            
        case PICKER_BET_RAISE:
        {
            
            return;
        }
            break;
            
        default:
            break;
    }
}

-(BOOL)ifPreflopStage
{
    if (self.card1.hidden == YES)
    {
        return YES;
    }
    
    return NO;
}

- (NSInteger)getPlayerPositionWithOffset:(NSInteger)offset
{
    NSInteger curPlayerPos = currentBU;
    for(int i=0; i < [settings getNumberOfPlayersForCurrentCount] - 1; i++)
    {
        curPlayerPos++;
        
        if (curPlayerPos >= [settings getNumberOfPlayersForCurrentCount])
        {
            curPlayerPos = curPlayerPos - [settings getNumberOfPlayersForCurrentCount];
        }
        
        Player *curPlayer = [self getPlayerWithIndex:curPlayerPos];
        //if (![curPlayer.playerFoldedCards boolValue] && ![curPlayer isPlayerIsOpenSeat])
        if (![curPlayer isPlayerIsOpenSeat])
        {
            offset--;
        }
        
        if (offset == 0)
        {
            return curPlayerPos;
        }
    }
    
    return offset;
}

- (Player*)getPreviousPlayer:(NSInteger)currentPlayerPosistion
{
    NSInteger curPlayerPos = currentPlayerPosistion;
    NSInteger offset = 1;
    
    for(int i=0; i < [settings getNumberOfPlayersForCurrentCount] - 1; i++)
    {
        curPlayerPos--;
        
        if (curPlayerPos < 0)
        {
            curPlayerPos = [settings getNumberOfPlayersForCurrentCount]-1;
        }
        
        Player *curPlayer = [self getPlayerWithIndex:curPlayerPos];
        if (![curPlayer.playerFoldedCards boolValue] && ![curPlayer isPlayerIsOpenSeat])
        {
            offset--;
        }
        
        if (offset == 0)
        {
            Player *prevPlayer = [self getPlayerWithIndex:curPlayerPos];
            NSLog(@"for %d, prev = %@", currentPlayerPosistion, prevPlayer.playerName);
            return prevPlayer;
        }
    }
    
    return NULL;
}

- (float)getPreviousPlayerBetSize:(NSInteger)currentPlayerPosistion
{
    NSInteger curPlayerPos = currentPlayerPosistion;
    NSInteger offset = 1;
    
    for(int i=0; i < [settings getNumberOfPlayersForCurrentCount] - 1; i++)
    {
        curPlayerPos--;
        
        if (curPlayerPos < 0)
        {
            curPlayerPos = [settings getNumberOfPlayersForCurrentCount]-1;
        }
        
        Player *curPlayer = [self getPlayerWithIndex:curPlayerPos];
        if (![curPlayer.playerFoldedCards boolValue] && ![curPlayer isPlayerIsOpenSeat])
        {
            offset--;
        }
        
        if (offset == 0)
        {
            Player *prevPlayer = [self getPlayerWithIndex:curPlayerPos];
            NSLog(@"for %d, prev = %@", currentPlayerPosistion, prevPlayer.playerName);
            return [prevPlayer.playerBetSize floatValue];
        }
    }
    
    return -1;
}

-(BOOL)ifPlayerIsSB:(NSInteger)position
{
    NSInteger sbPosition = [self getPlayerPositionWithOffset:1];
    
    if (position == sbPosition)
    {
        return YES;
    }
    
    return NO;
}

-(BOOL)ifPlayerIsBB:(NSInteger)position
{
    NSInteger bbPosition = [self getPlayerPositionWithOffset:2];
    
    if (position == bbPosition)
    {
        return YES;
    }
    
    return NO;
}

- (void)makeSBAndBBBets
{
    NSInteger sbPosition = [self getPlayerPositionWithOffset:1];
    NSInteger bbPosition = [self getPlayerPositionWithOffset:2];
    
    Player *sbPlayer = [self getPlayerWithIndex:sbPosition];
    Player *bbPlayer = [self getPlayerWithIndex:bbPosition];
    
    [sbPlayer changeBetSize:[settings.settingsMinLimit floatValue]];
    [bbPlayer changeBetSize:[settings.settingsMaxLimit floatValue]];
    
    [sbPlayer addToTotalBetSize:[settings.settingsMinLimit floatValue]];
    [bbPlayer addToTotalBetSize:[settings.settingsMaxLimit floatValue]];
    
    potSize = potSize + [settings.settingsMinLimit floatValue] + [settings.settingsMaxLimit floatValue];
    
    //[self recalculatePotSize];
    [self recalculateALLbet];
}

- (void)changePlayerBetsToZero
{
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        [curPlayer changeBetSize:0];
    }
    
    [self refreshPlayersInfo];
}

- (void)clearPlayerBets
{
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        [curPlayer clearBetSize];
    }
    
    [self refreshPlayersInfo];
}

- (void)clearPlayerTotalBets
{
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        [curPlayer clearTotalBetSize];
    }
    
    [self refreshPlayersInfo];
}

- (void)clearPlayerFolds
{
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        [curPlayer changePlayerFoldedCardsValue:NO];
    }
    
    [self refreshPlayersInfo];
}

#pragma mark - bet Slider Value Changed
- (IBAction)betSliderValueChanged:(UISlider*)sender
{
    //NSString *str = [NSString stringWithFormat:@"%.0f", sender.value];
    //self.menuBetField.text = str;
    
    NSInteger curPlayerPos = self.menuView.tag - MENU_TAG_OFFSET;
    Player *curPlayer = [self getPlayerWithIndex:curPlayerPos];
    
    float playerBet = 0;
    if (![self ifPreflopStage])
    {
        playerBet = (NSInteger)sender.value;
    }
    else
    {
        playerBet = (NSInteger)sender.value;
    }
    
    //NSLog(@"sender.value = %f, playerBet/sender.maximumValue = %f", sender.value, playerBet/sender.maximumValue);
    //NSLog(@"sender.maximumValue = %f", sender.maximumValue);
    
    /*if (playerBet/sender.maximumValue >= 0.91)
    {
        [curPlayer changeBetSize:0];
        playerBet = [curPlayer.playerStackSize floatValue];
    }*/
    
    //[curPlayer addToTotalBetSize:-[curPlayer.playerBetSize floatValue]];

    if (![self ifPreflopStage])
    {
        if (playerBet > potSize && playerBet/sender.maximumValue >= 0.95)
        {
            [curPlayer addToTotalBetSize:-[curPlayer.playerBetSize floatValue]];
            [curPlayer changeBetSize:-[curPlayer.playerBetSize floatValue]];
            playerBet = [curPlayer.playerStackSize floatValue];
        }
        else if (playerBet > potSize)
        {
            playerBet = potSize;
        }
    }
    
    [self makeBetForPlayer:curPlayer newPlayerBet:playerBet];
    [self recalculateALLbet];
    
    
    [self refreshMenuInfo];
    [self refreshPlayersInfo];
    [self resfreshMaxBetValue];
}


#pragma mark - New Deal Btn Clicked
- (IBAction)newDealBtn:(id)sender
{
    if (currentBU < 0)
    {
        [self showBUSelectPicker];
    }
    else
    {
        NSLog(@"currentBU now = %d", currentBU);
        for (int i= 0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
        {
            currentBU++;
            
            if (currentBU >= [settings getNumberOfPlayersForCurrentCount])
            {
                currentBU = currentBU - [settings getNumberOfPlayersForCurrentCount];
            }
            
            Player *nextPlayer = [self getPlayerWithIndex:currentBU];
            if (![nextPlayer isPlayerIsOpenSeat])
            {
                break;
            }
        }
        
        NSLog(@"currentBU next = %d", currentBU);
        
        [self newDealRoutine];
    }
}

- (void)newDealRoutine
{
    [self addRemovePlayersModeChange:NO];
    
    if (curSession == NULL)
    {
        curSession = [appDelegate.dataManager addSessionEntryWithLocationAndDate:settings.settingsLocationName date:[NSDate date]];
    }
    
    playerPositionStatsCalculated = -1;
    
    //add new hand for this session
    if (curSession != NULL)
    {
        curHand = [appDelegate.dataManager addNewHandForSession:curSession];
        [curSession.sessionStats changeStatsHandsPlayed:1];
        
        if (curHand!= NULL)
        {
            [curSession changeSessionNumOfHands:1];
        }
    }
    heroInvestMoney = NO;
    
    self.statsTextField0.userInteractionEnabled = YES;self.statsTextField1.userInteractionEnabled = YES;self.statsTextField2.userInteractionEnabled = YES;
    self.statsTextField3.userInteractionEnabled = YES;self.statsTextField4.userInteractionEnabled = YES;self.statsTextField5.userInteractionEnabled = YES;
    self.statsTextField6.userInteractionEnabled = YES;self.statsTextField7.userInteractionEnabled = YES;self.statsTextField8.userInteractionEnabled = YES;self.statsTextField9.userInteractionEnabled = YES;
    
    
    self.card1.hidden = YES;[self.card1 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
    self.card2.hidden = YES;[self.card2 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
    self.card3.hidden = YES;[self.card3 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
    self.card4.hidden = YES;[self.card4 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
    self.card5.hidden = YES;[self.card5 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
    
    [self.card1 setTitle:@"" forState:UIControlStateNormal];
    [self.card2 setTitle:@"" forState:UIControlStateNormal];
    [self.card3 setTitle:@"" forState:UIControlStateNormal];
    [self.card4 setTitle:@"" forState:UIControlStateNormal];
    [self.card5 setTitle:@"" forState:UIControlStateNormal];
    
    [self.flopBtn setTitle:@"Flop" forState:UIControlStateNormal];
    
    settings.settingsCard1 = NULL;
    settings.settingsCard2 = NULL;
    settings.settingsCard3 = NULL;
    settings.settingsCard4 = NULL;
    settings.settingsCard5 = NULL;
    
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        
        [curPlayer changePlayerStatus:NEUTRAL_STATUS];
        
        if (curPlayer != NULL && ![curPlayer isPlayerIsOpenSeat])
        {
            curPlayer.playerCard1 = NULL;
            curPlayer.playerCard2 = NULL;
            
            UIButton *card1 = (UIButton*)[self.boardView viewWithTag:i*10+FIRST_CARD_OFFSET];
            card1.hidden = NO;card1.userInteractionEnabled = YES;
            [card1 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
            [card1 setTitle:@"" forState:UIControlStateNormal];
            [card1 addTarget:self action:@selector(boardCardClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *card2 = (UIButton*)[self.boardView viewWithTag:i*10+SECOND_CARD_OFFSET];
            card2.hidden = NO;card2.userInteractionEnabled = YES;
            [card2 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
            [card2 setTitle:@"" forState:UIControlStateNormal];
            [card2 addTarget:self action:@selector(boardCardClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            UIButton *card1 = (UIButton*)[self.boardView viewWithTag:i*10+FIRST_CARD_OFFSET];
            card1.hidden = YES;card1.userInteractionEnabled = NO;
            [card1 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
            [card1 setTitle:@"" forState:UIControlStateNormal];
            
            UIButton *card2 = (UIButton*)[self.boardView viewWithTag:i*10+SECOND_CARD_OFFSET];
            card2.hidden = YES;card2.userInteractionEnabled = NO;
            [card2 setBackgroundImage:[UIImage imageNamed:@"boardCardShirt.png"] forState:UIControlStateNormal];
            [card2 setTitle:@"" forState:UIControlStateNormal];
        }
    }
    
    potSize = 0;
    self.potSizeField.text = @"POT: 0";
    
    [self clearPlayerBets];
    [self clearPlayerTotalBets];
    [self clearPlayerFolds];
    
    self.betRaiseBtn.userInteractionEnabled = YES;
    self.betRaiseBtn.alpha = 1;
    self.raiseBtn.userInteractionEnabled = YES;
    self.raiseBtn.alpha = 1;
    self.checkBtn.userInteractionEnabled = YES;
    self.checkBtn.alpha = 1;
    self.flopBtn.userInteractionEnabled = YES;
    self.flopBtn.alpha = 1;
    self.foldBtn.userInteractionEnabled = YES;
    self.foldBtn.alpha = 1;
    self.winnerBtn.userInteractionEnabled = YES;
    self.winnerBtn.alpha = 1;
    self.dealBtn.userInteractionEnabled = NO;
    self.dealBtn.alpha = 0.5;
    
    [self makeSBAndBBBets];
    
    currentMaxBet = [settings.settingsMaxLimit integerValue];
    
    calcPlayerStats = NO;
    
    [self refreshPlayersInfo];
    [self refreshBULabelBorder];
    
    [self showMenuForCurrentRoundTrade];
    
    //dealer btn frame make
    self.dealerBtn.frame = [[dealerBtnFrames objectAtIndex:currentBU] CGRectValue];
    if (IS_IPHONE_5)
    {
        CGRect frame = self.dealerBtn.frame;
        frame.origin.x = (float)frame.origin.x * (568.0/480.0);
        self.dealerBtn.frame = frame;
    }
}

#pragma mark - Open menu for next player
- (IBAction)menuNextPlayerBtnClicked:(id)sender
{
    NSInteger curPlayerPos = self.menuView.tag - MENU_TAG_OFFSET;
    NSInteger nextPlayerPos = self.menuView.tag - MENU_TAG_OFFSET + 1;
    
    for(int i=0; i < [players count] - 1; i++)
    {
        if (nextPlayerPos >= [players count])
        {
            nextPlayerPos = nextPlayerPos - [players count];
        }
        
        Player *nextPlayer = [self getPlayerWithIndex:nextPlayerPos];
        if ([nextPlayer.playerFoldedCards boolValue] || [nextPlayer isPlayerIsOpenSeat])
        {
            nextPlayerPos++;
            continue;
        }
        else
        {
            break;
        }
    }

    if (curPlayerPos != nextPlayerPos)
    {
        //Player *curPlayer = [self getPlayerWithIndex:curPlayerPos];
        //[self betActionStatistic:curPlayer];
        
        Player *nextPlayer = [self getPlayerWithIndex:nextPlayerPos];
        
        if (nextPlayer != NULL)
        {
            self.menuView.tag = nextPlayerPos + MENU_TAG_OFFSET;
            [self showMenuWithPlayerInfo:nextPlayer];
        }
    }
    
    ////#### 3bet OPP
    Player *prevPlayer = [self getPreviousPlayer:curPlayerPos];
    Player *curPlayer = [self getPlayerWithIndex:curPlayerPos];
    if (prevPlayer != NULL)
    {
        if (prevPlayer.playerStatus.integerValue == RAISE_STATUS)
        {
            [curPlayer addToPlayerAllAction:BET_3_OPP];
            NSLog(@"%@ 3betOpp+1", curPlayer.playerName);
        }
    }
    ////#### 3bet OPP
    
    ////#### cbet OPP
    if (curPlayer != NULL)
    {
        if (curPlayer.playerStatus.integerValue == RAISE_STATUS || curPlayer.playerStatus.integerValue == BET_STATUS)
        {
            [curPlayer addToPlayerAllAction:C_BET_OPP];
            NSLog(@"%@ cbetOpp+1", curPlayer.playerName);
        }
    }
    ////#### cbet OPP

    ////#### donk OPP
    if (![self ifPreflopStage])
    {
        if (curPlayer != NULL)
        {
            if (curPlayer.playerStatus.integerValue != RAISE_STATUS || curPlayer.playerStatus.integerValue != BET_STATUS)
            {
                [curPlayer addToPlayerAllAction:DONK_BET_OPP];
                NSLog(@"%@ donkBetOPP+1", curPlayer.playerName);
            }
        }
    }
    ////#### donk OPP
}

#pragma mark - FirstPlayerPosition
- (NSInteger)firstPlayerInTradePosition
{
    NSInteger offset = 1;
    if ([self ifPreflopStage])
    {
        offset = 3;
    }
    
    NSInteger curPlayerPos = currentBU;
    for(int i=0; i < [settings getNumberOfPlayersForCurrentCount] - 1; i++)
    {
        curPlayerPos++;
        
        if (curPlayerPos >= [settings getNumberOfPlayersForCurrentCount])
        {
            curPlayerPos = curPlayerPos - [settings getNumberOfPlayersForCurrentCount];
        }
        
        Player *curPlayer = [self getPlayerWithIndex:curPlayerPos];
        if (![curPlayer.playerFoldedCards boolValue] && ![curPlayer isPlayerIsOpenSeat])
        {
            offset--;
        }
        
        if (offset == 0)
        {
            return curPlayerPos;
        }
    }
    
    return -1;
}

#pragma mark - Show Menu with current player info
- (void)showMenuForCurrentRoundTrade
{
    //for preflop stage open BB+1 player
    //else open SB player
    NSInteger offset = 1;
    if ([self ifPreflopStage])
    {
        offset = 3;
    }
 
    NSInteger curPlayerPos = currentBU;
    for(int i=0; i < [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        curPlayerPos++;

        if (curPlayerPos >= [settings getNumberOfPlayersForCurrentCount])
        {
            curPlayerPos = curPlayerPos - [settings getNumberOfPlayersForCurrentCount];
        }
        
        Player *curPlayer = [self getPlayerWithIndex:curPlayerPos];
        if (![curPlayer.playerFoldedCards boolValue] && ![curPlayer isPlayerIsOpenSeat])
        {
            offset--;
        }
        
        if (offset == 0)
        {
            break;
        }
    }
    
    Player *curPlayer = [self getPlayerWithIndex:curPlayerPos];
    self.menuView.tag = curPlayerPos + MENU_TAG_OFFSET;
    [self showMenuWithPlayerInfo:curPlayer];
}

#pragma mark - Players Stats
- (void)calcPlayerStats
{
    calcPlayerStats = YES;
    
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        if (![curPlayer isPlayerIsOpenSeat])
        {
            [curPlayer makeAllPlayerActions];
        }
    }
}

- (void)calcPlayerStatsForPlayer:(NSInteger)playerPosition
{
}

#pragma mark - Flop Btn
- (IBAction)flopBtnClicked:(UIButton*)sender
{
    //self cals stats
    //[self calcPlayerStatsForPlayer:curMenuPlayerPosition];
    
    //[self calcPlayerStats];
    calcPlayerStats = NO;
    
    Player *heroPlayer  = [appDelegate.dataManager getPlayerByName:settings.settingsHeroName];
    
    NSInteger heroPosition = [self playerPositionForName:heroPlayer.playerName];
    
    if ([self ifPlayerIsSB:heroPosition] && [heroPlayer.playerBetSize integerValue] > [settings.settingsMinLimit integerValue])
    {
        heroInvestMoney = YES;
    }
    else if ([self ifPlayerIsBB:heroPosition] && [heroPlayer.playerBetSize integerValue] > [settings.settingsMaxLimit integerValue])
    {
        heroInvestMoney = YES;
    }
    else if ([heroPlayer.playerBetSize integerValue] > 0)
    {
        heroInvestMoney = YES;
    }
    
    recalcStats = NO;
    currentMaxBet = 0;//[settings.settingsMaxLimit integerValue];
    
    [self recalculatePotSize];
    
    if ([sender.currentTitle isEqualToString:@"Flop"])
    {
        [self clearPlayerBets];
        
        self.card1.hidden = NO;
        self.card2.hidden = NO;
        self.card3.hidden = NO;
        self.card4.hidden = YES;
        self.card5.hidden = YES;
        [sender setTitle:@"Turn" forState:UIControlStateNormal];
    }
    else if ([sender.currentTitle isEqualToString:@"Turn"])
    {
        [self clearPlayerBets];
        
        self.card1.hidden = NO;
        self.card2.hidden = NO;
        self.card3.hidden = NO;
        self.card4.hidden = NO;
        self.card5.hidden = YES;
        [sender setTitle:@"River" forState:UIControlStateNormal];
    }
    else if ([sender.currentTitle isEqualToString:@"River"])
    {
        [self clearPlayerBets];
        
        self.card1.hidden = NO;
        self.card2.hidden = NO;
        self.card3.hidden = NO;
        self.card4.hidden = NO;
        self.card5.hidden = NO;
        [sender setTitle:@"River" forState:UIControlStateNormal];
        
        self.flopBtn.userInteractionEnabled = NO;
        self.flopBtn.alpha = 0.5;
    }
    
    [self refreshPlayersInfo];
    [self refreshBULabelBorder];
    
    [self showMenuForCurrentRoundTrade];
}


#pragma mark - Calculate Pot Size
/*-(void)recalculatePotSize:(float)oldBet newBet:(float)newBet
{
    if (oldBet != 0)
    {
        potSize = potSize - oldBet;
    }
    
    potSize = potSize + newBet;
    
    self.potSizeField.text = [NSString stringWithFormat:@"POT: %.0f", potSize];;
}*/

-(void)recalculatePotSize
{
    float potSizeInt = 0;
    potSize = 0;
    
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        potSizeInt += [curPlayer.playerTotalBetSize floatValue];
    }
    
    potSize = potSize + potSizeInt;
    
    NSString *potSizeStr = [NSString stringWithFormat:@"POT: %.0f", potSize];
    self.potSizeField.text = potSizeStr;
}

-(void)recalculateALLbet
{
    float potSizeInt = 0;

    
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        potSizeInt += [curPlayer.playerTotalBetSize floatValue];
    }
    
    NSString *potSizeStr = [NSString stringWithFormat:@"%.2f | %.1fBB", potSizeInt, potSizeInt/[settings.settingsMaxLimit floatValue]];
    self.allBets.text = potSizeStr;
}

#pragma mark - UITextField delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSInteger playerTag = self.menuView.tag - MENU_TAG_OFFSET;
    Player *curPlayer  = [self getPlayerWithIndex:playerTag];
    NSString *str = [curPlayer.playerBetSize stringValue];
    textField.text = str;
    
    if (self.boardView.frame.origin.y == 0)
    {
        NSInteger keyboardYHeight = 160;
        
        [UIView animateWithDuration:0.3 animations:^
         {
             CGRect frame = self.boardView.frame;
             frame.origin.y = frame.origin.y-keyboardYHeight;
             self.boardView.frame = frame;
             
             frame = self.menuView.frame;
             frame.origin.y = frame.origin.y - keyboardYHeight;
             self.menuView.frame = frame;
         }
         completion:^(BOOL finished)
         {
             
         }];
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /*[textField resignFirstResponder];
    NSInteger tag = self.menuView.tag - MENU_TAG_OFFSET;
    Player *curPlayer = [self getPlayerWithIndex:tag];
    
    float playerBet = [textField.text integerValue];
    
    if (curPlayer != NULL)
    {
        [self recalculatePotSize:[curPlayer.playerBetSize floatValue] newBet:playerBet];
        [curPlayer changeBetSize:playerBet];
    }
    
    [self refreshMenuInfo];
    [self refreshPlayersInfo];
    [self resfreshMaxBetValue];
    

    NSInteger keyboardYHeight = 160;
    
    [UIView animateWithDuration:0.3 animations:^
     {
         CGRect frame = self.boardView.frame;
         frame.origin.y = frame.origin.y + keyboardYHeight;
         self.boardView.frame = frame;
         
         frame = self.menuView.frame;
         frame.origin.y = frame.origin.y + keyboardYHeight;
         self.menuView.frame = frame;
     }
                     completion:^(BOOL finished)
     {
     
     }];*/
    

    return YES;
}

#pragma mark - Refresh Menu Info
- (void)refreshMenuInfo
{
    NSInteger tag = self.menuView.tag - MENU_TAG_OFFSET;
    Player *curPlayer = [self getPlayerWithIndex:tag];
    
    NSString *betStr;
    
    if ([curPlayer.playerBetSize integerValue] == 0)
    {
        betStr = [curPlayer.playerBetSize stringValue];
    }
    else if ([curPlayer.playerFoldedCards boolValue])
    {
        betStr = @"FOLD";
    }
    else
    {
        if ([self ifPreflopStage])
        {
            if ([self ifPlayerIsSB:tag] && [curPlayer.playerBetSize integerValue]==[settings.settingsMinLimit integerValue])
            {
                betStr = [curPlayer.playerBetSize stringValue];
            }
            else if ([self ifPlayerIsBB:tag] && [curPlayer.playerBetSize integerValue]==[settings.settingsMaxLimit integerValue])
            {
                betStr = [curPlayer.playerBetSize stringValue];
            }
            else
            {
                betStr = [NSString stringWithFormat:@"%.1fBB", [curPlayer.playerBetSize floatValue]/[settings.settingsMaxLimit floatValue]];
            }
        }
        else
        {
            betStr = [NSString stringWithFormat:@"%.0f%%", ([curPlayer.playerBetSize floatValue]*100.0)/potSize];
        }
    }
    
    self.menuBetField.text = betStr;
    
    self.menuNameField.text = curPlayer.playerName;
    self.menuStackField.text = [NSString stringWithFormat:@"%.2f | %@", [curPlayer.playerBetSize floatValue], betStr];
    self.menuStatsField.text = [curPlayer getPlayerStatistic];
    self.menuStatsExtendedField.text = [curPlayer getExtendedPlayerStatistic];
}

#pragma mark - max bet calc
- (void)resfreshMaxBetValue
{
    currentMaxBet = 0;
    
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        
        if (currentMaxBet < [[curPlayer playerBetSize] floatValue])
        {
            currentMaxBet = [[curPlayer playerBetSize] floatValue];
        }
    }
}

#pragma mark - BetBtn Clicked
- (IBAction)betLabelBtnClicked:(UIButton*)sender
{
    NSInteger playerPosition = self.menuView.tag - MENU_TAG_OFFSET;
    Player *curPlayer = [self getPlayerWithIndex:playerPosition];

    float playerBet;

    if (currentMaxBet == 0)
    {
        playerBet = [settings.settingsMaxLimit integerValue];
    }
    else if (currentMaxBet == [settings.settingsMaxLimit integerValue])
    {
        playerBet = currentMaxBet + [settings.settingsMaxLimit integerValue];
    }
    else
    {
        playerBet = currentMaxBet + [settings.settingsMaxLimit integerValue]*2;
    }
    
    if (curPlayer != NULL)
    {
        if ([curPlayer.playerBetSize integerValue]>0)
        {
            //[curPlayer changeStackSize:(curPlayer.playerStackSize.integerValue+curPlayer.playerBetSize.integerValue)];
        }
    }
    
    [self makeBetForPlayer:curPlayer newPlayerBet:playerBet];
    [self recalculateALLbet];
   

    if ([self ifPreflopStage])
    {
        self.betSlider.minimumValue = playerBet;
        self.betSlider.maximumValue = [curPlayer.playerStackSize integerValue] + playerBet;
    }
    else
    {
        self.betSlider.minimumValue = playerBet;
        //self.betSlider.maximumValue = currentMaxBet + potSize + ((currentMaxBet + potSize)/10);
        //self.betSlider.maximumValue = potSize + (playerBet + potSize/10);
        self.betSlider.maximumValue = potSize + potSize/10;
        //self.betSlider.maximumValue = [curPlayer.playerStackSize integerValue];
    }
    
    self.betSlider.value = playerBet;
    
    //self.menuBetField.enabled = YES;
    self.menuBetField.alpha = 1;
    self.betSlider.enabled = YES;
    self.betSlider.alpha = 1;
    
    //[self hideMenu];
    [self refreshMenuInfo];
    [self refreshPlayersInfo];
    [self resfreshMaxBetValue];
    
    [self betActionStatistic:curPlayer];
}

- (IBAction)checkBtnClicked:(UIButton*)sender
{
    NSInteger playerPosition = self.menuView.tag - MENU_TAG_OFFSET;
    Player *curPlayer = [self getPlayerWithIndex:playerPosition];
    
    float playerBet = currentMaxBet;
    
    /*if (![self ifPreflopStage])
    {
        if (currentMaxBet == [settings.settingsMaxLimit integerValue])
        {
            playerBet = 0;
        }
    }*/
 
    if (playerBet > 0)
    {
        self.menuBetField.enabled = YES;
        self.menuBetField.alpha = 1;
        
        float prevPlayerBet = currentMaxBet;
        
        /*NSInteger firstPos = [self firstPlayerInTradePosition];
        if (playerPosition != firstPos)
        {
            prevPlayerBet = [self getPreviousPlayerBetSize:playerPosition];
        }*/
        prevPlayerBet = [self getPreviousPlayerBetSize:playerPosition];
        
        //change player call
        if (playerBet == prevPlayerBet)
        {
            //[curPlayer changePlayerCalls:1];
            [curPlayer addToPlayerAllAction:CALL];
            [curPlayer changePlayerStatus:CALL_STATUS];
            NSLog(@"%@ calls+1", curPlayer.playerName);
        }
        
        if([self ifPreflopStage] && (playerBet == prevPlayerBet))
        {
            [curPlayer addToPlayerAllAction:VPIP];
            NSLog(@"%@ vpip+1", curPlayer.playerName);
        }
    }
    else
    {
        if (![self ifPreflopStage])
        {
            [curPlayer addToPlayerAllAction:CHECK];
            [curPlayer changePlayerStatus:CHECK_STATUS];
            NSLog(@"%@ check+1", curPlayer.playerName);
        }
    }
    
    //[self recalculatePotSize:[curPlayer.playerBetSize floatValue] newBet:playerBet];
    /*[curPlayer addToTotalBetSize:playerBet - [curPlayer.playerBetSize floatValue]];
    //[self recalculatePotSize];
    [self recalculateALLbet];
    
    //[curPlayer clearBetSize];
    [curPlayer changeBetSize:playerBet - [curPlayer.playerBetSize floatValue]];*/
    //[curPlayer changeBetSize:playerBet];
    
    [self makeBetForPlayer:curPlayer newPlayerBet:playerBet];
    [self recalculateALLbet];
    
    self.betSlider.enabled = NO;
    self.betSlider.alpha = 0.5;
    self.betSlider.value = 0;
    
    //[self hideMenu];
    [self refreshMenuInfo];
    [self refreshPlayersInfo];
    [self resfreshMaxBetValue];
    
    sender.enabled = NO;
    sender.alpha = 0.5;
    
    [self menuNextPlayerBtnClicked:NULL];
}

- (IBAction)foldBtnClicked:(id)sender
{
    NSInteger tag = self.menuView.tag - MENU_TAG_OFFSET;
    
    Player *curPlayer = [self getPlayerWithIndex:tag];
    [curPlayer changePlayerFoldedCardsValue:YES];
    
    UIButton *card1 = (UIButton*)[self.boardView viewWithTag:tag*10+FIRST_CARD_OFFSET];
    UIButton *card2 = (UIButton*)[self.boardView viewWithTag:tag*10+SECOND_CARD_OFFSET];
    
    card1.hidden = YES;
    card2.hidden = YES;

    [self refreshMenuInfo];
    [self refreshPlayersInfo];
    
    [curPlayer addToPlayerAllAction:FOLD];
    [curPlayer changePlayerStatus:FOLD_STATUS];
    NSLog(@"%@ folds+1", curPlayer.playerName);
    
    [self menuNextPlayerBtnClicked:NULL];
}

#pragma mark - Non Empty and non Folded Player Count
- (NSInteger)currentPlayersCount
{
    //NSInteger currentPlayersCount = [players count];
    NSInteger currentPlayersCount = 0;
    
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount]; i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        /*if ([curPlayer isPlayerIsOpenSeat] || [curPlayer.playerFoldedCards boolValue])
        {
            currentPlayersCount--;
        }*/
        
        if (![curPlayer isPlayerIsOpenSeat] && ![curPlayer.playerFoldedCards boolValue])
        {
            currentPlayersCount++;
        }
    }
    
    return currentPlayersCount;
}

- (NSInteger)firstNonEmptyPlayerPosition
{
    NSInteger value = 0;
    
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        if ([curPlayer isPlayerIsOpenSeat])
        {
            value = i;
            return value;
        }
    }
    
    return value;
}

- (NSInteger)playerPositionForName:(NSString*)playerName
{
    for(int i=0; i< [settings getNumberOfPlayersForCurrentCount];i++)
    {
        Player *curPlayer = [self getPlayerWithIndex:i];
        if (![curPlayer isPlayerIsOpenSeat] && [curPlayer.playerName isEqualToString:playerName])
        {
            return i;
        }
    }
    
    return -1;
}

- (void)makeBetForPlayer:(Player*)curPlayer newPlayerBet:(float)newPlayerBet
{
    float playerBet = newPlayerBet - [curPlayer.playerBetSize floatValue];
    [curPlayer changeBetSize:playerBet];
    [curPlayer addToTotalBetSize:playerBet];
}

#pragma mark - menu bet Btn clicked
- (IBAction)betFirstBtnClicked:(id)sender
{
    NSInteger playerPosition = self.menuView.tag - MENU_TAG_OFFSET;
    Player *curPlayer = [self getPlayerWithIndex:playerPosition];
    
    float playerBet = 0;
    
    if ([self ifPreflopStage])
    {
        playerBet = [settings.settingsMaxLimit integerValue]*2;
    }
    else
    {
        playerBet = (float)potSize/4;
    }
    
    /*if ([self ifPlayerIsSB:playerPosition])
    {
        playerBet = playerBet - [settings.settingsMinLimit floatValue];
    }
    else if ([self ifPlayerIsBB:playerPosition])
    {
        playerBet = playerBet - [settings.settingsMaxLimit floatValue];
    }
    
    //[self recalculatePotSize:[curPlayer.playerBetSize floatValue] newBet:playerBet];
    [curPlayer addToTotalBetSize:playerBet];
    //[self recalculatePotSize];*/
    
    [self makeBetForPlayer:curPlayer newPlayerBet:playerBet];
    [self recalculateALLbet];
    

    //[curPlayer changeBetSize:playerBet];
    
    self.betSlider.enabled = YES;
    self.betSlider.alpha = 1;
    self.betSlider.value = playerBet;
    
    [self refreshMenuInfo];
    [self refreshPlayersInfo];
    [self resfreshMaxBetValue];
    
    [self betActionStatistic:curPlayer];
    [self menuNextPlayerBtnClicked:NULL];
}

- (IBAction)betSecondBtnClicked:(id)sender
{
    NSInteger playerPosition = self.menuView.tag - MENU_TAG_OFFSET;
    Player *curPlayer = [self getPlayerWithIndex:playerPosition];
    
    float playerBet = 0;
    
    if ([self ifPreflopStage])
    {
        playerBet = [settings.settingsMaxLimit integerValue]*3;
    }
    else
    {
        playerBet = (float)potSize/2;
    }
    
    /*if ([self ifPlayerIsSB:playerPosition])
    {
        playerBet = playerBet - [settings.settingsMinLimit floatValue];
    }
    else if ([self ifPlayerIsBB:playerPosition])
    {
        playerBet = playerBet - [settings.settingsMaxLimit floatValue];
    }
    
    //[self recalculatePotSize:[curPlayer.playerBetSize floatValue] newBet:playerBet];
    [curPlayer addToTotalBetSize:playerBet];
    //[self recalculatePotSize];
    [self recalculateALLbet];
    //[curPlayer changeBetSize:playerBet];*/
    
    [self makeBetForPlayer:curPlayer newPlayerBet:playerBet];
    [self recalculateALLbet];
    
    self.betSlider.enabled = YES;
    self.betSlider.alpha = 1;
    self.betSlider.value = playerBet;
    
    [self refreshMenuInfo];
    [self refreshPlayersInfo];
    [self resfreshMaxBetValue];
    
    [self betActionStatistic:curPlayer];
    [self menuNextPlayerBtnClicked:NULL];
}

- (IBAction)betThirdBtnClicked:(id)sender
{
    NSInteger playerPosition = self.menuView.tag - MENU_TAG_OFFSET;
    Player *curPlayer = [self getPlayerWithIndex:playerPosition];
    
    float playerBet = 0;
    
    if ([self ifPreflopStage])
    {
        playerBet = [settings.settingsMaxLimit integerValue]*5;
    }
    else
    {
        playerBet = (float)potSize*0.75;
    }
    
    /*if ([self ifPlayerIsSB:playerPosition])
    {
        playerBet = playerBet - [settings.settingsMinLimit floatValue];
    }
    else if ([self ifPlayerIsBB:playerPosition])
    {
        playerBet = playerBet - [settings.settingsMaxLimit floatValue];
    }
    
    
    //[self recalculatePotSize:[curPlayer.playerBetSize floatValue] newBet:playerBet];
    [curPlayer addToTotalBetSize:playerBet];
    //[self recalculatePotSize];
    [self recalculateALLbet];

    
    [curPlayer changeBetSize:playerBet];*/
    
    [self makeBetForPlayer:curPlayer newPlayerBet:playerBet];
    [self recalculateALLbet];
    
    self.betSlider.enabled = YES;
    self.betSlider.alpha = 1;
    self.betSlider.value = playerBet;
    
    [self refreshMenuInfo];
    [self refreshPlayersInfo];
    [self resfreshMaxBetValue];
    
    [self betActionStatistic:curPlayer];
    [self menuNextPlayerBtnClicked:NULL];
}

- (IBAction)betFourthBtnClicked:(id)sender
{
    /*if (TRUE)
    {
        NSInteger playerPosition = self.menuView.tag - MENU_TAG_OFFSET;
        Player *curPlayer = [self getPlayerWithIndex:playerPosition];
        [curPlayer changeBetSize:0.0];
    }
    [self refreshMenuInfo];
    [self refreshPlayersInfo];
    [self resfreshMaxBetValue];
    
    return;*/
    
    NSInteger playerPosition = self.menuView.tag - MENU_TAG_OFFSET;
    Player *curPlayer = [self getPlayerWithIndex:playerPosition];
    
    float playerBet = 0;
    
    if ([self ifPreflopStage])
    {
        playerBet = [settings.settingsMaxLimit integerValue]*7;
    }
    else
    {
        playerBet = potSize;
    }
    
    /*if ([self ifPlayerIsSB:playerPosition])
    {
        playerBet = playerBet - [settings.settingsMinLimit floatValue];
    }
    else if ([self ifPlayerIsBB:playerPosition])
    {
        playerBet = playerBet - [settings.settingsMaxLimit floatValue];
    }
    
    //[self recalculatePotSize:[curPlayer.playerBetSize floatValue] newBet:playerBet];
    [curPlayer addToTotalBetSize:playerBet];
    //[self recalculatePotSize];
    [self recalculateALLbet];

    
    //[curPlayer changeBetSize:playerBet];
    
    [curPlayer changeBetSize:playerBet];*/
    
    [self makeBetForPlayer:curPlayer newPlayerBet:playerBet];
    [self recalculateALLbet];
    
    self.betSlider.enabled = YES;
    self.betSlider.alpha = 1;
    self.betSlider.value = playerBet;
    
    [self refreshMenuInfo];
    [self refreshPlayersInfo];
    [self resfreshMaxBetValue];
    
    [self betActionStatistic:curPlayer];
    [self menuNextPlayerBtnClicked:NULL];
}

#pragma mark - Add notes
- (IBAction)addNotesBtnClicked:(id)sender
{
    NSInteger playerPosition = self.menuView.tag - MENU_TAG_OFFSET;
    Player *curPlayer = [self getPlayerWithIndex:playerPosition];
    
    [notesVC showWithPlayer:curPlayer animated:YES];
}


#pragma mark - bet statistic calculate
- (void)betActionStatistic:(Player*)curPlayer
{
    NSInteger playerPosition = self.menuView.tag - MENU_TAG_OFFSET;
    
    /*if (playerPositionStatsCalculated == playerPosition)
    {
        NSLog(@"already calculated");
        return;
    }
    */
    
    playerPositionStatsCalculated = playerPosition;
    
    //change player VPIP
    if ([self ifPreflopStage])//so is preflop
    {
        if (curPlayer != NULL)
        {
            if ([self ifPlayerIsSB:playerPosition])
            {
                if ([curPlayer.playerBetSize integerValue] > [settings.settingsMinLimit integerValue])
                {
                    //[curPlayer changePlayerVPIP:1];
                    [curPlayer addToPlayerAllAction:VPIP];
                    NSLog(@"%@ vpip+1", curPlayer.playerName);
                }
            }
            else if ([self ifPlayerIsBB:playerPosition])
            {
                if ([curPlayer.playerBetSize integerValue] > [settings.settingsMaxLimit integerValue])
                {
                    //[curPlayer changePlayerVPIP:1];
                    [curPlayer addToPlayerAllAction:VPIP];
                    NSLog(@"%@ vpip+1", curPlayer.playerName);
                }
            }
            else
            {
                //[curPlayer changePlayerVPIP:1];
                [curPlayer addToPlayerAllAction:VPIP];
                NSLog(@"%@ vpip+1", curPlayer.playerName);
            }
        }
    }
    
    //change player PFR
    if ([self ifPreflopStage])//so is preflop
    {
        float prevPlayerBet = currentMaxBet;
        prevPlayerBet = [self getPreviousPlayerBetSize:playerPosition];
        
        if ([curPlayer.playerBetSize integerValue] > prevPlayerBet)
        {
            ////#### cbet
            if (curPlayer != NULL)
            {
                if (curPlayer.playerStatus.integerValue == RAISE_STATUS || curPlayer.playerStatus.integerValue == BET_STATUS)
                {
                    [curPlayer addToPlayerAllAction:C_BET];
                    NSLog(@"%@ cbet+1", curPlayer.playerName);
                }
            }
            ////#### cbet
            
            //[curPlayer changePlayerPFR:1];
            [curPlayer addToPlayerAllAction:PFR];
            [curPlayer changePlayerStatus:RAISE_STATUS];
            NSLog(@"%@ pfr+1", curPlayer.playerName);
            
            ////#### 3bet
            Player *prevPlayer = [self getPreviousPlayer:playerPosition];
            
            if (prevPlayer != NULL)
            {
                if (prevPlayer.playerStatus.integerValue == RAISE_STATUS)
                {
                    [curPlayer addToPlayerAllAction:BET_3];
                    NSLog(@"%@ 3bet+1", curPlayer.playerName);
                }
            }
            ////#### 3bet
        }
    }
    else
    {
        float prevPlayerBet = currentMaxBet;
        prevPlayerBet = [self getPreviousPlayerBetSize:playerPosition];
        
        float playerBet = [curPlayer.playerBetSize floatValue];
        if (prevPlayerBet == 0 && playerBet > prevPlayerBet)
        {
            ////#### cbet
            if (curPlayer != NULL)
            {
                if (curPlayer.playerStatus.integerValue == RAISE_STATUS || curPlayer.playerStatus.integerValue == BET_STATUS)
                {
                    [curPlayer addToPlayerAllAction:C_BET];
                    NSLog(@"%@ cbet+1", curPlayer.playerName);
                }
            }
            ////#### cbet
            
            ////#### donk
            if (curPlayer != NULL)
            {
                if (curPlayer.playerStatus.integerValue != RAISE_STATUS || curPlayer.playerStatus.integerValue != BET_STATUS)
                {
                    [curPlayer addToPlayerAllAction:DONK_BET];
                    NSLog(@"%@ donk bet+1", curPlayer.playerName);
                }
            }
            ////#### donk
            
            [curPlayer addToPlayerAllAction:BET];
            [curPlayer changePlayerStatus:BET_STATUS];
            NSLog(@"%@ bets+1", curPlayer.playerName);
        }
        else if (playerBet > prevPlayerBet)
        {
            [curPlayer addToPlayerAllAction:RAISE];
            [curPlayer changePlayerStatus:RAISE_STATUS];
            NSLog(@"%@ raises+1", curPlayer.playerName);
            
            ////#### 3bet
            Player *prevPlayer = [self getPreviousPlayer:playerPosition];  
            
            if (prevPlayer != NULL)
            {
                if (prevPlayer.playerStatus.integerValue == RAISE_STATUS)
                {
                    [curPlayer addToPlayerAllAction:BET_3];
                    NSLog(@"%@ 3bet+1", curPlayer.playerName);
                }
            }
            ////#### 3bet
        }
        //else ([curPlayer.playerBetSize integerValue] > currentMaxBet)
    }
    
    ////#### 3bet OPP
    /*Player *prevPlayer = [self getPreviousPlayer:playerPosition];
    
    if (prevPlayer != NULL)
    {
        if (prevPlayer.playerStatus.integerValue == RAISE_STATUS)
        {
            [curPlayer addToPlayerAllAction:BET_3_OPP];
            NSLog(@"%@ 3betOpp+1", curPlayer.playerName);
        }
    }*/
    ////#### 3bet OPP

}

#pragma mark - addPlayersVC delegates
- (void)newPlayerWasSelected:(NSString*)playerName
{
    NSString *selectedPlayerStr = playerName;
    Player *changedPlayer = [appDelegate.dataManager getPlayerByName:selectedPlayerStr];
    NSInteger changedPlayerPosition = [self playerPositionForName:changedPlayer.playerName];
    
    if (curMenuPlayerPosition >= 0 && curMenuPlayerPosition < [players count])
    {
        Player *oldPlayer = [players objectAtIndex:curMenuPlayerPosition];
        if (changedPlayerPosition >= 0 && changedPlayerPosition < [settings getNumberOfPlayersForCurrentCount])
        {
            [players replaceObjectAtIndex:changedPlayerPosition withObject:oldPlayer];
        }
        
        [players replaceObjectAtIndex:curMenuPlayerPosition withObject:changedPlayer];
        [self refreshPlayersInfo];
    }
}

#pragma mark - Objects Frames
- (void)setObjectsFrames
{
    //[NSValue valueWithCGRect:CGRectMake(, , DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
    
    if ([settings getNumberOfPlayersForCurrentCount] <= 6)
    {
        dealerBtnFrames = [NSArray arrayWithObjects:
                           [NSValue valueWithCGRect:CGRectMake(99, 121, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],//hero stats
                           [NSValue valueWithCGRect:CGRectMake(232, 99, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(368, 121, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(368, 161, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(232, 174, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(99, 161, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(-10, -10, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(-10, -10, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(-10, -10, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(-10, -10, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           nil];
        
        statsLabelsFrames = [NSArray arrayWithObjects:
                             [NSValue valueWithCGRect:CGRectMake(23, 39, STATS_WIDTH, STATS_HEIGTH)],//hero stats
                             [NSValue valueWithCGRect:CGRectMake(195, 20, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(363, 39, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(363, 215, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(195, 228, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(23, 215, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(-10, -10, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(-10, -10, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(-10, -10, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(-10, -10, STATS_WIDTH, STATS_HEIGTH)],
                             nil];
        
        cardFrames = [NSArray arrayWithObjects:
                      [NSValue valueWithCGRect:CGRectMake(80, 86, CARD_WIDTH, CARD_HEIGTH)],//hero cards
                      [NSValue valueWithCGRect:CGRectMake(99, 86, CARD_WIDTH, CARD_HEIGTH)],//player 1 cards
                      [NSValue valueWithCGRect:CGRectMake(222, 68, CARD_WIDTH, CARD_HEIGTH)],//etc
                      [NSValue valueWithCGRect:CGRectMake(241, 68, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(362, 86, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(381, 86, CARD_WIDTH,CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(362, 181, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(381, 181, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(222, 193, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(241, 193, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(80, 181, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(99, 181, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(-10, -10, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(-10, -10, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(-10, -10, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(-10, -10, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(-10, -10, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(-10, -10, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(-10, -10, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(-10, -10, CARD_WIDTH, CARD_HEIGTH)],
                      nil];
        
        cardAngles = [NSArray arrayWithObjects:
                      [NSNumber numberWithInt:-45],//hero cards
                      [NSNumber numberWithInt:0],//player 1 cards
                      [NSNumber numberWithInt:45],//etc
                      [NSNumber numberWithInt:-45],
                      [NSNumber numberWithInt:0],
                      [NSNumber numberWithInt:45],
                      [NSNumber numberWithInt:0],
                      [NSNumber numberWithInt:0],
                      [NSNumber numberWithInt:0],
                      [NSNumber numberWithInt:0],
                      nil];
    }
    else if ([settings getNumberOfPlayersForCurrentCount] >6 && [settings getNumberOfPlayersForCurrentCount] < 10)
    {
        dealerBtnFrames = [NSArray arrayWithObjects:
                           [NSValue valueWithCGRect:CGRectMake(141, 111, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],//hero stats
                           [NSValue valueWithCGRect:CGRectMake(199, 94, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(275, 94, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(324, 111, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(324, 156, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(302, 176, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(235, 180, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(161, 176, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(143, 156, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(-10, -10, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           nil];
        
        statsLabelsFrames = [NSArray arrayWithObjects:
                             [NSValue valueWithCGRect:CGRectMake(28, 45, STATS_WIDTH, STATS_HEIGTH)],//hero stats
                             [NSValue valueWithCGRect:CGRectMake(138, 18, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(253, 18, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(363, 45, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(379, 159, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(309, 224, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(195, 233, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(81, 224, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(9, 159, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(-10, -10, STATS_WIDTH, STATS_HEIGTH)],
                             nil];
        
        cardFrames = [NSArray arrayWithObjects:
                      [NSValue valueWithCGRect:CGRectMake(103, 91, CARD_WIDTH, CARD_HEIGTH)],//hero cards
                      [NSValue valueWithCGRect:CGRectMake(122, 91, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(187, 63, CARD_WIDTH, CARD_HEIGTH)],//player 1 cards
                      [NSValue valueWithCGRect:CGRectMake(208, 63, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(263, 63, CARD_WIDTH, CARD_HEIGTH)],//etc
                      [NSValue valueWithCGRect:CGRectMake(284, 63, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(339, 91, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(358, 91, CARD_WIDTH,CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(339, 154, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(358, 154, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(305, 193, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(324, 193, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(221, 197, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(241, 197, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(138, 193, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(157, 193, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(103, 154, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(122, 154, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(-10, -10, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(-10, -10, CARD_WIDTH, CARD_HEIGTH)],
                      nil];
        
        cardAngles = [NSArray arrayWithObjects:
                      [NSNumber numberWithInt:-38],//hero cards
                      [NSNumber numberWithInt:0],//player 1 cards
                      [NSNumber numberWithInt:0],//etc
                      [NSNumber numberWithInt:38],
                      [NSNumber numberWithInt:-60],
                      [NSNumber numberWithInt:-18],
                      [NSNumber numberWithInt:0],
                      [NSNumber numberWithInt:18],
                      [NSNumber numberWithInt:60],
                      [NSNumber numberWithInt:0],
                      nil];
    }
    else
    {
        statsLabelsFrames = [NSArray arrayWithObjects:
                             [NSValue valueWithCGRect:CGRectMake(81, 22, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(196, 18, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(305, 22, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(379, 90, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(379, 158, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(305, 227, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(196, 231, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(81, 227, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(9, 158, STATS_WIDTH, STATS_HEIGTH)],
                             [NSValue valueWithCGRect:CGRectMake(9, 90, STATS_WIDTH, STATS_HEIGTH)],
                             nil];
        
        
        cardFrames = [NSArray arrayWithObjects:
                      [NSValue valueWithCGRect:CGRectMake(138, 70, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(157, 70, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(222, 64, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(241, 64, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(305, 70, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(324, 70, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(339, 108, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(358, 108, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(339, 154, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(358, 154, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(305, 193, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(324, 193, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(222, 197, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(241, 197, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(138, 193, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(157, 193, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(103, 154, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(122, 154, CARD_WIDTH, CARD_HEIGTH)],
                      
                      [NSValue valueWithCGRect:CGRectMake(103, 108, CARD_WIDTH, CARD_HEIGTH)],
                      [NSValue valueWithCGRect:CGRectMake(122, 108, CARD_WIDTH, CARD_HEIGTH)],

                      nil];
        
        dealerBtnFrames = [NSArray arrayWithObjects:
                           [NSValue valueWithCGRect:CGRectMake(161, 98, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(235, 95, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(302, 98, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(324, 123, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(324, 156, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(302, 176, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(235, 180, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(161, 176, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(143, 156, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           [NSValue valueWithCGRect:CGRectMake(143, 123, DEALER_BTN_HEIGTH, DEALER_BTN_HEIGTH)],
                           nil];
        
        cardAngles = [NSArray arrayWithObjects:
                      [NSNumber numberWithInt:0],//hero cards
                      [NSNumber numberWithInt:0],//player 1 cards
                      [NSNumber numberWithInt:0],//etc
                      [NSNumber numberWithInt:60],
                      [NSNumber numberWithInt:-60],
                      [NSNumber numberWithInt:0],
                      [NSNumber numberWithInt:0],
                      [NSNumber numberWithInt:0],
                      [NSNumber numberWithInt:60],
                      [NSNumber numberWithInt:-60],
                      nil];
    }
}

- (void)viewDidUnload
{
    [self setContentView:nil];
    [self setBoardView:nil];
    [self setBoardImageView:nil];
    [self setTopView:nil];
    [self setPotSizeField:nil];
    [self setCard1:nil];
    [self setCard2:nil];
    [self setCard3:nil];
    [self setCard4:nil];
    [self setCard5:nil];
    [self setBackBtn:nil];
    [self setBetTextFiled:nil];
    [self setMenuView:nil];
    [self setStatsTextField0:nil];
    [self setStatsTextField1:nil];
    [self setStatsTextField2:nil];
    [self setCard01:nil];
    [self setCard02:nil];
    [self setCard11:nil];
    [self setCard12:nil];
    [self setCard21:nil];
    [self setCard22:nil];
    [self setDealBtn:nil];
    [self setWinnerBtn:nil];
    [self setFlopBtn:nil];
    [self setMenuNameField:nil];
    [self setMenuStackField:nil];
    [self setMenuStatsField:nil];
    [self setBetRaiseBtn:nil];
    [self setCheckBtn:nil];
    [self setFoldBtn:nil];
    [self setMenuBetField:nil];
    [self setMenuHide:nil];
    [self setRaiseBtn:nil];
    [self setCard41:nil];
    [self setCard42:nil];
    [self setCard31:nil];
    [self setCard32:nil];
    [self setCard51:nil];
    [self setCard52:nil];
    [self setCard61:nil];
    [self setCard62:nil];
    [self setCard71:nil];
    [self setCard72:nil];
    [self setCard81:nil];
    [self setCard82:nil];
    [self setCard91:nil];
    [self setCard92:nil];
    [self setStatsTextField3:nil];
    [self setStatsTextField4:nil];
    [self setStatsTextField6:nil];
    [self setStatsTextField5:nil];
    [self setStatsTextField7:nil];
    [self setStatsTextField8:nil];
    [self setStatsTextField9:nil];
    [self setMenuNextPlayerBtn:nil];
    [self setBetSlider:nil];
    [self setDealerBtn:nil];
    [self setBetFirstBtn:nil];
    [self setBetSecondBtn:nil];
    [self setBetThirdBtn:nil];
    [self setBetFourthBtn:nil];
    [self setAllBets:nil];
    [self setAddNote:nil];
    [self setMenuStatsExtendedField:nil];
    [self setMenuStatsExtendedBkg:nil];
    [super viewDidUnload];
}

@end
