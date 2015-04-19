//
//  CardsPickerVC.h
//  TixClix
//
//  Created by Denis Senichkin on 1/17/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardsPickerVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSUInteger transitionState;
    
    NSString *currentSuit;
    
    NSArray *savedCardsArray;
    
    NSString *allBoardCards;
}

- (NSArray*)getSavedCards;
- (void)setSavedCards:(NSArray*)tmpArray;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UILabel *helpTitle;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *cardsLabel;

@property (weak, nonatomic) IBOutlet UIButton *spadesBtn;
@property (weak, nonatomic) IBOutlet UIButton *heartsBtn;
@property (weak, nonatomic) IBOutlet UIButton *diamondsBtn;
@property (weak, nonatomic) IBOutlet UIButton *clubsBtn;


@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, assign) NSInteger numberOfCards;

@property (nonatomic, retain) NSArray *pickerData;

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, assign) id delegate;

- (void)showWithTitle:(NSString *)title lockBackground:(BOOL)lockBackground animated:(BOOL)animated boardCards:(NSString*)boardCards;

- (void)hide:(BOOL)animated;
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (IBAction)cancelButtonClicked;
- (IBAction)doneButtonClicked;

- (void)makeAllCardNumbersDisabled;
- (void)makeAllCardNumbersEnabled;

- (void)makeSuitsEnabled;
- (void)makeSuitsDisabled:(BOOL)disable;

- (void)makeSuitsButtonsDisabled;

- (void)checkIfEnoughCards;

- (NSString*)getCardsString;

@end

#pragma mark -
@protocol CardsPickerVCDelegate <NSObject>
@optional


- (void)cardsPickerVC:(CardsPickerVC *)controller didSelectRow:(NSInteger)rowIndex inComponent:(NSInteger)component;
- (void)cardsPickerVCDoneButtonClicked:(CardsPickerVC *)pickerView;
- (void)cardsPickerVCCancelButtonClicked:(CardsPickerVC *)pickerView;

@end
