//
//  RageIAPHelper.m
//  Live Poker Stats
//
//  Created by Denis Senichkin on 4/19/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "RageIAPHelper.h"

@implementation RageIAPHelper

+ (RageIAPHelper *)sharedInstance
{
    static dispatch_once_t once;
    static RageIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSMutableArray *nameOfProducts = [NSMutableArray new];
        NSDictionary *products = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Products" ofType:@"plist"]];
        for (NSString *key in products)
        {
            NSDictionary *tmpProduct = [products objectForKey:key];
            
            if ([tmpProduct objectForKey:@"appleId"] != NULL)
            {
                [nameOfProducts addObject:[tmpProduct objectForKey:@"appleId"]];
            }
        }

        NSSet * productIdentifiers = [NSSet setWithArray:nameOfProducts];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    
    return sharedInstance;
}

@end