//
//  StoreViewController.m
//  Live Poker Stats
//
//  Created by Denis Senichkin on 4/19/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//
#import "StoreViewController.h"

#define CELL_DEFAULT_HEIGHT 60

@interface StoreViewController ()
{
    NSArray *_products;
}
@end

@implementation StoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        appDelegate = [AppDelegate sharedAppDelegate];
        NSString *bundleListPath = [[NSBundle mainBundle] pathForResource:@"Products" ofType:@"plist"];
        productsFromBundle = [[NSMutableDictionary alloc] initWithContentsOfFile:bundleListPath];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restoreBtn.titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    self.restoreBtn.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.restoreBtn setTitle:@"RESTORE\nPURCHASES" forState:UIControlStateNormal];
    
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Refreshing In-App info..."].showNetworkActivityIndicator = YES;
    [self reload];
}

- (SKProduct *)productWithIdentifier:(NSString *)identifier
{
    NSString *predicateString = [NSString stringWithFormat:@"productIdentifier like '%@'", identifier];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    NSArray *filteredArray = [_products filteredArrayUsingPredicate:predicate];
    /*if ([filteredArray count])
    {
        NSDictionary *productInfo = [filteredArray objectAtIndex:0];
        SKProduct *product = [productInfo objectForKey:@"product"];
        return product;
    }*/
    if ([filteredArray count] > 0)
    {
        SKProduct *product = [filteredArray objectAtIndex:0];
        //SKProduct *product = [productInfo objectForKey:@"product"];
        return product;
    }
    
    return nil;
}

- (void)reload
{
    _products = nil;
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products)
    {
        if (success)
        {
            _products = products;
            NSLog(@"reload products = %@", products);
        }
        
        [DejalBezelActivityView removeViewAnimated:YES];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnClicked:(id)sender
{
    if (!helpTextViewMode)
    {
        [appDelegate.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self hideHelpTextView];
    }
}

- (IBAction)buyBtnClicked:(UIButton*)sender
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."].showNetworkActivityIndicator = YES;

    //[self performSelector:@selector(buyBtnThread:) withObject:sender afterDelay:2];
    //return;
    
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:@"Under Construction" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    return;*/
    
    NSString *productName = [NSString stringWithFormat:@"product%d", sender.tag];
    NSDictionary *tmpProduct = [productsFromBundle objectForKey:productName];
    SKProduct *product = [self productWithIdentifier:[tmpProduct objectForKey:@"appleId"]];
    
    if (product != NULL)
    {
        [[RageIAPHelper sharedInstance] buyProduct:product];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:@"Error occurred during initialization of in-app purchases." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)buyBtnThread:(UIButton*)sender
{
    NSString *productName = [NSString stringWithFormat:@"product%d", sender.tag];
    NSDictionary *tmpProduct = [productsFromBundle objectForKey:productName];
    NSString *productId = [tmpProduct objectForKey:@"appleId"];
    [[RageIAPHelper sharedInstance] provideContentForProductIdentifier:productId];
}


- (void)viewDidUnload
{
    [self setMyTableView:nil];
    [self setSecondaryView:nil];
    [self setHelpTextField:nil];
    [self setTitleView:nil];
    [self setBackBtn:nil];
    [self setBuyBtn:nil];
    [self setModalView:nil];
    [self setRestoreBtn:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"indexPath = %@", indexPath);
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for(UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    /*UITextField *backLabel = [[UITextField alloc] initWithFrame:CGRectMake(0, 5, 320, CELL_DEFAULT_HEIGHT)];
    backLabel.borderStyle = UITextBorderStyleRoundedRect;
    backLabel.backgroundColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.8];
    backLabel.userInteractionEnabled = NO;
    backLabel.alpha = 1;
    [cell.contentView addSubview:backLabel];*/
    
    NSString *productTextString = @"N/A";
    
    NSString *productName = [NSString stringWithFormat:@"product%d", indexPath.row+1];
    NSDictionary *tmpProduct = [productsFromBundle objectForKey:productName];
    SKProduct *product = [self productWithIdentifier:[tmpProduct objectForKey:@"appleId"]];
    
    if (product != NULL)
    {
        if (product.localizedTitle != NULL)
        {
            productTextString = product.localizedTitle;
        }
    }
    else
    {
        NSDictionary *products = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Products" ofType:@"plist"]];
        NSString *keyName = [NSString stringWithFormat:@"product%d", indexPath.row+1];
        
        if ([products objectForKey:keyName]!= NULL)
        {
            NSDictionary *productDict = [products objectForKey:keyName];
            if ([productDict objectForKey:@"title"]!= NULL)
            {
                productTextString = [productDict objectForKey:@"title"];
            }
        }
    }
        
    UILabel *productText = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 215, CELL_DEFAULT_HEIGHT)];
    productText.text = productTextString;
    productText.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];productText.textColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
    productText.textAlignment = UITextAlignmentLeft;
    productText.backgroundColor = [UIColor clearColor];
    productText.userInteractionEnabled = NO;
    [cell.contentView addSubview:productText];
    
    UIButton *buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    buyBtn.frame = CGRectMake(225, 10, 75, 40);
    buyBtn.backgroundColor = [UIColor clearColor];
    buyBtn.tag = indexPath.row+1;
    [buyBtn setTitle:@"View" forState:UIControlStateNormal];
    buyBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18];
    [buyBtn setBackgroundImage:[UIImage imageNamed:@"viewBtnOn.png"] forState:UIControlStateNormal];
    [buyBtn setBackgroundImage:[UIImage imageNamed:@"viewBtnOff.png"] forState:UIControlStateHighlighted];
    [buyBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:buyBtn];
    
    UIImageView *separator= [[UIImageView alloc] initWithFrame:CGRectMake(0, CELL_DEFAULT_HEIGHT, 320, 2)];
    separator.image = [UIImage imageNamed:@"separator.png"];
    separator.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:separator];
    
    return cell;
}

