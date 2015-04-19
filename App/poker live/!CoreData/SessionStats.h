//
//  SessionStats.h
//  Live Poker Stats
//
//  Created by Denis Senichkin on 2/28/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface SessionStats : NSManagedObject

@property (nonatomic, retain) NSNumber * statsHandsPlayed;
@property (nonatomic, retain) NSNumber * statsHandsWon;
@property (nonatomic, retain) NSNumber * statsBB100Hands;
@property (nonatomic, retain) NSNumber * statsBiggestPotWon;
@property (nonatomic, retain) NSNumber * statsBiggestPotLost;
@property (nonatomic, retain) Session *session;

- (void)changeBiggestPotWon:(NSInteger)newValue;
- (void)changeBiggestPotLost:(NSInteger)newValue;
- (void)changeStatsHandsWon:(NSInteger)newValue;
- (void)changeStatsHandsPlayed:(NSInteger)newValue;

@end
