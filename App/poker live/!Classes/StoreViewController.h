//
//  StoreViewController.h
//  Live Poker Stats
//
//  Created by Denis Senichkin on 4/19/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>


@interface StoreViewController : UIViewController
{
    AppDelegate *appDelegate;
    NSDictionary *productsFromBundle;
    BOOL isAnimated;
    BOOL helpTextViewMode;
}

- (SKProduct *)productWithIdentifier:(NSString *)identifier;

@property (weak, nonatomic) IBOutlet UIImageView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIView *secondaryView;
@property (weak, nonatomic) IBOutlet UITextView *helpTextField;
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;
@property (weak, nonatomic) IBOutlet UIImageView *modalView;
@property (weak, nonatomic) IBOutlet UIButton *restoreBtn;

- (void)hideHelpTextView;

@end
