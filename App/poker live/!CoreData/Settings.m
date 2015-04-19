//
//  Settings.m
//  Poker Live
//
//  Created by Denis Senichkin on 2/14/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "Settings.h"

#define MAX_PLAYERS_COUNT 10


@implementation Settings

@dynamic settingsNumberOfPlayers;
@dynamic settingsMinLimit;
@dynamic settingsMaxLimit;
@dynamic settingsIsChanged;
@dynamic settingsHeroName;

@dynamic settingsLocationName;

@dynamic settingsCard1;
@dynamic settingsCard2;
@dynamic settingsCard3;
@dynamic settingsCard4;
@dynamic settingsCard5;

@dynamic settingsPlayer0;
@dynamic settingsPlayer1;
@dynamic settingsPlayer2;
@dynamic settingsPlayer3;
@dynamic settingsPlayer4;
@dynamic settingsPlayer5;
@dynamic settingsPlayer6;
@dynamic settingsPlayer7;
@dynamic settingsPlayer8;
@dynamic settingsPlayer9;

- (NSInteger)getNumberOfPlayersForCurrentCount
{
    if ([self.settingsNumberOfPlayers integerValue] <= 6)
    {
        return 6;
    }
    else if ([self.settingsNumberOfPlayers integerValue] <= 9)
    {
        return 9;
    }
    
    return MAX_PLAYERS_COUNT;
}

