//
//  Hand.h
//  Live Poker Stats
//
//  Created by Denis Senichkin on 2/28/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface Hand : NSManagedObject

@property (nonatomic, retain) NSString * handName;
@property (nonatomic, retain) NSNumber * handBBwon;
@property (nonatomic, retain) NSNumber * handNumber;
@property (nonatomic, retain) Session *session;

- (void)changeSessionBBwon:(float)newValue replace:(BOOL)replace;

@end
