//
//  DataManager.m
//  Poker Live
//
//  Created by Denis Senichkin on 2/14/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

- (void)saveCoreData
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            //NSLog(@"!!!!Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

#pragma mark - Settings routine
- (Settings*)addSettingsEntry
{
    Settings *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
    
    NSNumber *numOfPlayers = [NSNumber numberWithInteger:3];
    NSNumber *minLimit = [NSNumber numberWithInteger:1];
    NSNumber *maxLimit = [NSNumber numberWithInteger:2];
    NSNumber *isChanged = [NSNumber numberWithBool:FALSE];
 
    [newEntry setSettingsNumberOfPlayers:numOfPlayers];
    [newEntry setSettingsMinLimit:minLimit];
    [newEntry setSettingsMaxLimit:maxLimit];
    [newEntry setSettingsIsChanged:isChanged];
    [newEntry setSettingsHeroName:@"Hero"];
    
    [newEntry setSettingsCard1:NULL];
    [newEntry setSettingsCard2:NULL];
    [newEntry setSettingsCard3:NULL];
    [newEntry setSettingsCard4:NULL];
    [newEntry setSettingsCard5:NULL];
    
    [newEntry setSettingsLocationName:@""];
    
    [self saveCoreData];
    
    return newEntry;
}

- (Settings*)getSettingsEntry
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setFetchLimit:1];
	
	NSError *error;
    NSArray *FetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!FetchResults)
    {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
        return NULL;
	}
    
    if ([FetchResults count] == 0)
    {
        Settings *newRecord = [self addSettingsEntry];
        return newRecord;
    }
    
    Settings *tmpRecord = [FetchResults objectAtIndex:0];
    return tmpRecord;
}

#pragma mark - Player routine
- (Player*)addPlayerEntry:(NSString*)name
{
    Player *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:self.managedObjectContext];
    
    NSNumber *zero = [NSNumber numberWithInteger:0];
    
    NSInteger stackSizeTmp = 0;
    
    Settings *settings = [self getSettingsEntry];
    if (settings != NULL && [settings.settingsMaxLimit integerValue] > 0)
    {
        stackSizeTmp = [settings.settingsMaxLimit integerValue] * 100;
    }
    
    NSNumber *stackSize = [NSNumber numberWithInteger:stackSizeTmp];
    NSNumber *betSize = [NSNumber numberWithInteger:0];
    NSNumber *foldCards = [NSNumber numberWithBool:NO];
 
    [newEntry setPlayerName:name];
    [newEntry setPlayerVPIP:zero];
    [newEntry setPlayerPFR:zero];
    [newEntry setPlayerAGG:zero];
    [newEntry setPlayerStackSize:stackSize];
    [newEntry setPlayerBetSize:betSize];
    [newEntry setPlayerFoldedCards:foldCards];
    [newEntry setPlayerHands:zero];
    [newEntry setPlayerWalks:zero];
    [newEntry setPlayerStatsString:@"N/A-N/A-N/A"];
    
    [newEntry setPlayerBets:zero];
    [newEntry setPlayerCalls:zero];
    [newEntry setPlayerRaises:zero];
    [newEntry setPlayerChecks:zero];
    [newEntry setPlayerFolds:zero];
    [newEntry setPlayerNotes:@""];
    [newEntry setPlayerAllActions:@""];
    
    [newEntry setPlayerStatus:zero];
    
    [newEntry setPlayer3Bets:zero];
    [newEntry setPlayer3BetsOpp:zero];
    [newEntry setPlayerCBets:zero];
    [newEntry setPlayerCBetsOpp:zero];
    [newEntry setPlayerDonks:zero];
    [newEntry setPlayerDonksOpp:zero];
    
    [self saveCoreData];
    
    return newEntry;
}

- (BOOL)ifPlayerExist:(NSString*)tagName
{
	// Define our table/entity to use
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerName LIKE[cd] %@", tagName];
    
	// Setup the fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
	
	// Fetch the records and handle an error
	NSError *error;
	//NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    NSArray *FetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!FetchResults) {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
	}
	
    if ([FetchResults count] > 0)
        return YES;
    
    
    return NO;
}

- (Player*)getPlayerByName:(NSString*)name
{
    if (name == NULL || name.length == 0)
    {
        name = EMPTY_PLAYER_NAME;
    }
    
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerName LIKE[c] %@", name];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
	
	NSError *error;
    NSArray *FetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!FetchResults)
    {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
        return NULL;
	}
    
    if ([FetchResults count] == 0)
    {
        Player *newValue = [self addPlayerEntry:name];
        return newValue;
    }
    
    Player *newValue = [FetchResults objectAtIndex:0];
    
    return newValue;
}