- (void)changeSettingsIsChanged:(BOOL)newValue
{
    self.settingsIsChanged = [NSNumber numberWithBool:newValue];
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changeSettingsHeroName:(NSString*)newValue
{
    self.settingsHeroName = newValue;
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}


- (BOOL)getSettingsIsChanged
{
    return [self.settingsIsChanged boolValue];
}

- (NSInteger)getNumberOfPlayers
{
    return [self.settingsNumberOfPlayers integerValue];
}

- (NSInteger)getMinLimit
{
    return [self.settingsMinLimit integerValue];
}

- (NSInteger)getMaxLimit
{
    return [self.settingsMaxLimit integerValue];
}

- (NSString*)getNumberOfPlayersString
{
    NSString *str = [NSString stringWithFormat:@"%d", [self.settingsNumberOfPlayers integerValue]];
    return str;
}

- (NSString*)getMinLimitString
{
    NSString *str = [NSString stringWithFormat:@"%d", [self.settingsMinLimit integerValue]];
    return str;
}

- (NSString*)getMaxLimitString
{
    NSString *str = [NSString stringWithFormat:@"%d", [self.settingsMaxLimit integerValue]];
    return str;
}

- (NSString*)getMinMaxLimitString
{
    NSString *betStr = [NSString stringWithFormat:@"%@ / %@", [self getMinLimitString], [self getMaxLimitString]];

    return betStr;
}

- (void)changeNumberOfPlayers:(NSInteger)newValue
{
    if (newValue > 0)
    {
        self.settingsNumberOfPlayers = [NSNumber numberWithInteger:newValue];
    }
    
    [self changeSettingsIsChanged:YES];
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changeMinLimit:(NSInteger)newValue
{
    if (newValue > 0)
    {
        self.settingsMinLimit = [NSNumber numberWithInteger:newValue];
    }
    
    [self changeSettingsIsChanged:YES];
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changeMaxLimit:(NSInteger)newValue
{
    if (newValue > 0)
    {
        self.settingsMaxLimit = [NSNumber numberWithInteger:newValue];
    }
    
    [self changeSettingsIsChanged:YES];
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (NSInteger)numberOfExistedCardsForSuit:(NSString*)suit
{
    NSInteger num = 0;
    
    if (self.settingsCard1 != NULL)
    {
        if ([self.settingsCard1 rangeOfString:suit].location !=NSNotFound)
        {
            num++;
        }
    }
    
    if (self.settingsCard2 != NULL)
    {
        if ([self.settingsCard2 rangeOfString:suit].location !=NSNotFound)
        {
            num++;
        }
    }
    
    if (self.settingsCard3 != NULL)
    {
        if ([self.settingsCard3 rangeOfString:suit].location !=NSNotFound)
        {
            num++;
        }
    }
    
    if (self.settingsCard4 != NULL)
    {
        if ([self.settingsCard4 rangeOfString:suit].location !=NSNotFound)
        {
            num++;
        }
    }
    
    if (self.settingsCard5 != NULL)
    {
        if ([self.settingsCard5 rangeOfString:suit].location !=NSNotFound)
        {
            num++;
        }
    }
    
    for(int i=1; i < [self.settingsNumberOfPlayers integerValue]; i++)
    {
        NSString *playerName;
        switch (i)
        {
            case 1:
            {
                playerName = self.settingsPlayer1;
            }
                break;
            case 2:
            {
                playerName = self.settingsPlayer2;
            }
                break;
            case 3:
            {
                playerName = self.settingsPlayer3;
            }
                break;
            case 4:
            {
                playerName = self.settingsPlayer4;
            }
                break;
            case 5:
            {
                playerName = self.settingsPlayer5;
            }
                break;
            case 6:
            {
                playerName = self.settingsPlayer6;
            }
                break;
            case 7:
            {
                playerName = self.settingsPlayer7;
            }
                break;
            case 8:
            {
                playerName = self.settingsPlayer8;
            }
                break;
            case 9:
            {
                playerName = self.settingsPlayer9;
            }
                break;
                
            default:
                break;
        }
        
        if (playerName != NULL)
        {
            Player *curPlayer  = [[AppDelegate sharedAppDelegate].dataManager getPlayerByName:playerName];
            
            if (curPlayer.playerCard1 != NULL)
            {
                if ([curPlayer.playerCard1 rangeOfString:suit].location !=NSNotFound)
                {
                    num++;
                }
            }
            
            if (curPlayer.playerCard2 != NULL)
            {
                if ([curPlayer.playerCard2 rangeOfString:suit].location !=NSNotFound)
                {
                    num++;
                }
            }
        }
    }
    
    
    return num;
}

- (BOOL)isCardExistInSettingsCards:(NSString*)cardString
{
    if ([cardString isEqualToString:self.settingsCard1])
    {
        return YES;
    }
    else if ([cardString isEqualToString:self.settingsCard2])
    {
        return YES;
    }
    else if ([cardString isEqualToString:self.settingsCard3])
    {
        return YES;
    }
    else if ([cardString isEqualToString:self.settingsCard4])
    {
        return YES;
    }
    else if ([cardString isEqualToString:self.settingsCard5])
    {
        return YES;
    }
    
    for(int i=1; i < [self.settingsNumberOfPlayers integerValue]; i++)
    {
        NSString *playerName;
        switch (i)
        {
            case 1:
            {
                playerName = self.settingsPlayer1;
            }
                break;
            case 2:
            {
                playerName = self.settingsPlayer2;
            }
                break;
            case 3:
            {
                playerName = self.settingsPlayer3;
            }
                break;
            case 4:
            {
                playerName = self.settingsPlayer4;
            }
                break;
            case 5:
            {
                playerName = self.settingsPlayer5;
            }
                break;
            case 6:
            {
                playerName = self.settingsPlayer6;
            }
                break;
            case 7:
            {
                playerName = self.settingsPlayer7;
            }
                break;
            case 8:
            {
                playerName = self.settingsPlayer8;
            }
                break;
            case 9:
            {
                playerName = self.settingsPlayer9;
            }
                break;
                
            default:
                break;
        }
        
        if (playerName != NULL)
        {
            Player *curPlayer  = [[AppDelegate sharedAppDelegate].dataManager getPlayerByName:playerName];
            //NSLog(@"playerName = %@, card1 = %@, card2 = %@", curPlayer.playerName, curPlayer.playerCard1, curPlayer.playerCard1);
            
            if ([curPlayer isPlayerIsOpenSeat])
            {
                continue;
            }
            
            if ([cardString isEqualToString:curPlayer.playerCard1] || [cardString isEqualToString:curPlayer.playerCard2])
            {
                return YES;
            }
        }
    }

    
    return NO;
}

- (NSString*)getAllBoardCards
{
    NSString *allCards = @"";
    
    for(int i = 1; i < 6; i++)
    {
        NSString *valueName = [NSString stringWithFormat:@"settingsCard%d", i];
        
        NSString *card = [self valueForKey:valueName];
        if (card != NULL)
        {
            allCards = [allCards stringByAppendingString:card];
        }
    }
    
    for(int i = 0; i < [self.settingsNumberOfPlayers integerValue]; i++)
    {
        NSString *valueName = [NSString stringWithFormat:@"settingsPlayer%d", i];
        //BOOL hasFoo = [[self.entity propertiesByName] objectForKey:valueName] != nil;
        //NSLog(@"hasFoo for %@ %d", valueName, hasFoo);
        
        NSString *playerName;
        if (i == 0)
        {
            playerName = self.settingsHeroName;
        }
        else
        {
            playerName = [self valueForKey:valueName];
        }


        Player *curPlayer = [[AppDelegate sharedAppDelegate].dataManager getPlayerByName:playerName];
        
        if (curPlayer != NULL)
        {
            if (curPlayer.playerCard1 != NULL && curPlayer.playerCard2 != NULL)
            {
                allCards = [allCards stringByAppendingString:curPlayer.playerCard1];
                allCards = [allCards stringByAppendingString:curPlayer.playerCard2];
            }
        }
    }
    
    NSLog(@"getAllBoardCards allCards = %@", allCards);
    
    return allCards;
    
}

- (NSString*)getAllBoardCardsFromPlayersArray:(NSArray*)players
{
    NSString *allCards = @"";
    
    for(int i = 1; i < 6; i++)
    {
        NSString *valueName = [NSString stringWithFormat:@"settingsCard%d", i];
        
        NSString *card = [self valueForKey:valueName];
        if (card != NULL)
        {
            allCards = [allCards stringByAppendingString:card];
        }
    }
    
    for(int i = 0; i < [players count]; i++)
    {
        Player *curPlayer = [players objectAtIndex:i];
        
        if (curPlayer != NULL && ![curPlayer isPlayerIsOpenSeat])
        {
            if (curPlayer.playerCard1 != NULL && curPlayer.playerCard2 != NULL)
            {
                allCards = [allCards stringByAppendingString:curPlayer.playerCard1];
                allCards = [allCards stringByAppendingString:curPlayer.playerCard2];
            }
        }
    }
    
    NSLog(@"getAllBoardCardsFromPlayersArray allCards = %@", allCards);
    
    return allCards;
}


/*
 - (NSString *)valueOfItem:(NSManagedObject *)item asStringForKey:(NSString *)key {
 
 NSEntityDescription *entity = [item entity];
 NSDictionary *attributesByName = [entity attributesByName];
 NSAttributeDescription *attribute = attributesByName[key];
 
 if (!attribute) {
 return @"---No Such Attribute Key---";
 }
 else if ([attribute attributeType] == NSUndefinedAttributeType) {
 return @"---Undefined Attribute Type---";
 }
 else if ([attribute attributeType] == NSStringAttributeType) {
 // return NSStrings as they are
 return [item valueForKey:key];
 }
 else if ([attribute attributeType] < NSDateAttributeType) {
 // this will be all of the NSNumber types
 // return them as strings
 return [[item valueForKey:key] stringValue];
 }
 // add more "else if" cases as desired for other types
 
 else {
 return @"---Unacceptable Attribute Type---";
 }
 }
 */


@end
