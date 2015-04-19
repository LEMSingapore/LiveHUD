//
//  SettingsViewController.m
//  Poker Live
//
//  Created by Denis Senichkin on 2/13/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "SettingsViewController.h"
#import "BoardLandscapeViewController.h"
#import "PickerVC.h"

#define NUMBER_OF 0
#define STRUCTURE_OF 1

#define PLAYER_NAME 1
#define PLAYER_STACK 2

@interface SettingsViewController ()

@end

@implementation SettingsViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        pickerVC = [[PickerVC alloc] initWithNibName:@"PickerVC" bundle:nil];
        addLocVC = [[AddLocationViewController alloc] init];
        addLocVC.delegate = self;
        
        appDelegate = [AppDelegate sharedAppDelegate];
        settings = [appDelegate.dataManager getSettingsEntry];
        players = [NSMutableArray new];
        
        playersNames = [NSMutableArray new];
        playersStacks = [NSMutableArray new];
        
        CELL_DEFAULT_HEIGHT = 30;
        
        if (IS_IPHONE_5)
        {
            CELL_DEFAULT_HEIGHT = 33;
        }
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

- (void)viewDidUnload
{
    [self setBackBtn:nil];
    [self setDoneBtn:nil];
    [self setNumberBtn:nil];
    [self setStructureBtn:nil];
    [self setNumberText:nil];
    [self setBetText:nil];
    [self setMyTableView:nil];
    [self setLocationPlaceField:nil];
    [self setLocationPlaceBtn:nil];
    [self setContentView:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:pickerVC.view];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;

    addLocVC.view.frame = CGRectMake(0, 0, addLocVC.view.frame.size.width, screenHeight);
    [self.view addSubview:addLocVC.view];
    //[addLocVC hide:NO];
    
    
    self.locationPlaceField.text = settings.settingsLocationName;
    
    //NSInteger offsetY = 50;
    
    self.numberText.text = [settings getNumberOfPlayersString];
    
    self.betText.text = [settings getMinMaxLimitString];
    // Do any additional setup after loading the view from its nib.
    
    
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
        
        if (playerName == NULL || playerName.length ==0)
        {
            playerName = EMPTY_PLAYER_NAME;
        }
        
        Player *curPlayer  = [appDelegate.dataManager getPlayerByName:playerName];
        if (curPlayer != NULL)
        {
            [players addObject:curPlayer];
            
            [playersNames addObject:curPlayer.playerName];
            [playersStacks addObject:curPlayer.playerStackSize];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShowned:)  name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)  name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLocationName)  name:@"changeLocationName" object:nil];
}

