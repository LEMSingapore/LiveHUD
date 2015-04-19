//
//  BoardViewController.m
//  Poker Live
//
//  Created by Denis Senichkin on 2/14/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "BoardViewController.h"

#define PLAYER_STATS 1
#define PLAYER_NAME 2
#define PLAYER_STACK 3
#define PLAYER_CARD1 4
#define PLAYER_CARD2 5
#define PLAYER_CARD_BET_SIZE 6
#define PLAYER_CARD_BET_BTN 7
#define PLAYER_BU_SB_BB 8
#define PLAYER_CARDS_FOLDED 9

#define PICKER_WINNER 1
#define PICKER_BU 2
#define PICKER_BET_RAISE 3
#define PICKER_CHECK 4
#define PICKER_FOLDED 9

@interface BoardViewController ()

@end

@implementation BoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = [AppDelegate sharedAppDelegate];
        settings = [appDelegate.dataManager getSettingsEntry];
        players = [NSMutableDictionary new];
        doublePicker = [[DoubleComponentInPickerViewViewController alloc] initWithNibName:@"DoubleComponentInPickerViewViewController" bundle:nil];
        doublePicker.delegate = self;
        
        pickerVC = [[PickerVC alloc] initWithNibName:@"PickerVC" bundle:nil];
        pickerVC.delegate = self;
        
        cardsPickerVC = [[CardsPickerVC alloc] initWithNibName:@"CardsPickerVC" bundle:nil];
        cardsPickerVC.delegate = self;
        
        CELL_DEFAULT_HEIGHT = 100;
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