#pragma mark - btn Clicked
- (void)btnClicked:(UIButton*)sender
{
    if (isAnimated)
        return;
    
    NSInteger index = sender.tag;
    
    NSDictionary *products = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Products" ofType:@"plist"]];
    NSString *keyName = [NSString stringWithFormat:@"product%d", index];
    
    NSString *productTextString = @"N/A";
    if ([products objectForKey:keyName]!= NULL)
    {
        NSDictionary *productDict = [products objectForKey:keyName];
        
        SKProduct *product = [self productWithIdentifier:[productDict objectForKey:@"appleId"]];
        if (product != NULL)
        {
            if (product.localizedDescription != NULL)
            {
                productTextString = product.localizedDescription;
            }
        }
        else
        {
            if ([productDict objectForKey:@"text"]!= NULL)
            {
                productTextString = [productDict objectForKey:@"text"];
            }
        }
        
        if ([productDict objectForKey:@"btnTitle"]!= NULL)
        {
            [self.buyBtn setTitle:[productDict objectForKey:@"btnTitle"] forState:UIControlStateNormal];
        }
        
        self.buyBtn.enabled = YES;
        self.buyBtn.alpha = 1;
        
        if ([productDict objectForKey:@"appleId"]!=NULL)
        {
            NSString *productId = [productDict objectForKey:@"appleId"];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:productId] != NULL)
            {
                BOOL existId = [[NSUserDefaults standardUserDefaults] boolForKey:productId];
                
                if (existId == YES)
                {
                    [self.buyBtn setTitle:[productDict objectForKey:@"btnTitlePurchased"] forState:UIControlStateNormal];
                    self.buyBtn.enabled = NO;
                    self.buyBtn.alpha = 0.9;
                }
            }
        }
    }
    
    self.helpTextField.text = productTextString;
    
    self.buyBtn.tag = index;
    
    isAnimated = YES;
    self.modalView.hidden = NO;
    [self.view addSubview:self.secondaryView];
    [self.view bringSubviewToFront:self.titleView];
    [self.view bringSubviewToFront:self.backBtn];
    self.secondaryView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView animateWithDuration:0.4 animations:^
     {
         self.myTableView.frame = CGRectMake(self.myTableView.frame.origin.x - self.view.frame.size.width, self.myTableView.frame.origin.y, self.myTableView.frame.size.width, self.myTableView.frame.size.height);
         self.restoreBtn.frame = CGRectMake(self.restoreBtn.frame.origin.x - self.view.frame.size.width, self.restoreBtn.frame.origin.y, self.restoreBtn.frame.size.width, self.restoreBtn.frame.size.height);
         self.secondaryView.frame = CGRectMake(0, 0, self.secondaryView.frame.size.width, self.secondaryView.frame.size.height);
     }
     completion:^(BOOL finished)
     {
         isAnimated = NO;
         helpTextViewMode = YES;
     }];
}

- (void)hideHelpTextView
{
    if (isAnimated)
        return;
    
    isAnimated = YES;
    self.secondaryView.frame = CGRectMake(0, 0, self.secondaryView.frame.size.width, self.secondaryView.frame.size.height);
    
    [UIView animateWithDuration:0.4 animations:^
     {
         self.myTableView.frame = CGRectMake(self.myTableView.frame.origin.x + self.view.frame.size.width, self.myTableView.frame.origin.y, self.myTableView.frame.size.width, self.myTableView.frame.size.height);
         self.restoreBtn.frame = CGRectMake(self.restoreBtn.frame.origin.x + self.view.frame.size.width, self.restoreBtn.frame.origin.y, self.restoreBtn.frame.size.width, self.restoreBtn.frame.size.height);
         self.secondaryView.frame = CGRectMake(self.view.frame.size.width, 0, self.secondaryView.frame.size.width, self.secondaryView.frame.size.height);
         
     }
     completion:^(BOOL finished)
     {
         self.modalView.hidden = YES;
         isAnimated = NO;
         helpTextViewMode = NO;
         [self.secondaryView removeFromSuperview];
     }];
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return CELL_DEFAULT_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Restore btn
- (IBAction)restoreBtnClicked:(id)sender
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Restoring purchases..."].showNetworkActivityIndicator = YES;
    [[RageIAPHelper sharedInstance] restoreTransactions];
}


@end