- (IBAction)backBtnClicked:(id)sender
{
    BOOL modalPresent = (BOOL)(self.presentedViewController);
    
    if (modalPresent)
    {
        [[AppDelegate sharedAppDelegate].navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [[AppDelegate sharedAppDelegate].navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)doneBtnClicked:(id)sender
{
    for(NSInteger i=0; i < [settings.settingsNumberOfPlayers integerValue]; i++)
    {
        NSIndexPath *myIP = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
        
        UITextField *nameField = (UITextField *)[cell.contentView viewWithTag:i*10+PLAYER_NAME];
        UITextField *stackField = (UITextField *)[cell.contentView viewWithTag:i*10+PLAYER_STACK];
        
        
        
        NSString *playerName;
        if (nameField.text.length > 0)
        {
            playerName = nameField.text;
        }
        else
        {
            playerName = EMPTY_PLAYER_NAME;
        }
        
        Player *curPlayer;
        switch (i)
        {
            case 0:
            {
                settings.settingsHeroName = playerName;
                settings.settingsPlayer0 = playerName;
            }
                break;
            case 1:
            {
                settings.settingsPlayer1 = playerName;
            }
                break;
            case 2:
            {
                settings.settingsPlayer2 = playerName;
            }
                break;
            case 3:
            {
                settings.settingsPlayer3 = playerName;
            }
                break;
            case 4:
            {
                settings.settingsPlayer4 = playerName;
            }
                break;
            case 5:
            {
                settings.settingsPlayer5 = playerName;
            }
                break;
            case 6:
            {
                settings.settingsPlayer6 = playerName;
            }
                break;
            case 7:
            {
                settings.settingsPlayer7 = playerName;
            }
                break;
            case 8:
            {
                settings.settingsPlayer8 = playerName;
            }
                break;
            case 9:
            {
                settings.settingsPlayer9 = playerName;
            }
                break;

            default:
                break;
        }
        
        if (nameField.text.length > 0 && stackField.text.length > 0 && [stackField.text integerValue]>=0)
        {
            curPlayer  = [appDelegate.dataManager getPlayerByName:nameField.text];
            if (curPlayer!=NULL)
            {
                [curPlayer clearStackSize];
                [curPlayer changeStackSize:[stackField.text integerValue]];
            }
        }
    
    }
    
    /*if ([settings.settingsNumberOfPlayers integerValue] < 6)
    {
        [settings changeNumberOfPlayers:6];
    }
    else if ([settings.settingsNumberOfPlayers integerValue] < 9)
    {
        [settings changeNumberOfPlayers:9];
    }*/
    
    [settings changeSettingsIsChanged:YES];
    
    BOOL modalPresent = (BOOL)(self.presentedViewController);
    
    if (modalPresent)
    {
        [[AppDelegate sharedAppDelegate].navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        //[[AppDelegate sharedAppDelegate].navigationController popToRootViewControllerAnimated:NO];
    }
    
    BoardLandscapeViewController *vc = [[BoardLandscapeViewController alloc] init];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [[AppDelegate sharedAppDelegate] changeShowModalVCFlag:YES];
    [[AppDelegate sharedAppDelegate].navigationController presentViewController:vc animated:YES completion:nil];
}

- (IBAction)numberOfPlayersBtnClicked:(id)sender
{
    [self.view endEditing:YES];
    
    NSArray *allKeys = [[NSArray alloc] initWithObjects:@"2", @"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil];
	NSArray *components = [[NSArray alloc] initWithObjects:allKeys, nil];
    
	[pickerVC setData:components];
    
    [pickerVC selectRowWithValue:self.numberText.text inComponent:0 animated:NO];
 	
	pickerVC.tag = NUMBER_OF;
	pickerVC.delegate = self;
	[pickerVC showWithTitle:@"Number of players" lockBackground:YES animated:YES];
}

- (IBAction)structureBtnClicked:(id)sender
{
    [self.view endEditing:YES];
    
    NSArray *allKeys = [[NSArray alloc] initWithObjects:@"1 / 2", @"2 / 4", @"5 / 10", @"10 / 20", @"25 / 50", @"50 / 100", @"100 / 200", @"500 / 1000", nil];
	NSArray *components = [[NSArray alloc] initWithObjects:allKeys, nil];
    
	
	[pickerVC setData:components];
	//[pickerVC selectRowWithIndex:0 inComponent:0 animated:NO];
    [pickerVC selectRowWithValue:self.betText.text inComponent:0 animated:NO];
	
	pickerVC.tag = STRUCTURE_OF;
	pickerVC.delegate = self;
	[pickerVC showWithTitle:@"Blinds structure" lockBackground:YES animated:YES];
}

#pragma mark - PickerVC Delegate Methods
- (void)pickerViewControllerDoneButtonClicked:(PickerVC *)pickerView
{
    NSString *selectedValue = [pickerView getSelectedRowValueInComponent:0];
    //NSInteger selectedIndex = [pickerView getSelectedRowIndexInComponent:0];
    
	switch (pickerView.tag)
    {
        case NUMBER_OF:
        {
            self.numberText.text = selectedValue;
            [settings changeNumberOfPlayers:[selectedValue integerValue]];
            
            [playersNames removeAllObjects];
            [playersStacks removeAllObjects];
            
            for (int i=0; i < [settings.settingsNumberOfPlayers integerValue]; i++)
            {
                NSIndexPath *myIP = [NSIndexPath indexPathForRow:i inSection:0];
                UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
                
                UITextField *stackField = (UITextField *)[cell.contentView viewWithTag:i*10+PLAYER_STACK];
                NSInteger stackSize = [settings.settingsMaxLimit integerValue] * 100;
                
                NSString *valueName = [NSString stringWithFormat:@"settingsPlayer%d", i];
                NSString *playerName;
                if (i == 0)
                    playerName = settings.settingsHeroName;
                else
                    playerName = [settings valueForKey:valueName];
                
                Player *curPlayer = [[AppDelegate sharedAppDelegate].dataManager getPlayerByName:playerName];
                
                if (curPlayer != NULL)
                {
                    [playersNames addObject:curPlayer.playerName];
                    
                    if (stackSize < [curPlayer.playerStackSize integerValue])
                    {
                        stackSize = [curPlayer.playerStackSize integerValue];
                    }
                    
                    [playersStacks addObject:curPlayer.playerStackSize];
                }
                
                
                stackField.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger: stackSize]];
            }
            
            [self.myTableView reloadData];
        }
            break;
            
        case STRUCTURE_OF:
        {
            self.betText.text = selectedValue;
            NSArray *arrString = [selectedValue componentsSeparatedByString:@" / "];
            if ([arrString count] == 2)
            {
                [settings changeMinLimit:[arrString[0] integerValue]];
                
                [settings changeMaxLimit:[arrString[1] integerValue]];
            }
            
            [playersStacks removeAllObjects];
            
            for (int i=0; i < [settings.settingsNumberOfPlayers integerValue]; i++)
            {
                NSIndexPath *myIP = [NSIndexPath indexPathForRow:i inSection:0];
                UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
                
                UITextField *stackField = (UITextField *)[cell.contentView viewWithTag:i*10+PLAYER_STACK];
                NSInteger stackSize = [settings.settingsMaxLimit integerValue] * 100;
                
                NSString *valueName = [NSString stringWithFormat:@"settingsPlayer%d", i];
                NSString *playerName;
                if (i == 0)
                    playerName = settings.settingsHeroName;
                else
                    playerName = [settings valueForKey:valueName];
                
                Player *curPlayer = [[AppDelegate sharedAppDelegate].dataManager getPlayerByName:playerName];
                
                if (curPlayer != NULL)
                {
                    if (stackSize < [curPlayer.playerStackSize integerValue])
                    {
                        stackSize = [curPlayer.playerStackSize integerValue];
                    }
                    
                    [playersStacks addObject:curPlayer.playerStackSize];
                }
                
                stackField.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger: stackSize]];
            }
            
            [self.myTableView reloadData];
            
        }
            break;
	}
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [settings.settingsNumberOfPlayers integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        if (view.tag > 0)
        {
            [view removeFromSuperview];
        }
    }
    
    if (indexPath.row < [settings getNumberOfPlayers])
    {
        UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, 130, 22)];nameField.delegate = self;
        [nameField setReturnKeyType:UIReturnKeyDone];
        nameField.placeholder = @"Enter plr name";nameField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:14];nameField.autocorrectionType = UITextAutocorrectionTypeYes;
        nameField.tag = indexPath.row*10+PLAYER_NAME;nameField.borderStyle = UITextBorderStyleRoundedRect;
        nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        [cell.contentView addSubview:nameField];
        
        UITextField *stackField = [[UITextField alloc] initWithFrame:CGRectMake(175, 5, 130, 22)];stackField.delegate = self;
        [stackField setReturnKeyType:UIReturnKeyDone];
        stackField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        stackField.placeholder = @"Enter stack size";stackField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:14];
        stackField.tag = indexPath.row*10+PLAYER_STACK;stackField.borderStyle = UITextBorderStyleRoundedRect;stackField.autocorrectionType = UITextAutocorrectionTypeNo;
        [cell.contentView addSubview:stackField];
        
        if (indexPath.row == 0)
        {
            nameField.text = @"HERO";
        }
        
        if (indexPath.row < [playersNames count])
        {
            NSString *playerName = [playersNames objectAtIndex:indexPath.row];
            
            if (![playerName isEqualToString:EMPTY_PLAYER_NAME])
            {
                nameField.text = playerName;
            }
            else
            {
                nameField.text = NULL;
            }
        }
        else
        {
            nameField.text = NULL;
        }
        
        if (indexPath.row < [playersStacks count])
        {
            NSNumber *playerStack = [playersStacks objectAtIndex:indexPath.row];
            
            if ([playerStack integerValue] > [settings.settingsMaxLimit integerValue] * 100)
            {
                stackField.text = [playerStack stringValue];
            }
            else
            {
                stackField.text = [NSString stringWithFormat:@"%@", @([settings.settingsMaxLimit integerValue] * 100)];
            }
        }
        else
        {
            stackField.text = [NSString stringWithFormat:@"%@", @([settings.settingsMaxLimit integerValue] * 100)];
        }
        
        /*if (indexPath.row < [playersNames count])
        {
            Player *curPlayer = [players objectAtIndex:indexPath.row];
            
            
            if (curPlayer != NULL && ![curPlayer isPlayerIsOpenSeat])
            {
                nameField.text = curPlayer.playerName;
                
                if ([curPlayer.playerStackSize integerValue] > [settings.settingsMaxLimit integerValue] * 100)
                {
                    stackField.text = [curPlayer.playerStackSize stringValue];
                }
                else
                {
                    stackField.text = [NSString stringWithFormat:@"%d", [settings.settingsMaxLimit integerValue] * 100];
                }
            }
            else
            {
                nameField.text = NULL;
                //stackField.text = NULL;
                stackField.text = [NSString stringWithFormat:@"%d", [settings.settingsMaxLimit integerValue] * 100];
            }
        }*/
    }
    
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