- (NSArray*)getAllPlayersNamesSortedByName:(BOOL)showHero
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:self.managedObjectContext];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    Settings *settings = [self getSettingsEntry];
    
    NSString *emptyName = [NSString stringWithFormat:@"%@", EMPTY_PLAYER_NAME];
    NSString *splitName = [NSString stringWithFormat:@"%@", SPLIT_MSG_STRING];
    
    if (showHero)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT playerName CONTAINS[cd] %@ AND NOT playerName CONTAINS[cd] %@", emptyName, splitName];
        [request setPredicate:predicate];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT playerName CONTAINS[cd] %@ AND NOT playerName CONTAINS[cd] %@ AND NOT playerName CONTAINS[cd] %@", emptyName, settings.settingsHeroName, splitName];
        [request setPredicate:predicate];
    }

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"playerName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
	NSError *error;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!fetchResults)
    {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
        return NULL;
	}
    
    NSMutableArray *newArray = [NSMutableArray new];
    
    Player *empty = [self getPlayerByName:EMPTY_PLAYER_NAME];
    [newArray addObject:empty];
    [newArray addObjectsFromArray:fetchResults];
    
    /*NSMutableArray *names = [NSMutableArray new];
    
    for(Player *tmp in fetchResults)
    {
        if (![tmp isPlayerIsOpenSeat])
        {
            [names addObject:tmp.playerName];
        }
    }*/
    
    return newArray;
}

- (NSArray*)getPlayersByName:(NSString*)name showHero:(BOOL)showHero
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *emptyName = [NSString stringWithFormat:@"%@", EMPTY_PLAYER_NAME];
    NSString *splitName = [NSString stringWithFormat:@"%@", SPLIT_MSG_STRING];
    
    if (!showHero)
    {
        Settings *settings = [self getSettingsEntry];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"playerName CONTAINS[cd] %@ AND NOT playerName CONTAINS[cd] %@ AND NOT playerName CONTAINS[cd] %@ AND NOT playerName CONTAINS[cd] %@",
                                  name, emptyName, settings.settingsHeroName, splitName];
        [request setPredicate:predicate];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerName CONTAINS[cd] %@ AND NOT playerName CONTAINS[cd] %@ AND NOT playerName CONTAINS[cd] %@", name, emptyName, splitName];
        [request setPredicate:predicate];
    }
    
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];

    //[request setFetchLimit:1];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"playerName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
	
	NSError *error;
    NSArray *FetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!FetchResults)
    {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
        return NULL;
	}
    
    return FetchResults;
}

- (NSArray*)getAllPlayersNamesSortedByLastActionTime
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:self.managedObjectContext];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSString *splitName = [NSString stringWithFormat:@"%@", SPLIT_MSG_STRING];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT playerName CONTAINS[cd] %@", splitName];
    [request setPredicate:predicate];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastActionTime" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
	NSError *error;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!fetchResults)
    {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
        return NULL;
	}
    
    NSMutableArray *names = [NSMutableArray new];
    
    for(Player *tmp in fetchResults)
    {
        if (![tmp isPlayerIsOpenSeat])
        {
            [names addObject:tmp.playerName];
        }
    }
        
    return names;
}


#pragma mark - Location routine
- (BOOL)ifLocationExist:(NSString*)tagName
{
	// Define our table/entity to use
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationName LIKE[cd] %@", tagName];
    
	// Setup the fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
	
	// Fetch the records and handle an error
	NSError *error;
	//NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    NSArray *FetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!FetchResults) {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
	}
	
    if ([FetchResults count] > 0)
        return YES;
    
    
    return NO;
}

- (Location*)addLocationEntry:(NSString*)name
{
    Location *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    
    [newEntry setLocationName:name];
    
    [self saveCoreData];
    
    return newEntry;
}

- (NSArray*)getLocationsByName:(NSString*)name
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationName CONTAINS[cd] %@", name];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setPredicate:predicate];
    //[request setFetchLimit:1];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"locationName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
	
	NSError *error;
    NSArray *FetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!FetchResults)
    {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
        return NULL;
	}
    
    return FetchResults;
}

- (NSArray*)getAllLocations
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"locationName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
	
	NSError *error;
    NSArray *FetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!FetchResults)
    {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
        return NULL;
	}
    
    return FetchResults;
}

- (Location*)getLocationByName:(NSString*)name
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationName LIKE[c] %@", name];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
	
	NSError *error;
    NSArray *FetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!FetchResults)
    {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
        return NULL;
	}
    
    if ([FetchResults count] == 0)
    {
        Location *newValue = [self addLocationEntry:name];
        return newValue;
    }
    
    Location *newValue = [FetchResults objectAtIndex:0];
    
    return newValue;
}

