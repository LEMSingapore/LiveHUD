//
//  Player.h
//  Poker Live
//
//  Created by Denis Senichkin on 2/14/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Player : NSManagedObject

@property (nonatomic, retain) NSString *playerName;
@property (nonatomic, retain) NSString *playerCard1;
@property (nonatomic, retain) NSString *playerCard2;

@property (nonatomic, retain) NSNumber *playerStackSize;
@property (nonatomic, retain) NSNumber *playerBetSize;
@property (nonatomic, retain) NSNumber *playerTotalBetSize;
@property (nonatomic, retain) NSNumber *playerFoldedCards;

@property (nonatomic, retain) NSString *playerNotes;

@property (nonatomic, retain) NSString *playerStatsString;

@property (nonatomic, retain) NSString *playerAllActions;
@property (nonatomic, retain) NSNumber *playerFolds;
@property (nonatomic, retain) NSNumber *playerBets;
@property (nonatomic, retain) NSNumber *playerRaises;
@property (nonatomic, retain) NSNumber *playerCalls;
@property (nonatomic, retain) NSNumber *playerWalks;
@property (nonatomic, retain) NSNumber *playerHands;
@property (nonatomic, retain) NSNumber *playerVPIP;
@property (nonatomic, retain) NSNumber *playerPFR;
@property (nonatomic, retain) NSNumber *playerAGG;
@property (nonatomic, retain) NSNumber *playerChecks;

@property (nonatomic, retain) NSNumber *playerCBets;
@property (nonatomic, retain) NSNumber *playerCBetsOpp;
@property (nonatomic, retain) NSNumber *player3Bets;
@property (nonatomic, retain) NSNumber *player3BetsOpp;
@property (nonatomic, retain) NSNumber *playerDonks;
@property (nonatomic, retain) NSNumber *playerDonksOpp;

@property (nonatomic, retain) NSNumber *playerStatus;


@property (nonatomic, retain) NSDate *lastActionTime;

- (void)changePlayerStatus:(NSInteger)newValue;

- (void)savePlayerNotes:(NSString*)notesText;

- (void)changeStackSize:(float)newValue;
- (void)clearStackSize;

- (void)changeBetSize:(float)newValue;
- (void)clearBetSize;

- (void)addToTotalBetSize:(float)newValue;
- (void)clearTotalBetSize;

- (void)changePlayerFoldedCardsValue:(BOOL)newValue;

- (void)changePlayerHands:(NSInteger)newValue;
- (void)changePlayerVPIP:(NSInteger)newValue;
- (void)changePlayerPFR:(NSInteger)newValue;
- (void)changePlayerAGG:(NSInteger)newValue;
- (void)changePlayerWalks:(NSInteger)newValue;
- (void)changePlayerFolds:(NSInteger)newValue;
- (void)changePlayerBets:(NSInteger)newValue;
- (void)changePlayerRaises:(NSInteger)newValue;
- (void)changePlayerCalls:(NSInteger)newValue;
- (void)changePlayerChecks:(NSInteger)newValue;
- (void)changePlayer3Bets:(NSInteger)newValue;
- (void)changePlayer3BetsOpp:(NSInteger)newValue;
- (void)changePlayerCBets:(NSInteger)newValue;
- (void)changePlayerCBetsOpp:(NSInteger)newValue;
- (void)changePlayerDonks:(NSInteger)newValue;
- (void)changePlayerDonksOpp:(NSInteger)newValue;

- (NSString*)getPlayerStatistic;
- (NSString*)getExtendedPlayerStatistic;

- (NSInteger)numberOfExistedCardsForSuit:(NSString*)suit;
- (BOOL)isCardExistInPlayerCards:(NSString*)cardString;

- (BOOL)isPlayerIsOpenSeat;

- (void)addToPlayerAllAction:(NSString*)action;
- (void)clearPlayerAllAction;
- (void)makeAllPlayerActions;

@end
