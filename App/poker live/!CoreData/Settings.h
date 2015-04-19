//
//  Settings.h
//  Poker Live
//
//  Created by Denis Senichkin on 2/14/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject

@property (nonatomic, retain) NSNumber * settingsNumberOfPlayers;
@property (nonatomic, retain) NSNumber * settingsMinLimit;
@property (nonatomic, retain) NSNumber * settingsMaxLimit;
@property (nonatomic, retain) NSNumber * settingsIsChanged;
@property (nonatomic, retain) NSString * settingsHeroName;

@property (nonatomic, retain) NSString *settingsLocationName;

@property (nonatomic, retain) NSString *settingsCard1;
@property (nonatomic, retain) NSString *settingsCard2;
@property (nonatomic, retain) NSString *settingsCard3;
@property (nonatomic, retain) NSString *settingsCard4;
@property (nonatomic, retain) NSString *settingsCard5;

@property (nonatomic, retain) NSString *settingsPlayer0;
@property (nonatomic, retain) NSString *settingsPlayer1;
@property (nonatomic, retain) NSString *settingsPlayer2;
@property (nonatomic, retain) NSString *settingsPlayer3;
@property (nonatomic, retain) NSString *settingsPlayer4;
@property (nonatomic, retain) NSString *settingsPlayer5;
@property (nonatomic, retain) NSString *settingsPlayer6;
@property (nonatomic, retain) NSString *settingsPlayer7;
@property (nonatomic, retain) NSString *settingsPlayer8;
@property (nonatomic, retain) NSString *settingsPlayer9;

- (NSInteger)getNumberOfPlayersForCurrentCount;

- (void)changeSettingsIsChanged:(BOOL)newValue;
- (BOOL)getSettingsIsChanged;

- (void)changeSettingsHeroName:(NSString*)newValue;

- (void)changeNumberOfPlayers:(NSInteger)newValue;
- (void)changeMinLimit:(NSInteger)newValue;
- (void)changeMaxLimit:(NSInteger)newValue;

- (NSInteger)getNumberOfPlayers;
- (NSInteger)getMinLimit;
- (NSInteger)getMaxLimit;

- (NSString*)getNumberOfPlayersString;
- (NSString*)getMinLimitString;
- (NSString*)getMaxLimitString;
- (NSString*)getMinMaxLimitString;

- (NSInteger)numberOfExistedCardsForSuit:(NSString*)suit;
- (BOOL)isCardExistInSettingsCards:(NSString*)cardString;

- (NSString*)getAllBoardCards;
- (NSString*)getAllBoardCardsFromPlayersArray:(NSArray*)players;

@end
