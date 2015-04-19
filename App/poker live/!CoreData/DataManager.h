//
//  DataManager.h
//  Poker Live
//
//  Created by Denis Senichkin on 2/14/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Settings.h"
#import "Player.h"
#import "Location.h"
#import "Session.h"
#import "SessionStats.h"
#import "Hand.h"

@interface DataManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)saveCoreData;

- (Settings*)addSettingsEntry;
- (Settings*)getSettingsEntry;

- (NSArray*)getPlayersByName:(NSString*)name showHero:(BOOL)showHero;
- (Player*)addPlayerEntry:(NSString*)name;
- (NSArray*)getAllPlayersNamesSortedByLastActionTime;
- (NSArray*)getAllPlayersNamesSortedByName:(BOOL)showHero;
- (BOOL)ifPlayerExist:(NSString*)tagName;
- (Player*)getPlayerByName:(NSString*)name;

- (NSArray*)getAllLocations;
- (BOOL)ifLocationExist:(NSString*)tagName;
- (Location*)addLocationEntry:(NSString*)name;
- (NSArray*)getLocationsByName:(NSString*)name;
- (Location*)getLocationByName:(NSString*)name;

- (Session*)addSessionEntryWithLocationAndDate:(NSString*)location date:(NSDate*)date;
- (NSArray*)getAllSessions;

- (SessionStats*)addSessionStatsEntryForSession:(Session*)ownerSession;

#pragma mark - Hands routine
-(BOOL)checkForHandsLimit:(BOOL)showAlert;
- (NSUInteger)getAllHandsCount;
- (Hand*)addHandEntryWithNameAndNumber:(NSString*)name value:(NSInteger)value;
- (Hand*)addNewHandForSession:(Session*)entry;

@end
