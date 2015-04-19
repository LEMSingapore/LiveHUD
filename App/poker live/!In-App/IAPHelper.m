//
//  IAPHelper.m
//  Live Poker Stats
//
//  Created by Denis Senichkin on 4/19/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation IAPHelper
{
    SKProductsRequest * _productsRequest;
    
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init]))
    {
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];

        ////####TODO
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setBool:NO forKey:HANDS_UNLIMITED_NAME];
        
        NSDictionary *products = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Products" ofType:@"plist"]];
        NSNumber *handsLimit = [NSNumber numberWithInteger:BRONZE_EDITION_HANDS];
        [defaults setObject:handsLimit forKey:HANDS_LIMIT_NAME];
        ////####TODO
        
        for (NSString *productIdentifier in _productIdentifiers)
        {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased)
            {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            else
            {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
            
            ////####TODO
            if (productPurchased)
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
                //NSDictionary *tmpProduct = [products objectForKey:productIdentifier];
                
                NSDictionary *tmpProduct;
                
                for (id key in products)
                {
                    NSDictionary *tmpDict = [products objectForKey:key];
                    if ([tmpDict objectForKey:@"appleId"] != NULL)
                    {
                        if ([[tmpDict objectForKey:@"appleId"] isEqualToString:productIdentifier])
                        {
                            tmpProduct = tmpDict;
                            break;
                        }
                    }
                }
                
                if (tmpProduct != NULL)
                {
                    if ([tmpProduct objectForKey:HANDS_LIMIT_NAME] != NULL)
                    {
                        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                        [f setNumberStyle:NSNumberFormatterDecimalStyle];
                        handsLimit = [f numberFromString:[tmpProduct objectForKey:HANDS_LIMIT_NAME]];
                    }
                    
                    if ([defaults objectForKey:HANDS_LIMIT_NAME] != NULL)
                    {
                        NSNumber *handsLimitStored = [defaults objectForKey:HANDS_LIMIT_NAME];
                        if ([handsLimitStored integerValue] < [handsLimit integerValue] || [handsLimit integerValue] == PLATINUM_EDITION_HANDS)
                        {
                            [defaults setObject:handsLimit forKey:HANDS_LIMIT_NAME];
                            //NSLog(@"initWithProductIdentifiers overwrite handsLimitStored = %d, handsLimit = %d", [handsLimitStored unsignedIntegerValue], [handsLimit integerValue]);
                        }
                    }
                    else
                    {
                        [defaults setObject:handsLimit forKey:HANDS_LIMIT_NAME];
                        //NSLog(@"initWithProductIdentifiers create handsLimit = %d", [handsLimit unsignedIntegerValue]);
                    }
                    
                    if ([handsLimit integerValue] == PLATINUM_EDITION_HANDS)
                    {
                        [defaults setBool:YES forKey:HANDS_UNLIMITED_NAME];
                        //NSLog(@"initWithProductIdentifiers unlimited hands");
                    }
                }
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:productIdentifier];
            }
            ////####TODO
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        //[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts)
    {
        NSLog(@"Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product
{
    NSLog(@"Buying %@...", product.productIdentifier);
    NSLog(@"Buying description %@...", product.description);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

// Add new method
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    [DejalBezelActivityView removeViewAnimated:YES];
    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    
    BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
    
    if (!productPurchased)
    {
        NSString *message = [NSString stringWithFormat:@"Operation was successfully completed."];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    ////2013-04-23
    ////Set up hands limits
    NSDictionary *products = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Products" ofType:@"plist"]];
    if (products != NULL)
    {
        NSDictionary *tmpProduct = NULL;
        for (NSString *key in products)
        {
            tmpProduct = [products objectForKey:key];
            
            if ([tmpProduct objectForKey:@"appleId"] != NULL)
            {
                if([[tmpProduct objectForKey:@"appleId"] isEqualToString:productIdentifier])
                {
                    break;
                }
            }
        }
        
        if (tmpProduct != NULL)
        {
            NSNumber *handsLimit = [NSNumber numberWithInteger:BRONZE_EDITION_HANDS];
            if ([tmpProduct objectForKey:HANDS_LIMIT_NAME] != NULL)
            {
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                handsLimit = [f numberFromString:[tmpProduct objectForKey:HANDS_LIMIT_NAME]];
            }
            
            if ([defaults objectForKey:HANDS_LIMIT_NAME] != NULL)
            {
                NSNumber *handsLimitStored = [defaults objectForKey:HANDS_LIMIT_NAME];
                if ([handsLimitStored integerValue] < [handsLimit integerValue] || [handsLimit integerValue] == PLATINUM_EDITION_HANDS)
                {
                    [defaults setObject:handsLimit forKey:HANDS_LIMIT_NAME];
                    //NSLog(@"provideContentForProductIdentifier overwrite handsLimitStored = %d, handsLimit = %d", [handsLimitStored unsignedIntegerValue], [handsLimit integerValue]);
                }
            }
            else
            {
                [defaults setObject:handsLimit forKey:HANDS_LIMIT_NAME];
                //NSLog(@"provideContentForProductIdentifier create handsLimit = %d", [handsLimit unsignedIntegerValue]);
            }
            
            if ([handsLimit integerValue] == PLATINUM_EDITION_HANDS)
            {
                [defaults setBool:YES forKey:HANDS_UNLIMITED_NAME];
                //NSLog(@"initWithProductIdentifiers unlimited hands");
            }
        }
    }
    ////2013-04-23
    ////Set up hands limits
    /*NSString *message = [NSString stringWithFormat:@"Operation was successfully completed."];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];*/
    
    [[AppDelegate sharedAppDelegate].navigationController popViewControllerAnimated:YES];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [DejalBezelActivityView removeViewAnimated:YES];
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [DejalBezelActivityView removeViewAnimated:YES];
    
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    [DejalBezelActivityView removeViewAnimated:YES];
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:transaction.error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                /////2013-05-07
                //[self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    };
}

- (void)restoreTransactions
{
    NSLog(@"restore Transactions...");
    
    [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"%@",error);
    
    NSString *message = [NSString stringWithFormat:@"%@", error.localizedDescription];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"%@",queue );
    //NSLog(@"Restored Transactions are once again in Queue for purchasing %@",[queue transactions]);
    
    //NSLog(@"received restored transactions: %i", queue.transactions.count);
    
    if (queue.transactions.count > 0)
    {
        NSString *message = [NSString stringWithFormat:@"Purchase(s) was successfully restored."];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:NO forKey:HANDS_UNLIMITED_NAME];
    
    NSDictionary *products = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Products" ofType:@"plist"]];
    NSNumber *handsLimit = [NSNumber numberWithInteger:BRONZE_EDITION_HANDS];
    [defaults setObject:handsLimit forKey:HANDS_LIMIT_NAME];
    
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        NSLog (@"product id is %@" , productID);
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:transaction.payment.productIdentifier];
        //NSDictionary *tmpProduct = [products objectForKey:productIdentifier];
        NSDictionary *tmpProduct;
        
        for (id key in products)
        {
            NSDictionary *tmpDict = [products objectForKey:key];
            if ([tmpDict objectForKey:@"appleId"] != NULL)
            {
                if ([[tmpDict objectForKey:@"appleId"] isEqualToString:transaction.payment.productIdentifier])
                {
                    tmpProduct = tmpDict;
                    break;
                }
            }
        }
        
        if (tmpProduct != NULL)
        {
            if ([tmpProduct objectForKey:HANDS_LIMIT_NAME] != NULL)
            {
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                handsLimit = [f numberFromString:[tmpProduct objectForKey:HANDS_LIMIT_NAME]];
            }
            
            if ([defaults objectForKey:HANDS_LIMIT_NAME] != NULL)
            {
                NSNumber *handsLimitStored = [defaults objectForKey:HANDS_LIMIT_NAME];
                if ([handsLimitStored integerValue] < [handsLimit integerValue])
                {
                    [defaults setObject:handsLimit forKey:HANDS_LIMIT_NAME];
                    //NSLog(@"initWithProductIdentifiers overwrite handsLimitStored = %d, handsLimit = %d", [handsLimitStored unsignedIntegerValue], [handsLimit integerValue]);
                }
            }
            else
            {
                [defaults setObject:handsLimit forKey:HANDS_LIMIT_NAME];
                //NSLog(@"initWithProductIdentifiers create handsLimit = %d", [handsLimit unsignedIntegerValue]);
            }
            
            if ([handsLimit integerValue] == PLATINUM_EDITION_HANDS)
            {
                [defaults setBool:YES forKey:HANDS_UNLIMITED_NAME];
               // NSLog(@"initWithProductIdentifiers unlimited hands");
            }
        }
        
    }
    
    [DejalBezelActivityView removeViewAnimated:YES];
}

@end