- (void)changeLocationName
{
    self.locationPlaceField.text = settings.settingsLocationName;
}

#pragma mark - Keyboard delegates

- (void)keyboardWillBeShowned:(NSNotification*)aNotification
{
    double animationDuration;
    animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    NSDictionary *userInfo = [aNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    /*if (addLocVC.view.hidden == NO)
    {
        [UIView animateWithDuration:animationDuration animations:^
         {
             NSLog(@"addLocVC.frame = %@", NSStringFromCGRect(addLocVC.view.frame));
             addLocVC.view.frame = CGRectMake(0, 0, addLocVC.view.frame.size.width, self.contentView.frame.size.height - kbSize.height);
             NSLog(@"addLocVC.frame = %@", NSStringFromCGRect(addLocVC.view.frame));
             
         }
         completion:^(BOOL finished)
         {
             
         }];

        return;
    }*/
    
    NSInteger keyboardYHeight = self.myTableView.frame.origin.y;
    
    CGRect frame = self.view.frame;
    frame.origin.y = self.view.bounds.origin.y;
    self.view.frame = frame;
    
    [UIView animateWithDuration:animationDuration animations:^
     {
         //get keyboard size
         NSLog(@"self.view.bounds = %@", NSStringFromCGRect(self.view.bounds));
         NSLog(@"self.view.frame = %@", NSStringFromCGRect(self.view.frame));
         
         CGRect frame = self.contentView.frame;
         frame.origin.y = - keyboardYHeight;
         frame.size.height = frame.size.height - (kbSize.height - keyboardYHeight);
         self.contentView.frame = frame;
         
         NSLog(@"self.view.frame = %@", NSStringFromCGRect(self.view.frame));
         
     }
     completion:^(BOOL finished)
     {
         
     }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    double animationDuration;
    animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    /*if (addLocVC.view.hidden == NO)
    {
        [UIView animateWithDuration:animationDuration animations:^
         {
             addLocVC.view.frame = CGRectMake(0, 0, addLocVC.view.frame.size.width, self.contentView.frame.size.height);
         }
         completion:^(BOOL finished)
         {
             
         }];
        
        return;
    }*/
    
    //keyboard will be hidden
    if (self.contentView.frame.origin.y == self.contentView.bounds.origin.y)
    {
        NSLog(@"self.view.frame.origin.y = %f", self.view.frame.origin.y);
        NSLog(@"self.view.frame.bounds.y = %f", self.view.bounds.origin.y);

        
        return;
    }
    
    [UIView animateWithDuration:animationDuration animations:^
     {
         CGRect frame = self.view.frame;
         frame.origin.y = self.contentView.bounds.origin.y;
         frame.size.height = appDelegate.window.frame.size.height;
         self.contentView.frame = frame;
     }
     completion:^(BOOL finished)
     {
         
     }];
}

#pragma mark - addPlayersVC delegates
- (void)newPlayerWasSelected:(NSString*)playerName
{
    NSInteger playerPos =  addLocVC.view.tag;
    
    NSInteger textFieldTag = playerPos;
    NSLog(@"before playersNames %@", playersNames);
    
    NSUInteger index = [playersNames indexOfObject:playerName];
    if (index != NSNotFound) {
        [playersNames replaceObjectAtIndex:index withObject:EMPTY_PLAYER_NAME];
    }
    
    [playersNames replaceObjectAtIndex:textFieldTag withObject:playerName];
    NSLog(@"after playersNames %@", playersNames);
    
    [self.myTableView reloadData];
}


#pragma mark - UITextField delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag % 10 == PLAYER_NAME)
    {
        if (textField.tag/10 == 0)
        {
            return YES;
        }
            
        [addLocVC setPickerType:PLAYERS_PICKER showHeroName:NO];
        addLocVC.view.tag = textField.tag/10;
        [addLocVC showWithTitle:@"" lockBackground:YES animated:YES];
        
        return NO;
    }
    
    return YES;
    
    CGRect absRect = [textField.superview convertRect:textField.frame toView:NULL];
    NSInteger textFieldY = absRect.origin.y;
    
    NSInteger keyboardYHeight = 215;
    NSInteger keyboardY = self.view.bounds.size.height - keyboardYHeight;
    
    if (([settings.settingsNumberOfPlayers integerValue] - textField.tag/10) > 1)
    {
        NSInteger cellH = CELL_DEFAULT_HEIGHT;
        textFieldY = textFieldY + cellH*([settings.settingsNumberOfPlayers integerValue] - textField.tag/10 - 1);
    }
    
    //NSLog(@"textFieldY = %d, absRect = %@, YOffset - %.f", textFieldY, NSStringFromCGRect(absRect), textFieldY - keyboardY + textField.frame.size.height);
    if (keyboardY < textFieldY)
    {
        CGRect frame = self.contentView.frame;
        frame.origin.y = 0;
        self.contentView.frame = frame;
    }
    
    if (keyboardY < textFieldY)
    {
        [UIView animateWithDuration:0.3 animations:^
         {
             CGRect frame = self.contentView.frame;
             NSInteger yOffset = textFieldY - keyboardY - 13;
             frame.origin.y = -yOffset;
             self.contentView.frame = frame;
             
         }
         completion:^(BOOL finished)
         {
             
         }];
    }
    else
    {
        /*[UIView animateWithDuration:0.3 animations:^
         {
             CGRect frame = self.view.frame;
             frame.origin.y = 20;
             self.view.frame = frame;
             
         }
                         completion:^(BOOL finished)
         {
             
         }];*/
    }
    
    
    return YES;
}


- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag % 10 == PLAYER_NAME)
    {
        NSInteger textFieldTag = textField.tag/10;
        NSLog(@"before playersNames %@", playersNames);
        [playersNames replaceObjectAtIndex:textFieldTag withObject:textField.text];
        NSLog(@"after playersNames %@", playersNames);
    }
    
    if (textField.tag % 10 == PLAYER_STACK)
    {
        NSInteger textFieldTag = textField.tag/10;
        NSLog(@"before playersStacks %@", playersStacks);
        NSNumber *newStack = @([textField.text integerValue]);
        [playersStacks replaceObjectAtIndex:textFieldTag withObject:newStack];
        NSLog(@"after playersStacks %@", playersStacks);
    }
    
    /*NSLog(@"textFieldDidEndEditing %@", [textField text]);
    
    if (textField.tag % 10 == PLAYER_NAME)
    {
        NSInteger textFieldTag = textField.tag/10;
        
        Player *curPlayer  = [appDelegate.dataManager getPlayerByName:textField.text];
        if (curPlayer != NULL)
        {
            NSIndexPath *myIP = [NSIndexPath indexPathForRow:textFieldTag inSection:0];
            UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
            UITextField *stackField = (UITextField *)[cell.contentView viewWithTag:textField.tag+1];
            //stackField.text = [curPlayer.playerStackSize stringValue];
            
            stackField.text = [NSString stringWithFormat:@"%d", [settings.settingsMaxLimit integerValue] * 100];
        }
    }*/
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /*if (textField.tag % 10 == PLAYER_NAME)
    {
        NSInteger textFieldTag = textField.tag/10;
        
        Player *curPlayer  = [appDelegate.dataManager getPlayerByName:textField.text];
        if (curPlayer != NULL)
        {
            NSIndexPath *myIP = [NSIndexPath indexPathForRow:textFieldTag inSection:0];
            UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:myIP];
            UITextField *stackField = (UITextField *)[cell.contentView viewWithTag:textField.tag+1];
            //stackField.text = [curPlayer.playerStackSize stringValue];
            
            stackField.text = [NSString stringWithFormat:@"%d", [settings.settingsMaxLimit integerValue] * 100];
        }
    }*/
    
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)locationPlaceBtnClicked:(id)sender
{
    [self.view endEditing:YES];
    
    //addLocVC.view.frame = CGRectMake(0, 0, addLocVC.view.frame.size.width, self.contentView.frame.size.height);
    //addLocVC.view.hidden = NO;
    
    /*[addLocVC hide:NO];
    
    [UIView animateWithDuration:0.35 animations:^
     {
         addLocVC.view.frame = CGRectMake(0, 0, addLocVC.view.frame.size.width, self.contentView.frame.size.height);
         
     }
     completion:^(BOOL finished)
     {
         
     }];*/
    
    [addLocVC setPickerType:LOCATIONS_PICKER showHeroName:NO];
    [addLocVC showWithTitle:@"" lockBackground:YES animated:NO];
    //[addLocVC showKeyboardCustom];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
