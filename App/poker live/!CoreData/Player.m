//
//  Player.m
//  Poker Live
//
//  Created by Denis Senichkin on 2/14/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "Player.h"


@implementation Player

@dynamic playerStatus;

@dynamic playerName;
@dynamic playerCard1;
@dynamic playerCard2;
@dynamic playerVPIP;
@dynamic playerPFR;
@dynamic playerAGG;
@dynamic playerStackSize;
@dynamic playerBetSize;
@dynamic playerTotalBetSize;
@dynamic playerFoldedCards;
@dynamic playerHands;
@dynamic playerWalks;
@dynamic playerStatsString;
@dynamic playerBets;
@dynamic playerCalls;
@dynamic playerRaises;
@dynamic playerNotes;
@dynamic lastActionTime;
@dynamic playerFolds;
@dynamic playerChecks;
@dynamic playerAllActions;

@dynamic player3Bets;
@dynamic player3BetsOpp;
@dynamic playerCBets;
@dynamic playerCBetsOpp;
@dynamic playerDonks;
@dynamic playerDonksOpp;

- (void)savePlayerNotes:(NSString*)notesText
{
    self.playerNotes = notesText;
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)clearStackSize
{
    self.playerStackSize = [NSNumber numberWithInteger:0];
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerStatus:(NSInteger)newValue
{
    self.playerStatus = [NSNumber numberWithInteger:newValue];
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changeStackSize:(float)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    if (newValue >= 0)
        self.playerStackSize = [NSNumber numberWithFloat:newValue];
    else
        self.playerStackSize = [NSNumber numberWithFloat:0];
    
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}


- (void)addToTotalBetSize:(float)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerTotalBetSize = [NSNumber numberWithFloat:[self.playerTotalBetSize floatValue]+newValue];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)clearTotalBetSize
{
    self.playerTotalBetSize = [NSNumber numberWithInteger:0];
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changeBetSize:(float)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    /*self.playerStackSize = [NSNumber numberWithFloat:([self.playerStackSize floatValue] + [self.playerBetSize floatValue])];
    self.playerBetSize = [NSNumber numberWithFloat:newValue];
    self.playerStackSize = [NSNumber numberWithFloat:([self.playerStackSize floatValue] - newValue)];*/
    //self.playerStackSize = [NSNumber numberWithFloat:([self.playerStackSize floatValue] + [self.playerBetSize floatValue])];
    
    self.playerBetSize = [NSNumber numberWithFloat:[self.playerBetSize floatValue] + newValue];
    self.playerStackSize = [NSNumber numberWithFloat:([self.playerStackSize floatValue] - newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)clearBetSize
{
    self.playerBetSize = [NSNumber numberWithInteger:0];
    self.lastActionTime = [NSDate date];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerHands:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerHands = [NSNumber numberWithInteger:([self.playerHands integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerVPIP:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerVPIP = [NSNumber numberWithInteger:([self.playerVPIP integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerPFR:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerPFR = [NSNumber numberWithInteger:([self.playerPFR integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerAGG:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerAGG = [NSNumber numberWithInteger:([self.playerAGG integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerWalks:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerWalks = [NSNumber numberWithInteger:([self.playerWalks integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerFoldedCardsValue:(BOOL)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerFoldedCards = [NSNumber numberWithBool:newValue];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerBets:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerBets = [NSNumber numberWithInteger:([self.playerBets integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerRaises:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerRaises = [NSNumber numberWithInteger:([self.playerRaises integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerCalls:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerCalls = [NSNumber numberWithInteger:([self.playerCalls integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerFolds:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerFolds = [NSNumber numberWithInteger:([self.playerFolds integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerChecks:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerChecks = [NSNumber numberWithInteger:([self.playerChecks integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayer3Bets:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.player3Bets = [NSNumber numberWithInteger:([self.player3Bets integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayer3BetsOpp:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.player3BetsOpp = [NSNumber numberWithInteger:([self.player3BetsOpp integerValue] + newValue)];
    
    NSLog(@"%@  player3BetsOpp %@", self.playerName, self.player3BetsOpp);
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerCBets:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerCBets = [NSNumber numberWithInteger:([self.playerCBets integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerCBetsOpp:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerCBetsOpp = [NSNumber numberWithInteger:([self.playerCBetsOpp integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerDonks:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerDonks = [NSNumber numberWithInteger:([self.playerDonks integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changePlayerDonksOpp:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.playerDonksOpp = [NSNumber numberWithInteger:([self.playerDonksOpp integerValue] + newValue)];
    
    //[[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)addToPlayerAllAction:(NSString*)action
{
    if ([self.playerAllActions rangeOfString:action].location == NSNotFound)
    {
        self.playerAllActions = [self.playerAllActions stringByAppendingString:action];
    }
}

- (void)clearPlayerAllAction
{
    self.playerAllActions = @"";
}


- (void)makeAllPlayerActions
{
    NSLog(@"%@ makeAllPlayerActions %@", self.playerName, self.playerAllActions);
    
    if ([self.playerAllActions rangeOfString:VPIP].location != NSNotFound)
    {
        [self changePlayerVPIP:1];
    }
    
    if ([self.playerAllActions rangeOfString:PFR].location != NSNotFound)
    {
        [self changePlayerPFR:1];
    }
    
    if ([self.playerAllActions rangeOfString:AGG].location != NSNotFound)
    {
        [self changePlayerAGG:1];
    }
    
    if ([self.playerAllActions rangeOfString:WALK].location != NSNotFound)
    {
        [self changePlayerWalks:1];
    }
    
    if ([self.playerAllActions rangeOfString:FOLD].location != NSNotFound)
    {
        [self changePlayerFolds:1];
    }
    
    if ([self.playerAllActions rangeOfString:BET].location != NSNotFound)
    {
        [self changePlayerBets:1];
    }
    
    if ([self.playerAllActions rangeOfString:RAISE].location != NSNotFound)
    {
        [self changePlayerRaises:1];
    }
    
    if ([self.playerAllActions rangeOfString:CALL].location != NSNotFound)
    {
        [self changePlayerCalls:1];
    }
    
    if ([self.playerAllActions rangeOfString:CHECK].location != NSNotFound)
    {
        [self changePlayerChecks:1];
    }
    
    if ([self.playerAllActions rangeOfString:BET_3].location != NSNotFound)
    {
        [self changePlayer3Bets:1];
    }
    
    if ([self.playerAllActions rangeOfString:BET_3_OPP].location != NSNotFound)
    {
        [self changePlayer3BetsOpp:1];
    }
    
    if ([self.playerAllActions rangeOfString:C_BET].location != NSNotFound)
    {
        [self changePlayerCBets:1];
    }
    
    if ([self.playerAllActions rangeOfString:C_BET_OPP].location != NSNotFound)
    {
        [self changePlayerCBetsOpp:1];
    }
    
    if ([self.playerAllActions rangeOfString:DONK_BET].location != NSNotFound)
    {
        [self changePlayerDonks:1];
    }
    
    if ([self.playerAllActions rangeOfString:DONK_BET_OPP].location != NSNotFound)
    {
        [self changePlayerDonksOpp:1];
    }
    
    [self clearPlayerAllAction];
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (NSString*)getPlayerStatistic
{
    NSString *vpip = @"N/A";
    NSString *pfr = @"N/A";
    NSString *af = @"N/A";
    
    //Agg% = (Bets + Raises) / (Bets + Raises + Calls + Checks + Folds) * 100% 
    
    if ([self.playerHands integerValue] > 0)
    {
        //NSLog(@"%@: vpip - %d hands - %d walks - %d", self.playerName, [self.playerVPIP integerValue], [self.playerHands integerValue], [self.playerWalks integerValue]);
        vpip = [NSString stringWithFormat:@"%.f", 100*([self.playerVPIP floatValue]/([self.playerHands floatValue] - [self.playerWalks floatValue]))];

        //NSLog(@"playerPFR - %d, playerBets - %d, playerRaises - %d, playerCalls - %d", [self.playerPFR integerValue], [self.playerBets integerValue], [self.playerRaises integerValue], [self.playerCalls integerValue]);
        pfr = [NSString stringWithFormat:@"%.f", 100*([self.playerPFR floatValue]/[self.playerHands floatValue])];
        
        /*if ([self.playerCalls floatValue] > 0)
        {
            af = [NSString stringWithFormat:@"%.f", 100*(([self.playerBets floatValue]+[self.playerRaises floatValue])/[self.playerCalls floatValue])];
        }*/
        if ([self.playerBets floatValue]>0||[self.playerRaises floatValue]>0||[self.playerCalls floatValue]>0||[self.playerChecks floatValue]>0||[self.playerFolds floatValue]>0)
        {
            af = [NSString stringWithFormat:@"%.f", 100*(
                                                         ([self.playerBets floatValue]+[self.playerRaises floatValue])/
                                                         ([self.playerBets floatValue]+[self.playerRaises floatValue]+[self.playerCalls floatValue]+[self.playerChecks floatValue]+[self.playerFolds floatValue])
                                                         )];
        }
        //else if ([self.playerBets floatValue] > 0 || [self.playerRaises floatValue] > 0)
        else if ([self.playerBets floatValue] > 0 || [self.playerRaises floatValue] > 0)
        {
            af = @"∞";
        }
        
        NSString *stats = [NSString stringWithFormat:@"VP:%@ PF:%@ AG:%@", vpip, pfr, af];
        self.playerStatsString = [NSString stringWithFormat:@"VP:%@ PF:%@ AG:%@", vpip, pfr, af];;
        
        return stats;
    }
    else
    {
        NSString *stats = [NSString stringWithFormat:@"VP:0 PF:0 AG:0"];
        self.playerStatsString = [NSString stringWithFormat:@"VP: 0 PF: 0 AG: 0"];;
        
        return stats;
    }
    
    
    return @"";
}

- (NSString*)getExtendedPlayerStatistic
{
    NSString *bet3 = @"N/A";
    NSString *cbet = @"N/A";
    NSString *donk = @"N/A";
    
    if ([self.playerHands integerValue] > 0)
    {
        if ([self.player3BetsOpp floatValue] > 0)
        {
            bet3 = [NSString stringWithFormat:@"%.f", 100*([self.player3Bets floatValue]/[self.player3BetsOpp floatValue])];
        }
        
        if ([self.playerCBetsOpp floatValue] > 0)
        {
            cbet = [NSString stringWithFormat:@"%.f", 100*([self.playerCBets floatValue]/[self.playerCBetsOpp floatValue])];
        }
        
        if ([self.playerDonksOpp floatValue] > 0)
        {
            donk = [NSString stringWithFormat:@"%.f", 100*([self.playerDonks floatValue]/[self.playerDonksOpp floatValue])];
        }
        
        NSString *stats = [NSString stringWithFormat:@"3B:%@ CB:%@ DNK:%@", bet3, cbet, donk];
        return stats;
    }
    else
    {
        NSString *stats = [NSString stringWithFormat:@"3B:0 CB:0 DNK:0"];
        return stats;
    }
    
    
    return @"";
}

- (NSInteger)numberOfExistedCardsForSuit:(NSString*)suit
{
    NSInteger num = 0;
    
    if (self.playerCard1 != NULL)
    {
        if ([self.playerCard1 rangeOfString:suit].location !=NSNotFound)
        {
            num++;
        }
    }
    
    if (self.playerCard2 != NULL)
    {
        if ([self.playerCard2 rangeOfString:suit].location !=NSNotFound)
        {
            num++;
        }
    }
    
    return num;
}

- (BOOL)isCardExistInPlayerCards:(NSString*)cardString
{
    if ([cardString isEqualToString:self.playerCard1])
    {
        return YES;
    }
    else if ([cardString isEqualToString:self.playerCard2])
    {
        return YES;
    }

    
    return NO;
}

- (BOOL)isPlayerIsOpenSeat
{
    if ([self.playerName isEqualToString:EMPTY_PLAYER_NAME])
    {
        return YES;
    }
    
    return NO;
}

@end
