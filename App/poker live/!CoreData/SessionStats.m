//
//  SessionStats.m
//  Live Poker Stats
//
//  Created by Denis Senichkin on 2/28/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "SessionStats.h"
#import "Session.h"


@implementation SessionStats

@dynamic statsHandsPlayed;
@dynamic statsHandsWon;
@dynamic statsBB100Hands;
@dynamic statsBiggestPotWon;
@dynamic statsBiggestPotLost;
@dynamic session;


- (void)changeBiggestPotWon:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    if ([self.statsBiggestPotWon integerValue] < newValue)
    {
        self.statsBiggestPotWon = [NSNumber numberWithInteger:newValue];
        [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
    }
}

- (void)changeBiggestPotLost:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    if ([self.statsBiggestPotLost integerValue] < newValue)
    {
        self.statsBiggestPotLost = [NSNumber numberWithInteger:newValue];
        [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
    }
}

- (void)changeStatsHandsWon:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.statsHandsWon = [NSNumber numberWithInteger:([self.statsHandsWon integerValue] + newValue)];
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changeStatsHandsPlayed:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.statsHandsPlayed = [NSNumber numberWithInteger:([self.statsHandsPlayed integerValue] + newValue)];
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

@end
