//
//  AppDelegate.h
//  Poker Live
//
//  Created by Denis Senichkin on 2/13/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomePageViewController.h"
#import "DataManager.h"
#import "RageIAPHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL showModalVC;
    BOOL openedByPush;
    
    BOOL coldStart;
    BOOL startupForeground;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) UINavigationController *navigationController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain, nonatomic) DataManager *dataManager;

@property (strong, nonatomic) HomePageViewController *viewController;

- (void)setupUrbanAirship:(NSDictionary *)launchOptions application:(UIApplication*)application;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+ (AppDelegate *)sharedAppDelegate;

- (void)changeShowModalVCFlag:(BOOL)value;

- (NSDictionary*)getCommercialPlist:(NSString*)keyName;
- (BOOL)getIfCommercialPlistInDocuments:(NSString*)keyName;
- (void)showCommercial;
- (void)endOfSessionConfirmation;

@end