- (void)viewDidUnload {
    [self setBackBtn:nil];
    [self setMyTableView:nil];
    [self setBetTextFiled:nil];
    [self setPotSizeField:nil];
    [self setCard1:nil];
    [self setCard2:nil];
    [self setCard3:nil];
    [self setCard4:nil];
    [self setCard5:nil];
    [self setFlopBtn:nil];
    [self setFoldBtn:nil];
    [self setDealBtn:nil];
    [self setWinnerBtn:nil];
    [self setBetRaiseBtn:nil];
    [self setCheckBtn:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (IS_IPHONE_5)
    {
        CELL_DEFAULT_HEIGHT = 97;
        
        CGRect frame = self.myTableView.frame;
        frame.size.height = CELL_DEFAULT_HEIGHT*4;
        self.myTableView.frame = frame;
    }

    
    [self.view addSubview:doublePicker.view];
    [self.view addSubview:pickerVC.view];
    doublePicker.view.hidden = YES;
    
    [self.view addSubview:cardsPickerVC.view];
    
    recalcStats = YES;
    calcPlayerStats = NO;
    currentMaxBet = [settings.settingsMaxLimit integerValue];
    
    self.betTextFiled.text = [settings getMinMaxLimitString];
    
    for(NSInteger i=0; i < [settings.settingsNumberOfPlayers integerValue]; i++)
    {
        NSString *playerName;
        switch (i)
        {
            case 0:
            {
                playerName = settings.settingsHeroName;
            }
                break;
            case 1:
            {
                playerName = settings.settingsPlayer1;
            }
                break;
            case 2:
            {
                playerName = settings.settingsPlayer2;
            }
                break;
            case 3:
            {
                playerName = settings.settingsPlayer3;
            }
                break;
            case 4:
            {
                playerName = settings.settingsPlayer4;
            }
                break;
            case 5:
            {
                playerName = settings.settingsPlayer5;
            }
                break;
            case 6:
            {
                playerName = settings.settingsPlayer6;
            }
                break;
            case 7:
            {
                playerName = settings.settingsPlayer7;
            }
                break;
            case 8:
            {
                playerName = settings.settingsPlayer8;
            }
                break;
            case 9:
            {
                playerName = settings.settingsPlayer9;
            }
                break;
                
            default:
                break;
        }
        
        Player *curPlayer;
        if (playerName != NULL)
        {
            curPlayer  = [appDelegate.dataManager getPlayerByName:playerName];
        }
        else
        {
            
            playerName = [NSString stringWithFormat:@"Player%@", [NSNumber numberWithInteger:i]];
            curPlayer  = [appDelegate.dataManager getPlayerByName:playerName];
        }
        
        if (curPlayer != NULL)
        {
            NSString *playerDictPos = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:i]];
            [players setObject:curPlayer forKey:playerDictPos];
            
            curPlayer.playerCard1 = NULL;
            curPlayer.playerCard2 = NULL;
        }
    }
    
    Player *curPlayer  = [appDelegate.dataManager getPlayerByName:settings.settingsHeroName];
    startHeroMoney = [curPlayer.playerStackSize integerValue];
    
    [self clearPlayerBets];

    currentBU = -10;
    potSize = 0;
    
    [self.myTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)  name:UIKeyboardWillHideNotification object:nil];
    
    //[self showBUSelectPicker];
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
        [appDelegate.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (IS_IPHONE_5)
    {
        if ([settings getNumberOfPlayers] > 0 && [settings getNumberOfPlayers] > 4)
        {
            return [settings getNumberOfPlayers];
        }
        
        return 4;
    }
    
    else
    {
        
        if ([settings getNumberOfPlayers] > 0 && [settings getNumberOfPlayers] > 3)
        {
            return [settings getNumberOfPlayers];
        }
    }
    
    return 3;
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
        
        UITextField *label1 = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, CELL_DEFAULT_HEIGHT+1)];
        label1.borderStyle = UITextBorderStyleLine;label1.userInteractionEnabled = NO;
        [cell.contentView addSubview:label1];
        UITextField *label2 = [[UITextField alloc] initWithFrame:CGRectMake(99, 0, 20, CELL_DEFAULT_HEIGHT+1)];
        label2.borderStyle = UITextBorderStyleLine;label2.userInteractionEnabled = NO;
        [cell.contentView addSubview:label2];
        UITextField *label3 = [[UITextField alloc] initWithFrame:CGRectMake(118, 0, 100, CELL_DEFAULT_HEIGHT+1)];
        label3.borderStyle = UITextBorderStyleLine;label3.userInteractionEnabled = NO;
        [cell.contentView addSubview:label3];
        UITextField *label4 = [[UITextField alloc] initWithFrame:CGRectMake(217, 0, cell.frame.size.width - 162, CELL_DEFAULT_HEIGHT+1)];
        label4.borderStyle = UITextBorderStyleLine;label4.userInteractionEnabled = NO;label4.backgroundColor = [UIColor colorWithRed:0 green:125.0/255.0 blue:0 alpha:1];
        [cell.contentView addSubview:label4];
    }
    
    for(UIView *view in cell.contentView.subviews)
    {
        if (view.tag > 0)
        {
            [view removeFromSuperview];
        }
    }
    
    if (indexPath.row < [settings getNumberOfPlayers])
    {
        UITextField *statsField = [[UITextField alloc] initWithFrame:CGRectMake(4, 6, 92, 22)];statsField.userInteractionEnabled = NO;
        statsField.placeholder = @"vPip-PFR-AGG";statsField.font = [UIFont fontWithName:@"Helvetica" size:11];
        statsField.tag = indexPath.row*10+PLAYER_STATS;statsField.borderStyle = UITextBorderStyleBezel;statsField.autocorrectionType = UITextAutocorrectionTypeNo;
        [cell.contentView addSubview:statsField];
        
        UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(4, 38, 92, 22)];nameField.userInteractionEnabled = NO;nameField.delegate = self;
        [nameField setReturnKeyType:UIReturnKeyDone];
        nameField.placeholder = @"Enter plr name";nameField.font = [UIFont fontWithName:@"Helvetica" size:11];nameField.autocorrectionType = UITextAutocorrectionTypeYes;
        nameField.tag = indexPath.row*10+PLAYER_NAME;nameField.borderStyle = UITextBorderStyleRoundedRect;
        nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        [cell.contentView addSubview:nameField];
        
        UITextField *stackField = [[UITextField alloc] initWithFrame:CGRectMake(4, 70, 92, 22)];stackField.userInteractionEnabled = NO;stackField.delegate = self;
        [stackField setReturnKeyType:UIReturnKeyDone];
        stackField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        stackField.placeholder = @"Enter stack size";stackField.font = [UIFont fontWithName:@"Helvetica" size:11];
        stackField.tag = indexPath.row*10+PLAYER_STACK;stackField.borderStyle = UITextBorderStyleRoundedRect;stackField.autocorrectionType = UITextAutocorrectionTypeNo;
        [cell.contentView addSubview:stackField];
        
        UIButton *card1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        card1.frame = CGRectMake(220, 10, 45, 80);[card1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [card1 setBackgroundImage:[UIImage imageNamed:@"CardShirt.jpg"] forState:UIControlStateNormal];
        card1.backgroundColor = [UIColor clearColor];
        card1.tag = indexPath.row*10+PLAYER_CARD1;
        [card1 addTarget:self action:@selector(card1Clicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:card1];
        
        UIButton *card2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        card2.frame = CGRectMake(270, 10, 45, 80);[card2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        card2.backgroundColor = [UIColor clearColor];
        card2.tag = indexPath.row*10+PLAYER_CARD2;
        [card2 setBackgroundImage:[UIImage imageNamed:@"CardShirt.jpg"] forState:UIControlStateNormal];
        [card2 addTarget:self action:@selector(card2Clicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:card2];
        
        UIButton *betLabelBtn = [UIButton buttonWithType:UIButtonTypeCustom]; betLabelBtn.frame = CGRectMake(120, 5, 96, CELL_DEFAULT_HEIGHT-10);
        //[betLabelBtn setTitle:@"Click for bet" forState:UIControlStateNormal];
        betLabelBtn.titleLabel.textColor = [UIColor redColor];
        betLabelBtn.tag = indexPath.row*10+PLAYER_CARD_BET_BTN;betLabelBtn.backgroundColor = [UIColor clearColor];
        [betLabelBtn addTarget:self action:@selector(betLabelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:betLabelBtn];
        
        UITextField *betLabel = [[UITextField alloc] initWithFrame:CGRectMake(123, 20, 90, 20)];
        betLabel.font = [UIFont systemFontOfSize:11];betLabel.borderStyle = UITextBorderStyleLine;[betLabel setReturnKeyType:UIReturnKeyDone];
        betLabel.placeholder = @"Enter bet";betLabel.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        betLabel.tag = indexPath.row*10+PLAYER_CARD_BET_SIZE;betLabel.delegate = self;
        [cell.contentView addSubview:betLabel];
        

        
        if (indexPath.row == 0)
        {
            Player *curPlayer = [players objectForKey:@"0"];
            
            if (curPlayer.playerCard1 != NULL)
            {
                [card1 setBackgroundImage:[UIImage imageNamed:@"CardFace.jpg"] forState:UIControlStateNormal];
                [card1.titleLabel setFont:[UIFont boldSystemFontOfSize:28]];
                [card1 setTitle:curPlayer.playerCard1 forState:UIControlStateNormal];
            }
            else
            {
                [card1 setBackgroundImage:[UIImage imageNamed:@"CardShirt.jpg"] forState:UIControlStateNormal];
                [card1 setTitle:@"Click" forState:UIControlStateNormal];
                [card1.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
            }
            
            if (curPlayer.playerCard2 != NULL)
            {
                [card2 setBackgroundImage:[UIImage imageNamed:@"CardFace.jpg"] forState:UIControlStateNormal];
                [card2.titleLabel setFont:[UIFont boldSystemFontOfSize:28]];
                [card2 setTitle:curPlayer.playerCard2 forState:UIControlStateNormal];
            }
            else
            {
                [card2 setBackgroundImage:[UIImage imageNamed:@"CardShirt.jpg"] forState:UIControlStateNormal];
                [card2 setTitle:@"Click" forState:UIControlStateNormal];
                [card2.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
            }
        }
        else
        {
            card1.userInteractionEnabled = NO;
            card2.userInteractionEnabled = NO;
        }
        
        if (indexPath.row == currentBU)
        {
            UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(102, 1, 16, CELL_DEFAULT_HEIGHT-20)];
            label4.userInteractionEnabled = NO;label4.tag = PLAYER_BU_SB_BB;
            label4.text = @"B\nU";label4.numberOfLines = 0;
            [cell.contentView addSubview:label4];
        }
        else if (indexPath.row == currentBU+1 || indexPath.row == (currentBU + 1 - [settings.settingsNumberOfPlayers integerValue]))
        {
            UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(102, 1, 16, CELL_DEFAULT_HEIGHT-20)];
            label4.userInteractionEnabled = NO;label4.tag = PLAYER_BU_SB_BB;
            label4.text = @"S\nB";label4.numberOfLines = 0;
            [cell.contentView addSubview:label4];
        }
        else if (indexPath.row == currentBU+2 || indexPath.row == (currentBU + 2 - [settings.settingsNumberOfPlayers integerValue]))
        {
            UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(102, 1, 16, CELL_DEFAULT_HEIGHT-20)];
            label4.userInteractionEnabled = NO;label4.tag = PLAYER_BU_SB_BB;
            label4.text = @"B\nB";label4.numberOfLines = 0;
            [cell.contentView addSubview:label4];
        }
        
        
        NSString *idStr = [@(indexPath.row) stringValue];
        
        Player *curPlayer = [players objectForKey:idStr];
        if (curPlayer != NULL)
        {
            nameField.text = curPlayer.playerName;
            stackField.text = [curPlayer.playerStackSize stringValue];
            
            
            if (recalcStats)
            {
                statsField.text = [curPlayer getPlayerStatistic];
            }
            else
            {
                statsField.text = [curPlayer playerStatsString];
            }
            
            if ([curPlayer.playerFoldedCards boolValue])
            {
                UIImageView *imageTmp = [[UIImageView alloc] initWithFrame:CGRectMake(218, 1, 110, CELL_DEFAULT_HEIGHT-1)];
                imageTmp.image = [UIImage imageNamed:@"cardsFolded.jpg"];imageTmp.contentMode = UIViewContentModeScaleToFill;
                imageTmp.tag = PLAYER_CARDS_FOLDED;
                [cell.contentView addSubview:imageTmp];
            }
            
            //preflop in BB, else in % of pot size
            if ([curPlayer.playerBetSize integerValue] == 0)
            {
                betLabel.text = [curPlayer.playerBetSize stringValue];
            }
            else
            {
                if ([self ifPreflopStage])
                {
                    if ([self ifPlayerIsSB:indexPath.row] && [curPlayer.playerBetSize integerValue]==[settings.settingsMinLimit integerValue])
                    {
                        betLabel.text = [curPlayer.playerBetSize stringValue];
                    }
                    else if ([self ifPlayerIsBB:indexPath.row] && [curPlayer.playerBetSize integerValue]==[settings.settingsMaxLimit integerValue])
                    {
                        betLabel.text = [curPlayer.playerBetSize stringValue];
                    }
                    else
                    {
                        NSString *betStr = [NSString stringWithFormat:@"%.2f BB", [curPlayer.playerBetSize floatValue]/[settings.settingsMaxLimit floatValue]];
                        betLabel.text = betStr;
                    }
                }
                else
                {
                    
                    NSString *betStr = [NSString stringWithFormat:@"%.0f%%", ([curPlayer.playerBetSize floatValue]*100)/potSize];
                    betLabel.text = betStr;
                }
            }
            //betLabel.text = [curPlayer.playerBetSize stringValue];
        }
    }
 
    return cell;
}

-(BOOL)ifPreflopStage
{
    if (self.card1.hidden == YES)
    {
        return YES;
    }
    
    return NO;
}

-(BOOL)ifPlayerIsSB:(NSInteger)position
{
    if (position == currentBU+1 || position == (currentBU + 1 - [settings.settingsNumberOfPlayers integerValue]))
    {
        return YES;
    }
    
    return NO;
}

-(BOOL)ifPlayerIsBB:(NSInteger)position
{
    if (position == currentBU+2 || position == (currentBU + 2 - [settings.settingsNumberOfPlayers integerValue]))
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return CELL_DEFAULT_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:@"Set current player as \"BU\"?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    //alert.tag = indexPath.row;
    //[alert show];
}


#pragma mark - BetBtn Clicked
- (void)betLabelBtnClicked:(UIButton*)sender
{
    NSIndexPath *myIP = [NSIndexPath indexPathForRow:sender.tag/10 inSection:0];
    UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
    
    UITextField *betField = (UITextField *)[cell.contentView viewWithTag:sender.tag-1];
    [betField becomeFirstResponder];
}



#pragma mark - UITextField delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSInteger tag = textField.tag%10;
    //NSInteger row =  textField.tag/10;
    
    switch (tag)
    {
        case PLAYER_CARD_BET_SIZE:
        {
            
            NSString *str = [@(currentMaxBet) stringValue];
            textField.text = str;
        }
            break;
            
        default:
            break;
    }
    
    CGRect absRect = [textField.superview convertRect:textField.frame toView:NULL];
    NSInteger textFieldY = self.view.frame.origin.y + absRect.origin.y + textField.frame.size.height - 20;
    
    NSInteger keyboardYHeight = 245;
    NSInteger keyboardY = self.view.bounds.size.height - keyboardYHeight + 30;
    //NSLog(@"textFieldY = %d, absRect = %@, YOffset - %.f", textFieldY, NSStringFromCGRect(absRect), textFieldY - keyboardY + textField.frame.size.height);
    
    if (keyboardY < textFieldY)
    {
        [UIView animateWithDuration:0.3 animations:^
         {
             CGRect frame = self.view.frame;
             NSInteger yOffset = textFieldY - keyboardY + 3;
             frame.origin.y = -yOffset;
             self.view.frame = frame;
             
         }
         completion:^(BOOL finished)
         {
             
         }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^
         {
             CGRect frame = self.view.frame;
             frame.origin.y = 0;
             self.view.frame = frame;
             
         }
                         completion:^(BOOL finished)
         {
             
         }];
    }
    
    return YES;
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSInteger tag = textField.tag%10;
    
    switch (tag) {
        case PLAYER_STATS:
            break;
            
        case PLAYER_NAME:
        {
            if (textField.tag/10 == 0)
            {
                [settings changeSettingsHeroName:textField.text];
            }
                
            Player *curPlayer = [appDelegate.dataManager getPlayerByName:textField.text];
            
            NSString *idStr = [@(textField.tag/10) stringValue];
            [players setObject:curPlayer forKey:idStr];
            
            NSIndexPath *myIP = [NSIndexPath indexPathForRow:textField.tag/10 inSection:0];
            UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
            
            NSInteger row = textField.tag/10;
            if (cell!=NULL)
            {
                UITextField *stackField = (UITextField *)[cell.contentView viewWithTag:row*10+PLAYER_STACK];
                if ([stackField.text length]>0 && [stackField.text integerValue]>0)
                {
                    [curPlayer changeStackSize:[stackField.text integerValue]];
                }
            }

        }
            break;
            
        case PLAYER_STACK:
        {
            NSString *idStr = [@(textField.tag/10) stringValue];
            Player *curPlayer = [players objectForKey:idStr];

            if (curPlayer!=NULL)
            {
                [curPlayer changeStackSize:[textField.text integerValue]];
            }
            
        }
            break;
            
        case PLAYER_CARD_BET_SIZE:
        {
            NSString *idStr = [@(textField.tag/10) stringValue];
            Player *curPlayer = [players objectForKey:idStr];
            
            NSInteger playerBet = [textField.text integerValue];
            //potSize += playerBet;
            
            /*if ([curPlayer.playerBetSize integerValue]>0)
            {
                potSize-=curPlayer.playerBetSize.integerValue;
            }
            NSString *potSizeStr = [NSString stringWithFormat:@"%d", potSize];
            self.potSizeField.text = potSizeStr;*/
            
            if (curPlayer != NULL)
            {
                if ([curPlayer.playerBetSize integerValue]>0)
                {
                    [curPlayer changeStackSize:(curPlayer.playerStackSize.integerValue+curPlayer.playerBetSize.integerValue)];
                }
                
                [curPlayer changeBetSize:playerBet];
            }
            
            if (playerBet > currentMaxBet)
            {
                currentMaxBet = playerBet;
            }
            
            
            [self.myTableView reloadData];
        }
            break;
            
        default:
            break;
    }


    
    return YES;
}

#pragma mark - Card clicked
- (void)card1Clicked:(UIButton*)sender
{
    [doublePicker.mpicker reloadAllComponents];
    doublePicker.view.tag = sender.tag;
    doublePicker.view.hidden = NO;
}

- (void)card2Clicked:(UIButton*)sender
{
    [doublePicker.mpicker reloadAllComponents];
    doublePicker.view.tag = sender.tag;
    doublePicker.view.hidden = NO;
}

- (IBAction)boardCardClicked:(UIButton*)sender
{
    [doublePicker.mpicker reloadAllComponents];
    doublePicker.view.tag = sender.tag;
    doublePicker.view.hidden = NO;
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
            [self.card1 setBackgroundImage:[UIImage imageNamed:@"CardFace.jpg"] forState:UIControlStateNormal];
            
            settings.settingsCard1 = str;
        }
        else if (pickerView.view.tag == 102)
        {
            [self.card2 setTitle:str forState:UIControlStateNormal];
            [self.card2.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.card2 setBackgroundImage:[UIImage imageNamed:@"CardFace.jpg"] forState:UIControlStateNormal];
            
            settings.settingsCard2 = str;
        }
        else if (pickerView.view.tag == 103)
        {
            [self.card3 setTitle:str forState:UIControlStateNormal];
            [self.card3.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.card3 setBackgroundImage:[UIImage imageNamed:@"CardFace.jpg"] forState:UIControlStateNormal];
            
            settings.settingsCard3 = str;
        }
        else if (pickerView.view.tag == 104)
        {
            [self.card4 setTitle:str forState:UIControlStateNormal];
            [self.card4.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.card4 setBackgroundImage:[UIImage imageNamed:@"CardFace.jpg"] forState:UIControlStateNormal];
            
            settings.settingsCard4 = str;

        }
        else if (pickerView.view.tag == 105)
        {
            [self.card5 setTitle:str forState:UIControlStateNormal];
            [self.card5.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.card5 setBackgroundImage:[UIImage imageNamed:@"CardFace.jpg"] forState:UIControlStateNormal];
            
            settings.settingsCard5 = str;
        }
        else
        {
            NSIndexPath *myIP = [NSIndexPath indexPathForRow:pickerView.view.tag/10 inSection:0];
            UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
            
            UIButton *card = (UIButton *)[cell.contentView viewWithTag:pickerView.view.tag];
            [card setBackgroundImage:[UIImage imageNamed:@"CardFace.jpg"] forState:UIControlStateNormal];
            [card.titleLabel setFont:[UIFont boldSystemFontOfSize:28]];
            [card setTitle:str forState:UIControlStateNormal];
            
            
            Player *curPlayer = [players objectForKey:@"0"];
            if (curPlayer != NULL)
            {
                if (pickerView.view.tag % 10 == PLAYER_CARD1)
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

#pragma mark - flop btn clicked
- (IBAction)flopBtnClicked:(UIButton*)sender
{
    [self calcPlayerStats];
    calcPlayerStats = NO;
    
    Player *heroPlayer  = [appDelegate.dataManager getPlayerByName:settings.settingsHeroName];
    
    if ([self ifPlayerIsSB:0] && [heroPlayer.playerBetSize integerValue] > [settings.settingsMinLimit integerValue])
    {
        heroInvestMoney = YES;
    }
    else if ([self ifPlayerIsBB:0] && [heroPlayer.playerBetSize integerValue] > [settings.settingsMaxLimit integerValue])
    {
        heroInvestMoney = YES;
    }
    else if ([heroPlayer.playerBetSize integerValue] > 0)
    {
        heroInvestMoney = YES;
    }
    
    recalcStats = NO;
    currentMaxBet = [settings.settingsMaxLimit integerValue];
    
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
        //self.flopBtn.alpha = 0.5;
    }

    [self.myTableView reloadData];
}

- (IBAction)foldBtnClicked:(id)sender
{
    [self showPickerWithTitleAndTag:@"Select player" tag:PLAYER_CARDS_FOLDED];
}

- (IBAction)newDealBtn:(id)sender
{
    if (curSession == NULL)
    {
        curSession = [appDelegate.dataManager addSessionEntryWithLocationAndDate:settings.settingsLocationName date:[NSDate date]];
    }
    
    //add new hand for this session
    curHand = [appDelegate.dataManager addNewHandForSession:curSession];
    [curSession.sessionStats changeStatsHandsPlayed:1];
    heroInvestMoney = NO;
    
    [self.card1.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [self.card2.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [self.card3.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [self.card4.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [self.card5.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    self.card1.hidden = YES;[self.card1 setBackgroundImage:[UIImage imageNamed:@"CardShirt.jpg"] forState:UIControlStateNormal];[self.card1 setTitle:@"Click" forState:UIControlStateNormal];
    self.card2.hidden = YES;[self.card2 setBackgroundImage:[UIImage imageNamed:@"CardShirt.jpg"] forState:UIControlStateNormal];[self.card2 setTitle:@"Click" forState:UIControlStateNormal];
    self.card3.hidden = YES;[self.card3 setBackgroundImage:[UIImage imageNamed:@"CardShirt.jpg"] forState:UIControlStateNormal];[self.card3 setTitle:@"Click" forState:UIControlStateNormal];
    self.card4.hidden = YES;[self.card4 setBackgroundImage:[UIImage imageNamed:@"CardShirt.jpg"] forState:UIControlStateNormal];[self.card4 setTitle:@"Click" forState:UIControlStateNormal];
    self.card5.hidden = YES;[self.card5 setBackgroundImage:[UIImage imageNamed:@"CardShirt.jpg"] forState:UIControlStateNormal];[self.card5 setTitle:@"Click" forState:UIControlStateNormal];
    [self.flopBtn setTitle:@"Flop" forState:UIControlStateNormal];
    
    settings.settingsCard1 = NULL;
    settings.settingsCard2 = NULL;
    settings.settingsCard3 = NULL;
    settings.settingsCard4 = NULL;
    settings.settingsCard5 = NULL;
    
    NSIndexPath *myIP = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
    UIView *view = [cell.contentView viewWithTag:PLAYER_CARDS_FOLDED];
    if(view!=NULL)
    {
        [view removeFromSuperview];
    }
    
    UIButton *card1 = (UIButton*)[cell.contentView viewWithTag:PLAYER_CARD1];
    [card1 setBackgroundImage:[UIImage imageNamed:@"CardShirt.jpg"] forState:UIControlStateNormal];
    [card1 setTitle:@"Click" forState:UIControlStateNormal];
    [card1.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    
    UIButton *card2 = (UIButton*)[cell.contentView viewWithTag:PLAYER_CARD2];
    [card2 setBackgroundImage:[UIImage imageNamed:@"CardShirt.jpg"] forState:UIControlStateNormal];
    [card2 setTitle:@"Click" forState:UIControlStateNormal];
    [card2.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    
    potSize = 0;
    self.potSizeField.text = @"0";
    
    for(NSInteger i=0; i< [settings.settingsNumberOfPlayers integerValue];i++)
    {
        NSString *playerDictPos = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:i]];
        Player *curPlayer = [players objectForKey:playerDictPos];
        [curPlayer changeBetSize:0];
        [curPlayer changePlayerFoldedCardsValue:NO];
        
        NSLog(@"%@: playerStackSize = %@", curPlayer.playerName, [curPlayer.playerStackSize stringValue]);
    }
    
    self.betRaiseBtn.userInteractionEnabled = YES;
    self.betRaiseBtn.alpha = 1;
    self.checkBtn.userInteractionEnabled = YES;
    self.checkBtn.alpha = 1;
    self.flopBtn.userInteractionEnabled = YES;
    self.flopBtn.alpha = 1;
    self.foldBtn.userInteractionEnabled = YES;
    self.foldBtn.alpha = 1;
    self.winnerBtn.userInteractionEnabled = YES;
    self.winnerBtn.alpha = 1;
    self.dealBtn.userInteractionEnabled = NO;
    //self.dealBtn.alpha = 0.5;
    
    if (currentBU == -10)
    {
        [self showBUSelectPicker];
    }
    else
    {
        if (currentBU == [settings.settingsNumberOfPlayers integerValue])
        {
            currentBU = 0;
        }
        else
        {
            currentBU++;
        }
        
        for(NSInteger i=currentBU+1; i <= currentBU+2; i++)
        {
            NSInteger curPlayerPos = i;
            
            if (curPlayerPos + 1 > [settings.settingsNumberOfPlayers integerValue])
            {
                curPlayerPos = i - [settings.settingsNumberOfPlayers integerValue];
            }
            
            NSString *playerDictPos = [@(curPlayerPos) stringValue];
            Player *curPlayer = [players objectForKey:playerDictPos];
            
            if (i == currentBU + 1)
            {
                [curPlayer changeBetSize:[settings.settingsMinLimit integerValue]];
            }
            else if (i == currentBU + 2)
            {
                [curPlayer changeBetSize:[settings.settingsMaxLimit integerValue]];
            }
        }
    }
    
    currentMaxBet = [settings.settingsMaxLimit integerValue];
    
    calcPlayerStats = NO;
    
    //[self recalculatePotSize];
    
    [self.myTableView reloadData];
}

#pragma mark - Winner Btn
- (IBAction)winnerBtnClicked:(id)sender
{
    [self showPickerWithTitleAndTag:@"Select winner" tag:PICKER_WINNER];
}

- (void)showBUSelectPicker
{
    [self showPickerWithTitleAndTag:@"Select BU player" tag:PICKER_BU];
}

- (void)makeSBAndBBBets
{
    for(NSInteger i=currentBU+1; i <= currentBU+2; i++)
    {
        NSInteger curPlayerPos = i;
        
        if (curPlayerPos + 1 > [settings.settingsNumberOfPlayers integerValue])
        {
            curPlayerPos = i - [settings.settingsNumberOfPlayers integerValue];
        }
        
        NSString *playerDictPos = [@(curPlayerPos) stringValue];
        Player *curPlayer = [players objectForKey:playerDictPos];
        
        if (i == currentBU + 1)
        {
            [curPlayer changeBetSize:[settings.settingsMinLimit integerValue]];
        }
        else if (i == currentBU + 2)
        {
            [curPlayer changeBetSize:[settings.settingsMaxLimit integerValue]];
        }
    }
    
    [self.myTableView reloadData];
    //[self recalculatePotSize];
}

- (void)clearPlayerBets
{
    for(NSInteger i=0; i< [settings.settingsNumberOfPlayers integerValue];i++)
    {
        NSString *playerDictPos = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:i]];
        Player *curPlayer = [players objectForKey:playerDictPos];
        [curPlayer changeBetSize:0];
    }
    
   //[self recalculatePotSize];
}

#pragma mark - PickerVC Delegate Methods
- (void)pickerViewControllerDoneButtonClicked:(PickerVC *)pickerView
{
    //NSString *selectedValue = [pickerView getSelectedRowValueInComponent:0];
    switch (pickerVC.tag)
    {
        case PICKER_FOLDED:
        {
            NSString *selectedPlayerStr = [pickerView getSelectedRowValueInComponent:0];
            Player *curPlayer = [appDelegate.dataManager getPlayerByName:selectedPlayerStr];
            [curPlayer changePlayerFoldedCardsValue:YES];
        }
            break;
            
        case PICKER_WINNER:
        {
            if (calcPlayerStats == NO)
            {
                [self calcPlayerStats];
            }
            
            [self recalculatePotSize];
            
            
            self.betRaiseBtn.userInteractionEnabled = NO;
            self.betRaiseBtn.alpha = 0.5;
            self.checkBtn.userInteractionEnabled = NO;
            self.checkBtn.alpha = 0.5;
            self.flopBtn.userInteractionEnabled = NO;
            //self.flopBtn.alpha = 0.5;
            self.foldBtn.userInteractionEnabled = NO;
            self.foldBtn.alpha = 0.5;
            self.winnerBtn.userInteractionEnabled = NO;
            //self.winnerBtn.alpha = 0.5;
            
            NSString *selectedPlayerStr = [pickerView getSelectedRowValueInComponent:0];
            Player *curPlayer = [appDelegate.dataManager getPlayerByName:selectedPlayerStr];
            
            [curPlayer changeStackSize:(curPlayer.playerStackSize.integerValue+potSize)];
            
            //Change Session stats
            Player *heroPlayer  = [appDelegate.dataManager getPlayerByName:settings.settingsHeroName];
            NSInteger curHeroMoney = [heroPlayer.playerStackSize integerValue];
            float BB = [settings.settingsMaxLimit floatValue];
            [curSession changeSessionNumOfHands:1];
   
            [curSession changeSessionBBwon:(float)(curHeroMoney-startHeroMoney)/BB replace:YES];
            
            if ([curPlayer.playerName isEqualToString:heroPlayer.playerName])
            {
                
                NSLog(@"hero win %@, %f", [NSNumber numberWithInteger:potSize], (float)(curHeroMoney-startHeroMoney)/BB);
                [curSession.sessionStats changeBiggestPotWon:potSize/BB];
                [curSession.sessionStats changeStatsHandsWon:1];
                
                NSInteger curHeroBet = [heroPlayer.playerBetSize integerValue];
                if (curHand != NULL && curHeroBet > 0)
                {
                    [curHand changeSessionBBwon:(float)curHeroBet/BB replace:YES];
                }
            } else {
                NSLog(@"hero lost %@, %f", [NSNumber numberWithInteger:potSize], (float)(curHeroMoney-startHeroMoney)/BB);
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
            
            NSInteger selectedIndex = -10;
            for(NSInteger i=0; i< [settings.settingsNumberOfPlayers integerValue];i++)
            {
                
                NSString *playerDictPos = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:i]];
                Player *curPlayer = [players objectForKey:playerDictPos];
                [curPlayer changeBetSize:0];
                [curPlayer changePlayerHands:1];
                
                if ([curPlayer.playerName isEqualToString:selectedPlayerStr])
                {
                    selectedIndex = i;
                }
            }
            
            //if player was BB and all other player folded -- +1 to player walks
            if (selectedIndex == currentBU + 2 || selectedIndex == (currentBU + 2 - [settings.settingsNumberOfPlayers integerValue]))
            {
                BOOL allFolded = YES;
                
                for(NSInteger i=0; i< [settings.settingsNumberOfPlayers integerValue];i++)
                {
                    if (i == selectedIndex)
                        continue;
                    
                    NSString *playerDictPos = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:i]];
                    Player *curPlayer = [players objectForKey:playerDictPos];
                    
                    if (![curPlayer.playerFoldedCards boolValue])
                    {
                        allFolded = NO;
                        break;
                    }
                }
                
                if (allFolded)
                {
                    NSString *playerDictPos = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:selectedIndex]];
                    Player *curPlayer = [players objectForKey:playerDictPos];
                    [curPlayer changePlayerWalks:1];
                    NSLog(@"%@ walks+1", curPlayer.playerName);
                }
            }
            
            potSize = 0;
            self.potSizeField.text = @"0";
            
            recalcStats = YES;

            
            self.dealBtn.userInteractionEnabled = YES;
            self.dealBtn.alpha = 1;
        }
            break;
            
        case PICKER_BU:
        {
            NSInteger selectedIndex = [pickerView getSelectedRowIndexInComponent:0];
            currentBU = selectedIndex;
            [self makeSBAndBBBets];
        }
            break;
            
        case PICKER_CHECK:
        {
            NSString *selectedPlayerStr = [pickerView getSelectedRowValueInComponent:0];
            
            NSInteger selectedIndex = -10;
            for(NSInteger i=0; i< [settings.settingsNumberOfPlayers integerValue];i++)
            {
                NSString *playerDictPos = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:i]];
                Player *curPlayer = [players objectForKey:playerDictPos];
                
                if ([curPlayer.playerName isEqualToString:selectedPlayerStr])
                {
                    selectedIndex = i;
                    break;
                }
            }
            
            NSIndexPath *myIP = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
            UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
            
            UITextField *betField = (UITextField *)[cell.contentView viewWithTag:selectedIndex*10+PLAYER_CARD_BET_SIZE];
            NSString *currentMaxBetStr = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:currentMaxBet]];
            betField.text = currentMaxBetStr;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
            [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
            NSString *selectedIndexStr = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:selectedIndex]];
            [self performSelector:@selector(showKeyboardForTextField:) withObject:selectedIndexStr afterDelay:0.3];
            
            return;
        }
            break;
            
        case PICKER_BET_RAISE:
        {
            NSString *selectedPlayerStr = [pickerView getSelectedRowValueInComponent:0];
            
            NSInteger selectedIndex = -10;
            for(NSInteger i=0; i< [settings.settingsNumberOfPlayers integerValue];i++)
            {
                NSString *playerDictPos = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:i]];
                Player *curPlayer = [players objectForKey:playerDictPos];
                
                if ([curPlayer.playerName isEqualToString:selectedPlayerStr])
                {
                    selectedIndex = i;
                    break;
                }
            }
            
            NSIndexPath *myIP = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
            UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
            
            UITextField *betField = (UITextField *)[cell.contentView viewWithTag:selectedIndex*10+PLAYER_CARD_BET_SIZE];
            NSString *currentMaxBetStr = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:currentMaxBet*2 + 1]];
            betField.text = currentMaxBetStr;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
            [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
            NSString *selectedIndexStr = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:selectedIndex]];
            [self performSelector:@selector(showKeyboardForTextField:) withObject:selectedIndexStr afterDelay:0.3];
            
            return;
        }
            break;
            
        default:
            break;
    }

    
    [self.myTableView reloadData];
}

