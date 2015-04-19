//
//  AppDelegate.m
//  Poker Live
//
//  Created by Denis Senichkin on 2/13/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "AppDelegate.h"

//UA
//#import "UAirship.h"
//#import "UAPush.h"
//#import "UALocationCommonValues.h"
//#import "UAAnalytics.h"

#define EMPTY_KEY_NAME @"EMPTY_KEY_NAME"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"[NSUserDefaults standardUserDefaults] = %@", [NSUserDefaults standardUserDefaults]);
    
    //set up hands limits
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:HANDS_LIMIT_NAME] != NULL)
    {
        NSNumber *handsLimit = [defaults objectForKey:HANDS_LIMIT_NAME];
        NSLog(@"didFinishLaunchingWithOptions handsLimit = %d", [handsLimit unsignedIntegerValue]);
    }
    else
    {
        NSNumber *handsLimit = [NSNumber numberWithInteger:BRONZE_EDITION_HANDS];
        [defaults setObject:handsLimit forKey:HANDS_LIMIT_NAME];
        NSLog(@"didFinishLaunchingWithOptions create handsLimit = %d", [handsLimit unsignedIntegerValue]);
        [defaults synchronize];
    }
    
    
    showModalVC = NO;
    
    [RageIAPHelper sharedInstance];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSLog(@"self.window = %@", self.window);
    // Override point for customization after application launch.
    
    self.viewController = [[HomePageViewController alloc] initWithNibName:@"HomePageViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    
    [self.window setRootViewController:self.navigationController];
    //self.window.rootViewController = self.navigationController;
    self.window.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES];
    
    //self.window.rootViewController.shouldAutorotate = NO;
    
    self.dataManager = [DataManager alloc];
	self.dataManager.managedObjectContext = [self managedObjectContext];
    
    openedByPush = NO;
    coldStart = YES;
    startupForeground = YES;
    if (launchOptions)
    {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo)
        {
            openedByPush = YES;
        }
    }
    
    //Urban Air
    [self setupUrbanAirship:launchOptions application:application];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UIImageView *imageView;
    if (IS_IPHONE_5)
    {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashScreen-568h@2x.png"]];
    }
    else
    {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashScreen@2x.png"]];
    }
    
    imageView.frame = self.window.frame;
    imageView.contentMode = UIViewContentModeScaleToFill;
    
    
    [self.window addSubview:imageView];
    imageView.alpha = 1;
    
    [UIView animateWithDuration:1.3 animations:^
     {
         imageView.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         [imageView removeFromSuperview];
         //show Commercial
         //[self showCommercial];
     }];
    
    return YES;
}


