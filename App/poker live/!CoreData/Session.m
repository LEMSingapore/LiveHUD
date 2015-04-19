//
//  Session.m
//  Live Poker Stats
//
//  Created by Denis Senichkin on 2/28/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "Session.h"


@implementation Session

@dynamic sessionDate;
@dynamic sessionLocation;
@dynamic sessionNumOfHands;
@dynamic sessionBBwon;
@dynamic hands;
@dynamic sessionStats;

- (void)changeSessionNumOfHands:(NSInteger)newValue
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    self.sessionNumOfHands = [NSNumber numberWithInteger:([self.sessionNumOfHands integerValue] + newValue)];
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

- (void)changeSessionBBwon:(float)newValue replace:(BOOL)replace
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    if (!replace)
        self.sessionBBwon = [NSNumber numberWithFloat:([self.sessionBBwon floatValue] + newValue)];
    else
        self.sessionBBwon = [NSNumber numberWithFloat:(newValue)]; 
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

@end