#pragma mark - Sessions routine
- (NSArray*)getAllSessions
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Session" inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sessionDate" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setSortDescriptors:sortDescriptors];
    
    //In-App purchases limit there
    //[request setFetchLimit:5];
	
	NSError *error;
    NSArray *FetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!FetchResults)
    {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
        return NULL;
	}
    
    return FetchResults;
}

- (Session*)addSessionEntryWithLocationAndDate:(NSString*)location date:(NSDate*)date
{
    if (![self checkForHandsLimit:NO])
    {
        return NULL;
    }
    
    Session *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:self.managedObjectContext];
    
    [self addSessionStatsEntryForSession:newEntry];
    
    NSNumber *zero = [NSNumber numberWithInteger:0];
    
    [newEntry setSessionDate:date];
    [newEntry setSessionLocation:location];
    [newEntry setSessionBBwon:zero];
    [newEntry setSessionNumOfHands:zero];
    
    [self saveCoreData];
    
    return newEntry;
}

#pragma mark - Session Stats routine
- (SessionStats*)addSessionStatsEntryForSession:(Session*)ownerSession
{
    SessionStats *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"SessionStats" inManagedObjectContext:self.managedObjectContext];
    
    ownerSession.sessionStats = newEntry;
    
    NSNumber *zero = [NSNumber numberWithInteger:0];
    
    [newEntry setStatsBB100Hands:zero];
    [newEntry setStatsBiggestPotLost:zero];
    [newEntry setStatsBiggestPotLost:zero];
    [newEntry setStatsBiggestPotWon:zero];
    [newEntry setStatsHandsPlayed:zero];
    [newEntry setStatsHandsWon:zero];
    
    [self saveCoreData];
    
    return newEntry;
}

#pragma mark - Hands routine
-(BOOL)checkForHandsLimit:(BOOL)showAlert
{
    NSUInteger allHandsCount = [self getAllHandsCount];
    NSLog(@"allHandsCount = %d", allHandsCount);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *handsLimit = [NSNumber numberWithInteger:BRONZE_EDITION_HANDS];
    if ([defaults objectForKey:HANDS_LIMIT_NAME] != NULL)
    {
        handsLimit = [defaults objectForKey:HANDS_LIMIT_NAME];
        NSLog(@"checkForHandsLimit handsLimit = %d", [handsLimit unsignedIntegerValue]);
        
        if ([handsLimit integerValue] == PLATINUM_EDITION_HANDS)
        {
            return YES;
        }
    }
    
    if ([defaults objectForKey:HANDS_UNLIMITED_NAME] != NULL)
    {
        BOOL unlim = [defaults boolForKey:HANDS_UNLIMITED_NAME];
        NSLog(@"check unlim handsLimit = %d", unlim);
        
        if (unlim)
        {
            return YES;
        }
    }
    
    if (allHandsCount+1 == [handsLimit unsignedIntegerValue])
    {
        if (showAlert)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:@"You have reached the limit of hands history for your version of the app.\n\nTo get more hands, please upgrade from the Main Menu Shop." delegate:NULL cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
        return YES;
    }
    else if (allHandsCount >= [handsLimit unsignedIntegerValue])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (NSUInteger)getAllHandsCount
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hand" inManagedObjectContext:self.managedObjectContext];
    
	// Setup the fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
	// Fetch the records and handle an error
	NSError *error;
    NSUInteger count = 0;
    count = [self.managedObjectContext countForFetchRequest:request error:&error];
    
    //NSLog(@"getAllEventDates FetchResults = %@", FetchResults);
    return count;
}

- (Hand*)addHandEntryWithNameAndNumber:(NSString*)name value:(NSInteger)value
{
    if (![self checkForHandsLimit:YES])
    {
        return NULL;
    }
    
    Hand *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Hand" inManagedObjectContext:self.managedObjectContext];
    
    NSNumber *zero = [NSNumber numberWithInteger:0];
    NSNumber *number = [NSNumber numberWithInteger:value];
    
    [newEntry setHandName:name];
    [newEntry setHandNumber:number];
    [newEntry setHandBBwon:zero];
    
    [self saveCoreData];
    
    return newEntry;
}

- (Hand*)addNewHandForSession:(Session*)entry
{
    NSInteger handsCount = [entry.hands.allObjects count];
    NSString *handNamde = [NSString stringWithFormat:@"HAND %d", handsCount+1];
    
    Hand *newHand = [self addHandEntryWithNameAndNumber:handNamde value:handsCount];
    
    if (newHand == NULL)
    {
        return NULL;
    }
    
    [entry addHandsObject:newHand];
    [self saveCoreData];
    
    return newHand;
}



@end