#pragma mark - Urban air
- (void)setupUrbanAirship:(NSDictionary *)launchOptions application:(UIApplication*)application
{
    //Create Airship options dictionary and add the required UIApplication launchOptions
    NSMutableDictionary *takeOffOptions = [NSMutableDictionary dictionary];
//    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Call takeOff (which creates the UAirship singleton), passing in the launch options so the
    // library can properly record when the app is launched from a push notification. This call is
    // required.
    //
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
//    [UAirship takeOff:takeOffOptions];
    
    // Set the icon badge to zero on startup (optional)
//    [[UAPush shared] resetBadge];
    
    // Register for remote notfications with the UA Library. This call is required.
//    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
//                                                         UIRemoteNotificationTypeSound |
//                                                         UIRemoteNotificationTypeAlert)];
    
    // Handle any incoming incoming push notifications.
    // This will invoke `handleBackgroundNotification` on your UAPushNotificationDelegate.
//    [[UAPush shared] handleNotification:[launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey] applicationState:application.applicationState];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Updates the device token and registers the token with UA.
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken deviceToken = %@", deviceToken);
    
    const unsigned *tokenData = [deviceToken bytes];
	NSString *deviceTokenString = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x", ntohl(tokenData[0]), ntohl(tokenData[1]), ntohl(tokenData[2]), ntohl(tokenData[3]), ntohl(tokenData[4]), ntohl(tokenData[5]), ntohl(tokenData[6]), ntohl(tokenData[7])];
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken deviceTokenString =%@", deviceTokenString);
//    [[UAPush shared] registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification userInfo = %@", userInfo);
    openedByPush = YES;
    
    if (application.applicationState == UIApplicationStateActive)
    {
        if ([userInfo objectForKey:@"aps"] != NULL)
        {
            NSDictionary *aps = [userInfo objectForKey:@"aps"];
            if ([aps objectForKey:@"alert"] != NULL)
            {
                NSString *text = [aps objectForKey:@"alert"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:text delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

#pragma mark - shared Delegate
+ (AppDelegate *)sharedAppDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)changeShowModalVCFlag:(BOOL)value
{
    showModalVC = value;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (showModalVC)
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
    openedByPush = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    startupForeground = YES;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive %@", application);
    [DejalBezelActivityView removeViewAnimated:YES];
    
    //show commercial;
    if (openedByPush == NO && startupForeground == YES)
    {
        startupForeground = NO;
        
        float delay = 0.5;
        if (coldStart == YES)
        {
            delay = 1.5;
            coldStart = NO;
        }
        
        self.window.userInteractionEnabled = NO;
        [self performSelector:@selector(showCommercial) withObject:NULL afterDelay:delay];
        //[self performSelector:@selector(downloadCommercial) withObject:NULL afterDelay:delay*2];
        [self performSelectorInBackground:@selector(downloadCommercial) withObject:NULL];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
//    [UAirship land];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
		[_managedObjectContext setUndoManager:nil];
        ////2011-12-15
        //[_managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
        [_managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        ////2011-12-15
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    /*NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
     if (coordinator != nil) {
     _managedObjectContext = [[NSManagedObjectContext alloc] init];
     [_managedObjectContext setPersistentStoreCoordinator:coordinator];
     }*/
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Poker_Live" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.

/*
 NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
 
 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
 
 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
 
 NSError *error;
 _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
 
 if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
 // Handle error
 NSLog(@"Problem with PersistentStoreCoordinator: %@",error);
 }
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Poker_Live013.sqlite"];
    
    ////2013-04-23
    /*NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    ////2013-04-23*/
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:NULL error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSDictionary*)getCommercialPlist:(NSString*)keyName
{
    NSDictionary *storedItems;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *themesDirectory = [documentsDirectory stringByAppendingString:@"/commercial/"];
    
    NSString *bundleListPath = [[NSBundle mainBundle] pathForResource:@"commercial" ofType:@"plist"];
    NSString *donwloadedListPath = [themesDirectory stringByAppendingPathComponent:@"commercial.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:donwloadedListPath])
    {
        storedItems = [[NSMutableDictionary alloc] initWithContentsOfFile:bundleListPath];
        
        NSDictionary *tmp = [[NSMutableDictionary alloc] initWithContentsOfFile:donwloadedListPath];
        if ([tmp respondsToSelector:@selector(allKeys)])
        {
            NSArray *allKeys = [tmp allKeys];
            if ([allKeys count] > 0)
            {
                if ([keyName isEqualToString:EMPTY_KEY_NAME])
                {
                    storedItems = [[NSMutableDictionary alloc] initWithContentsOfFile:donwloadedListPath];
                    return storedItems;
                }
                else
                {
                    if ([tmp objectForKey:keyName] != NULL)
                    {
                        NSString *downloadedImagePath = [themesDirectory stringByAppendingPathComponent:keyName];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:downloadedImagePath])
                        {
                            storedItems = [[NSMutableDictionary alloc] initWithContentsOfFile:donwloadedListPath];
                            return storedItems;
                        }
                    }
                }
            }
        }
    }
    else
    {
        storedItems = [[NSMutableDictionary alloc] initWithContentsOfFile:bundleListPath];
    }
    
    return storedItems;
}

- (BOOL)getIfCommercialPlistInDocuments:(NSString*)keyName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *themesDirectory = [documentsDirectory stringByAppendingString:@"/commercial/"];
    
    NSString *donwloadedListPath = [themesDirectory stringByAppendingPathComponent:@"commercial.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:donwloadedListPath])
    {
        NSDictionary *tmp = [[NSMutableDictionary alloc] initWithContentsOfFile:donwloadedListPath];
        if ([tmp respondsToSelector:@selector(allKeys)])
        {
            NSArray *allKeys = [tmp allKeys];
            if ([allKeys count] > 0)
            {
                if ([keyName isEqualToString:EMPTY_KEY_NAME])
                {
                    return YES;
                }
                else
                {
                    if ([tmp objectForKey:keyName] != NULL)
                    {
                        NSString *downloadedImagePath = [themesDirectory stringByAppendingPathComponent:keyName];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:downloadedImagePath])
                        {
                            return YES;
                        }
                    }
                }
            }
        }
    }

    
    return NO;
}

#pragma mark - download Commercials
- (void)downloadCommercial
{
    @autoreleasepool
    {
        // Themes directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *themesDirectory = [documentsDirectory stringByAppendingString:@"/commercial/"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:themesDirectory])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:themesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        NSData *responseData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:COMMERCIAL_PLIST_URL]];
        if (responseData == NULL)
        {
            return;
        }
        
        NSString *string = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
        if (string == NULL || string.length == 0)
        {
            return;
        }
        
        NSError *e = nil;
        NSPropertyListFormat format;
        id obj = [NSPropertyListSerialization propertyListWithData:[string dataUsingEncoding:NSUnicodeStringEncoding] options:NSPropertyListImmutable format:&format error:&e];
        
        if (obj == NULL && ![obj isKindOfClass:[NSDictionary class]])
        {
            return;
        }
        
        NSDictionary *remoteItems = (NSDictionary*)obj;
        //NSDictionary *remoteItems = [string propertyList];
        
        NSString *localPlistPath = [themesDirectory stringByAppendingPathComponent:@"commercial.plist"];
        NSMutableDictionary *storedItems = [[NSMutableDictionary alloc] initWithContentsOfFile:localPlistPath];
        
        if (![remoteItems respondsToSelector:@selector(allKeys)])
        {
            return;
        }
        
        NSArray *allKeys = [remoteItems allKeys];
        for(id key in allKeys)
        {
            NSDictionary *tmpD = [remoteItems objectForKey:key];
            //check for image existing
            NSString *existedImagePath = [themesDirectory stringByAppendingPathComponent:key];
            if ([[NSFileManager defaultManager] fileExistsAtPath:existedImagePath])
            {
                NSDictionary *storedKey = NULL;
                if ([storedItems objectForKey:key] != NULL)
                {
                    storedKey = [storedItems objectForKey:key];
                }
                
                if (storedKey != NULL && [tmpD objectForKey:@"last_update"] != NULL && [storedKey objectForKey:@"last_update"] != NULL && [tmpD objectForKey:@"imageURL"] != NULL && [storedKey objectForKey:@"imageURL"] != NULL)
                {
                    NSString *remoteDateStr = [tmpD objectForKey:@"last_update"];
                    NSString *cachedDateStr = [storedKey objectForKey:@"last_update"];
                    
                    NSString *remoteURLStr = [tmpD objectForKey:@"imageURL"];
                    NSString *cachedURLStr = [storedKey objectForKey:@"imageURL"];
                    
                    //if dates/URL are equal and existed don't dowload
                    if (remoteDateStr!= NULL && cachedDateStr != NULL && [remoteDateStr isEqualToString:cachedDateStr] && remoteURLStr!= NULL && cachedURLStr != NULL && [remoteURLStr isEqualToString:cachedURLStr])
                    {
                        NSLog(@"%@ remoteDate = %@ continue", key, remoteDateStr);
                        continue;
                    }
                    else
                    {
                        NSLog(@"%@ remoteDate = %@, cachedDateStr = %@ differs", key, remoteDateStr, cachedDateStr);
                    }
                }
            }
            
            if ([tmpD objectForKey:@"imageURL"] != NULL)
            {
                NSString *imageUrl = [tmpD objectForKey:@"imageURL"];
                NSLog(@"%@ imageURL = %@ download", key, imageUrl);
                
                NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                NSString *imagePath = [themesDirectory stringByAppendingPathComponent:key];
                
                if (data.length > 0)
                {
                    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:NULL];
                    [data writeToFile:imagePath atomically:YES];
                }
            }
        }
        
        //write to plist names and dates
        if ([remoteItems count] > 0)
        {
            NSLog(@"write to %@", localPlistPath);
            [remoteItems writeToFile:localPlistPath atomically:YES];
        }
    }
}

#pragma mark - Commercial
- (void)showCommercial
{
    //self.window.userInteractionEnabled = YES;
    //return;
    
    /*if (![self.navigationController.topViewController isKindOfClass:[HomePageViewController class]])
     {
     self.window.userInteractionEnabled = YES;
     return;
     }*/
    
    if([self.window viewWithTag:666] != NULL)
    {
        self.window.userInteractionEnabled = YES;
        return;
    }
    
    NSString *prevCommercialKey = EMPTY_KEY_NAME;
    NSString *curCommercialKey = EMPTY_KEY_NAME;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"commercial"] != NULL)
    {
        prevCommercialKey = [defaults objectForKey:@"commercial"];
    }
    
    NSDictionary *storedItems = [self getCommercialPlist:prevCommercialKey];
    
    NSArray *allKeys = [storedItems allKeys];
    NSUInteger index = [allKeys indexOfObject:prevCommercialKey];
    if (index != NSNotFound)
    {
        index++;
        if (index >= [allKeys count])
        {
            index = 0;
        }
    }
    else
    {
        index = 0;
    }
    
    curCommercialKey = [allKeys objectAtIndex:index];
    BOOL findInDocuments = [self getIfCommercialPlistInDocuments:curCommercialKey];
    storedItems = [self getCommercialPlist:curCommercialKey];
    
    if (!findInDocuments)
    {
        NSArray *allKeys = [storedItems allKeys];
        NSUInteger index = [allKeys indexOfObject:prevCommercialKey];
        if (index != NSNotFound)
        {
            index++;
            if (index >= [allKeys count])
            {
                index = 0;
            }
        }
        else
        {
            index = 0;
        }
        
        curCommercialKey = [allKeys objectAtIndex:index];
    }
    
    [defaults setObject:curCommercialKey forKey:@"commercial"];
    [defaults synchronize];
    
    NSDictionary *tmpD = [storedItems objectForKey:curCommercialKey];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *themesDirectory = [documentsDirectory stringByAppendingString:@"/commercial/"];
    NSString *existedImagePath = [themesDirectory stringByAppendingPathComponent:curCommercialKey];
    
    /*if (findInDocuments == YES && ![[NSFileManager defaultManager] fileExistsAtPath:existedImagePath])
     {
     tmpD = [storedItems objectForKey:@"commercial1"];
     }*/
    
    UIView *view = [[UIView alloc] initWithFrame:self.window.frame];
    view.backgroundColor = [UIColor clearColor];
    view.tag = 666;
    
    NSString *fileName = existedImagePath;
    UIImage *image;
    if (findInDocuments)
    {
        image = [UIImage imageWithContentsOfFile:fileName];
    }
    else
    {
        image = [UIImage imageNamed:curCommercialKey];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGRect frame = CGRectMake(0, 0, image.size.width/2, image.size.height/2);
    imageView.frame = frame;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = NO;
    
    [view addSubview:imageView];
    
    if ([tmpD objectForKey:@"text"] != NULL)
    {
        UILabel *textField = [[UILabel alloc] initWithFrame:CGRectMake(20, 250, 280, self.window.frame.size.height-250-70)];
        textField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
        textField.backgroundColor = [UIColor clearColor];
        textField.textColor = [UIColor whiteColor];
        textField.text = [tmpD objectForKey:@"text"];
        textField.textAlignment = UITextAlignmentCenter;
        textField.numberOfLines = 0;
        textField.userInteractionEnabled = NO;
        
        //[textField sizeToFit];
        
        [view addSubview:textField];
    }
    
    CGSize btnSize = [UIImage imageNamed:@"commercialDoneBtnOn.png"].size;
    BOOL twoButtons = NO;
    if ([tmpD objectForKey:@"actionBtn"] != NULL)
    {
        twoButtons = YES;
    }
    
    if ([tmpD objectForKey:@"actionBtn"] != NULL)
    {
        NSDictionary *actionBtnDict = [tmpD objectForKey:@"actionBtn"];
        
        if ([actionBtnDict objectForKey:@"buttonTitle"]!= NULL && [actionBtnDict objectForKey:@"buttonURL"]!= NULL)
        {
            UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            actionBtn.frame = CGRectMake(self.window.frame.size.width/2 + 10, self.window.frame.size.height - 75, btnSize.width/2, btnSize.height/2);
            [actionBtn setTitle:[actionBtnDict objectForKey:@"buttonTitle"] forState:UIControlStateNormal];
            actionBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
            [actionBtn setBackgroundImage:[UIImage imageNamed:@"commercialDoneBtnOn.png"] forState:UIControlStateNormal];
            [actionBtn setBackgroundImage:[UIImage imageNamed:@"commercialDoneBtnOff.png"] forState:UIControlStateHighlighted];
            [actionBtn addTarget:self action:@selector(downloadBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:actionBtn];
        }
        else
        {
            twoButtons = NO;
        }
    }
    
    if ([tmpD objectForKey:@"okBtn"] != NULL)
    {
        NSDictionary *okBtnDict = [tmpD objectForKey:@"okBtn"];
        if ([okBtnDict objectForKey:@"buttonTitle"]!= NULL)
        {
            UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            if (twoButtons)
            {
                okBtn.frame = CGRectMake(10, self.window.frame.size.height - 75, btnSize.width/2, btnSize.height/2);
            }
            else
            {
                okBtn.frame = CGRectMake((self.window.frame.size.width - btnSize.width/2)/2, self.window.frame.size.height - 75, btnSize.width/2, btnSize.height/2);
            }
            [okBtn setTitle:[okBtnDict objectForKey:@"buttonTitle"] forState:UIControlStateNormal];
            okBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
            [okBtn setBackgroundImage:[UIImage imageNamed:@"commercialDoneBtnOn.png"] forState:UIControlStateNormal];
            [okBtn setBackgroundImage:[UIImage imageNamed:@"commercialDoneBtnOff.png"] forState:UIControlStateHighlighted];
            [okBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:okBtn];
        }
    }
    else
    {
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        okBtn.frame = CGRectMake((self.window.frame.size.width - btnSize.width/2)/2, self.window.frame.size.height - 75, btnSize.width/2, btnSize.height/2);
        [okBtn setTitle:@"Close" forState:UIControlStateNormal];
        okBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
        [okBtn setBackgroundImage:[UIImage imageNamed:@"commercialDoneBtnOn.png"] forState:UIControlStateNormal];
        [okBtn setBackgroundImage:[UIImage imageNamed:@"commercialDoneBtnOff.png"] forState:UIControlStateHighlighted];
        [okBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:okBtn];
    }
    
    [self.window addSubview:view];
    
    
    self.window.userInteractionEnabled = YES;
}

-(void)okBtnClicked:(UIButton*)btn
{
    UIView *view = (UIView*)[self.window viewWithTag:666];
    view.alpha = 1;
    
    [UIView animateWithDuration:0.75 animations:^
     {
         view.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         [view removeFromSuperview];
     }];
}

-(void)downloadBtnClicked:(UIButton*)btn
{
    UIView *view = (UIView*)[self.window viewWithTag:666];
    [view removeFromSuperview];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *curCommercial = @"";
    if ([defaults objectForKey:@"commercial"] != NULL)
    {
        curCommercial = [defaults objectForKey:@"commercial"];
    }
    
    NSDictionary *storedItems = [self getCommercialPlist:curCommercial];
    if ([storedItems objectForKey:curCommercial] != NULL)
    {
        NSDictionary *tmpD = [storedItems objectForKey:curCommercial];
        
        if ([tmpD objectForKey:@"actionBtn"] != NULL)
        {
            NSDictionary *actionBtn = [tmpD objectForKey:@"actionBtn"];
            if ([actionBtn objectForKey:@"buttonURL"] != NULL)
            {
                NSString *strURL = [actionBtn objectForKey:@"buttonURL"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
            }
        }
    }
}


@end