- (void)showKeyboardForTextField:(NSString*)textFieldTagStr
{
    NSInteger textFieldTag = [textFieldTagStr integerValue];
    
    NSIndexPath *myIP = [NSIndexPath indexPathForRow:textFieldTag inSection:0];
    UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
    
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:textFieldTag*10+PLAYER_CARD_BET_SIZE];

    [textField becomeFirstResponder];
}

- (void)keyboardWasShown:(NSNotification *)nsNotification
{
 /*   //align cover image view vertically
    CGRect frame = self.view.frame;
    //default Y value
    
    //get keyboard size
    NSDictionary *userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSInteger keyboardY = self.view.bounds.size.height - kbSize.height;
    
    //get seleced text field Y
    UITextField *textField = (UITextField*)[coverImageView viewWithTag:selectedText];
    NSInteger textFieldY = coverImageView.frame.origin.y + textField.frame.origin.y + textField.frame.size.height;
    
    //if keyboard will be under text field, raise cover image view
    if (keyboardY < textFieldY)
    {
        CGRect frame = coverImageView.frame;
        NSInteger yOffset = textFieldY - keyboardY;
        frame.origin.y = frame.origin.y - yOffset;
        coverImageView.frame = frame;
    }
    // Portrait:    Height: 235  Width: 320.000000
  */
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //keyboard will be hidden
    
    [UIView animateWithDuration:0.3 animations:^
     {
         CGRect frame = self.view.frame;
         frame.origin.y = 0;
         self.view.frame = frame;
         
     }
                     completion:^(BOOL finished)
     {
         
     }];
}

