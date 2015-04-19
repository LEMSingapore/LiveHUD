//
//  Session.h
//  Live Poker Stats
//
//  Created by Denis Senichkin on 2/28/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SessionStats;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSDate * sessionDate;
@property (nonatomic, retain) NSString * sessionLocation;
@property (nonatomic, retain) NSNumber * sessionNumOfHands;
@property (nonatomic, retain) NSNumber * sessionBBwon;
@property (nonatomic, retain) NSSet *hands;
@property (nonatomic, retain) SessionStats *sessionStats;
@end

@interface Session (CoreDataGeneratedAccessors)

- (void)addHandsObject:(NSManagedObject *)value;
- (void)removeHandsObject:(NSManagedObject *)value;
- (void)addHands:(NSSet *)values;
- (void)removeHands:(NSSet *)values;

- (void)changeSessionNumOfHands:(NSInteger)newValue;
- (void)changeSessionBBwon:(float)newValue replace:(BOOL)replace;

@end
