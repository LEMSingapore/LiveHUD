//
//  Hand.m
//  Live Poker Stats
//
//  Created by Denis Senichkin on 2/28/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "Hand.h"
#import "Session.h"


@implementation Hand

@dynamic handName;
@dynamic handBBwon;
@dynamic session;
@dynamic handNumber;

- (void)changeSessionBBwon:(float)newValue replace:(BOOL)replace
{
    if (&newValue == NULL)
    {
        newValue = 0;
    }
    
    if (!replace)
        self.handBBwon = [NSNumber numberWithFloat:([self.handBBwon floatValue] + newValue)];
    else
        self.handBBwon = [NSNumber numberWithFloat:(newValue)];
    
    [[AppDelegate sharedAppDelegate].dataManager saveCoreData];
}

@end