#pragma mark - Calculate Pot Size
-(void)recalculatePotSize
{
    NSInteger potSizeInt = 0;
    
    for(NSInteger i=0; i< [settings.settingsNumberOfPlayers integerValue];i++)
    {
        NSString *playerDictPos = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:i]];
        Player *curPlayer = [players objectForKey:playerDictPos];
        potSizeInt += [curPlayer.playerBetSize integerValue];
    }
    
    //NSLog(@"recalculatePotSize %d, potSizeInt - %d", potSize, potSizeInt);
    potSize = potSize + potSizeInt;
    //NSLog(@"recalculatePotSize 2 %d, potSizeInt - %d", potSize, potSizeInt);
    
    NSString *potSizeStr = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:potSize]];
    self.potSizeField.text = potSizeStr;
}

- (void)showPickerWithTitleAndTag:(NSString*)title tag:(NSInteger)tag
{
    NSMutableArray *allKeys = [NSMutableArray new];
    for(NSInteger i=0; i< [settings.settingsNumberOfPlayers integerValue];i++)
    {
        NSString *playerDictPos = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:i]];
        Player *curPlayer = [players objectForKey:playerDictPos];
        
        if (![curPlayer.playerFoldedCards boolValue])
            [allKeys addObject:curPlayer.playerName];
    }
    
	NSArray *components = [[NSArray alloc] initWithObjects:allKeys, nil];
    
    pickerVC.tag = tag;
	[pickerVC setData:components];
	[pickerVC selectRowWithIndex:0 inComponent:0 animated:NO];
	
	pickerVC.delegate = self;
	[pickerVC showWithTitle:title lockBackground:YES animated:YES];
}

- (IBAction)betRaiseBtnClicked:(id)sender
{
    [self showPickerWithTitleAndTag:@"Select player for bet/raise" tag:PICKER_BET_RAISE];
}

- (IBAction)checkBtnClicked:(id)sender
{
    [self showPickerWithTitleAndTag:@"Select player for check" tag:PICKER_CHECK];
}

#pragma mark - Players Stats
- (void)calcPlayerStats
{
    calcPlayerStats = YES;
    
    for(NSInteger i=0; i< [settings.settingsNumberOfPlayers integerValue];i++)
    {
        NSString *playerDictPos = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:i]];
        Player *curPlayer = [players objectForKey:playerDictPos];
        
        //change player VPIP
        if (self.card1.hidden == YES)//so is preflop
        {
            if (curPlayer != NULL)
            {
                if (i == currentBU + 1 || i == (currentBU + 1 - [settings.settingsNumberOfPlayers integerValue]))
                {
                    if ([curPlayer.playerBetSize integerValue] > [settings.settingsMinLimit integerValue])
                    {
                        [curPlayer changePlayerVPIP:1];
                        NSLog(@"%@ vpip+1", curPlayer.playerName);
                    }
                }
                else if (i == currentBU + 2 || i == (currentBU + 2 - [settings.settingsNumberOfPlayers integerValue]))
                {
                    if ([curPlayer.playerBetSize integerValue] > [settings.settingsMaxLimit integerValue])
                    {
                        [curPlayer changePlayerVPIP:1];
                        NSLog(@"%@ vpip+1", curPlayer.playerName);
                    }
                }
                else
                {
                    [curPlayer changePlayerVPIP:1];
                    NSLog(@"%@ vpip+1", curPlayer.playerName);
                }
            }
        }
        
        //change player PFR
        if (self.card1.hidden == YES)//so is preflop
        {
            if ([curPlayer.playerBetSize integerValue] > currentMaxBet)
            {
                [curPlayer changePlayerPFR:1];
                NSLog(@"%@ pfr+1", curPlayer.playerName);
            }
        }
        else
        {
            if (([curPlayer.playerBetSize integerValue] == [settings.settingsMaxLimit integerValue]) && (currentMaxBet == [settings.settingsMaxLimit integerValue]))
            {
                [curPlayer changePlayerBets:1];
                NSLog(@"%@ bets+1", curPlayer.playerName);
            }
            else if ([curPlayer.playerBetSize integerValue] > currentMaxBet)
            {
                [curPlayer changePlayerRaises:1];
                NSLog(@"%@ raises+1", curPlayer.playerName);
            }
            else if ([curPlayer.playerBetSize integerValue] == currentMaxBet)
            {
                [curPlayer changePlayerCalls:1];
                NSLog(@"%@ calls+1", curPlayer.playerName);
            }
        }
    }
}

@end
