//
//  CardsPickerVC.m
//  TixClix
//
//  Created by Denis Senichkin on 1/17/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "CardsPickerVC.h"
#import <QuartzCore/QuartzCore.h>

enum {
	TransitionStateIdle = 0,
	TransitionStateAppearing,
	TransitionStateDisappearing,
} TransitionState;

@interface CardsPickerVC ()

@end

#define CUR_LABEL_BORDER 400

@implementation CardsPickerVC

@synthesize backgroundImageView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    allBoardCards = @"";
    
    self.doneBtn.enabled = NO;
    self.doneBtn.alpha = 0.5;
    
    self.numberOfCards = 2;
    
	//self.view.frame = CGRectMake(0, 0, 320, 460);
    self.view.frame = self.view.bounds;
    
    self.spadesBtn.enabled = NO;
    self.diamondsBtn.enabled = NO;
    self.heartsBtn.enabled = NO;
    self.clubsBtn.enabled = NO;
    
    self.spadesBtn.alpha = 0.5;
    self.diamondsBtn.alpha = 0.5;
    self.heartsBtn.alpha = 0.5;
    self.clubsBtn.alpha = 0.5;
    
    //NSLog(@"viewDidLoad self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
	[self hide:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)showWithTitle:(NSString *)title lockBackground:(BOOL)lockBackground animated:(BOOL)animated boardCards:(NSString*)boardCards
{
    //Settings *settings = [[AppDelegate sharedAppDelegate].dataManager getSettingsEntry];
    //allBoardCards = [settings getAllBoardCards];
    allBoardCards = boardCards;
    
    self.cardsLabel.text = @"";
    
    UILabel *borderLabel = (UILabel*)[self.contentView viewWithTag:CUR_LABEL_BORDER];
    [borderLabel removeFromSuperview];
    
    self.helpTitle.text = @"Select suit first, then select value of card.\nYou can change suit anytime.";
    
    //[self makeAllCardNumbersEnabled];
    //[self makeSuitsDisabled:YES];
    [self makeSuitsEnabled];
    [self makeAllCardNumbersDisabled];

    self.doneBtn.enabled = NO;
    self.doneBtn.alpha = 0.5;
    
    self.titleLabel.text = title;
    
	self.backgroundImageView.alpha = 0.5;
    
    //NSLog(@"showWithTitle self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
	
	CGRect frame = self.view.frame;
	frame.origin.y = self.view.frame.size.height;
	self.view.frame = frame;
	
	self.view.hidden = NO;
    
    if(animated) {
		[UIView beginAnimations:@"showView" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.35];
	}

	if (lockBackground)
    {
		self.backgroundImageView.alpha = 0.8;
	}
	
	frame.origin.y = self.view.bounds.size.height - frame.size.height;
	self.view.frame = frame;
	
	if(animated) {
		transitionState = TransitionStateAppearing;
		[UIView commitAnimations];
	}
    
    //NSLog(@"showWithTitle self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
	
}

- (void)hide:(BOOL)animated
{
    //NSLog(@"hide self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
	if(animated)
    {
		[UIView beginAnimations:@"hideView" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.35];
	}
    
	self.backgroundImageView.alpha = 0;
	
	CGRect frame = self.view.frame;
	frame.origin.y = self.view.bounds.size.height;
	self.view.frame = frame;
    
	if (animated)
    {
		transitionState = TransitionStateDisappearing;
		[UIView commitAnimations];
	}
    else
    {
		self.view.hidden = YES;
	}
    
    //NSLog(@"hide self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
    
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([animationID isEqualToString:@"showView"])
    {
		transitionState = TransitionStateIdle;
	}
    else if([animationID isEqualToString:@"hideView"])
    {
		transitionState = TransitionStateIdle;
		self.view.hidden = YES;
		self.delegate = nil;
	}
}

- (IBAction)cancelButtonClicked
{
	//targetButton.enabled = YES;
	[self hide:YES];
    
	if ([self.delegate respondsToSelector:@selector(cardsPickerVCCancelButtonClicked:)])
    {
		[self.delegate cardsPickerVCCancelButtonClicked:self];
	}
}

- (IBAction)doneButtonClicked
{
	[self hide:YES];
	
	if ([self.delegate respondsToSelector:@selector(cardsPickerVCDoneButtonClicked:)])
    {
		[self.delegate cardsPickerVCDoneButtonClicked:self];
	}
}

- (NSString*)getCardsString
{
    NSString *newString = [self.cardsLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return newString;
}

- (NSArray*)getSavedCards
{
    return savedCardsArray;
}

- (void)setSavedCards:(NSArray*)tmpArray
{
    savedCardsArray = tmpArray;
}

#pragma mark -
#pragma mark UIPickerViewDataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return [self.pickerData count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [[self.pickerData objectAtIndex:component] count];
}

#pragma mark -
#pragma mark UIPickerViewDelegate Methods
/*
 - (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
 
 }
 */

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSArray *componentData = [self.pickerData objectAtIndex:component];
	return [componentData objectAtIndex:row];
}

/*
 - (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
 
 }
 */

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	/*if ([self.delegate respondsToSelector:@selector(pickerViewController:didSelectRow:inComponent:)])
    {
		[self.delegate pickerViewController:self didSelectRow:row inComponent:component];
	}*/
}

- (IBAction)cardsBtnClicked:(UIButton*)sender
{
    NSArray *cards = [[NSArray alloc] initWithObjects:@"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"T", @"J", @"Q", @"K", @"A", nil];
    
    NSInteger cardNumber = sender.tag - 100;
    
    if (cardNumber < [cards count])
    {
        NSString *cardString = [cards objectAtIndex:cardNumber];
        self.cardsLabel.text = [NSString stringWithFormat:@"%@%@%@ ", self.cardsLabel.text, cardString, currentSuit];
    }
    
    [self makeAllCardNumbersEnabled];
    [self makeSuitsEnabled];
    
    [self checkIfEnoughCards];
}

- (void)createBorderForFrame:(CGRect)frame
{
    UILabel *borderLabel = (UILabel*)[self.contentView viewWithTag:CUR_LABEL_BORDER];
    [borderLabel removeFromSuperview];
    
    borderLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 1, frame.origin.y + 1, frame.size.width - 2, frame.size.height - 2)];
    borderLabel.backgroundColor = [UIColor clearColor];
    borderLabel.tag = CUR_LABEL_BORDER;
    [[borderLabel layer] setBorderWidth:2.0f];
    [[borderLabel layer] setBorderColor:[UIColor whiteColor].CGColor];
    [self.contentView addSubview:borderLabel];
}

- (IBAction)spadesBtnClicked:(UIButton*)sender
{
    //self.cardsLabel.text = [NSString stringWithFormat:@"%@%@ ", self.cardsLabel.text, @"♠"];
    currentSuit = sender.titleLabel.text;
    
    //[self makeSuitsDisabled:NO];
    
    [self createBorderForFrame:sender.frame];
    
    [self makeAllCardNumbersEnabled];
    //[self checkIfEnoughCards];
}

- (IBAction)heartsBtnClicked:(UIButton*)sender
{
    //self.cardsLabel.text = [NSString stringWithFormat:@"%@%@ ", self.cardsLabel.text, @"♥"];
    currentSuit = sender.titleLabel.text;
    
    [self createBorderForFrame:sender.frame];
    
    [self makeAllCardNumbersEnabled];
    //[self makeSuitsDisabled:NO];
    
    //[self checkIfEnoughCards];
}

- (IBAction)diamondsBtnClicked:(UIButton*)sender
{
    //self.cardsLabel.text = [NSString stringWithFormat:@"%@%@ ", self.cardsLabel.text, @"♦"];
    currentSuit = sender.titleLabel.text;
    
    [self createBorderForFrame:sender.frame];
    
    [self makeAllCardNumbersEnabled];
    //[self makeSuitsDisabled:NO];
    
    //[self checkIfEnoughCards];
}

- (IBAction)clubsBtnClicked:(UIButton*)sender
{
    //self.cardsLabel.text = [NSString stringWithFormat:@"%@%@ ", self.cardsLabel.text, @"♣"];
    currentSuit = sender.titleLabel.text;
    
    [self createBorderForFrame:sender.frame];
    
    [self makeAllCardNumbersEnabled];
    //[self makeSuitsDisabled:NO];
    
    //[self checkIfEnoughCards];
}

- (IBAction)backSpaceBtnClicked:(id)sender
{
    if (self.cardsLabel.text.length == 0)
    {
        return;
    }
    
    NSString *curText = self.cardsLabel.text;
    
    if (curText.length >= 3)
    {
        //NSString *deletedSymbol = [curText substringFromIndex:curText.length-3];
        self.cardsLabel.text = [curText substringToIndex:curText.length-3];
        
        /*if ([deletedSymbol isEqualToString:@" "])
        {
            if (curText.length > 0)
            {
                NSString *curText = self.cardsLabel.text;
                self.cardsLabel.text = [curText substringToIndex:curText.length-1];
            }
        }*/
    }
    else if (curText.length < 3)
    {
        self.cardsLabel.text = @"";
    }
    
    [self checkIfEnoughCards];
}


- (void)makeAllCardNumbersDisabled
{
    for (int i=100; i<113; i++)
    {
        UIButton *btn = (UIButton*)[self.view viewWithTag:i];
        btn.enabled = NO;
        btn.alpha = 0.5;
    }
}

- (void)makeAllCardNumbersEnabled
{
    //Settings *settings = [[AppDelegate sharedAppDelegate].dataManager getSettingsEntry];
    //Player *hero = [[AppDelegate sharedAppDelegate].dataManager getPlayerByName:settings.settingsHeroName];
    
    for (int i=100; i<113; i++)
    {
        UIButton *btn = (UIButton*)[self.view viewWithTag:i];
        
        NSString *card = [NSString stringWithFormat:@"%@%@", btn.titleLabel.text, currentSuit];

        //NSLog(@"self.cardsLabel.text = %@", self.cardsLabel.text);

        if (([allBoardCards rangeOfString:card].location != NSNotFound) || ([self.cardsLabel.text rangeOfString:card].location != NSNotFound))
        {
            btn.enabled = NO;
            btn.alpha = 0.5;
        }
        else
        {
            btn.enabled = YES;
            btn.alpha = 1;
        }
    }
}

- (void)checkIfEnoughCards
{
    if ((self.cardsLabel.text.length > 0) && (self.cardsLabel.text.length / 3 == self.numberOfCards))
    {
        [self makeSuitsDisabled:YES];
        [self makeAllCardNumbersDisabled];
        
        self.doneBtn.enabled = YES;
        self.doneBtn.alpha = 1;

    }
    else
    {
        self.doneBtn.enabled = NO;
        self.doneBtn.alpha = 0.5;

        if (self.cardsLabel.text.length % 3 != 0)
        {
            [self makeAllCardNumbersEnabled];
            [self makeSuitsDisabled:YES];
        }
        else
        {
            //[self makeAllCardNumbersDisabled];
            [self makeAllCardNumbersEnabled];
            [self makeSuitsEnabled];
        }
    }
}

- (void)makeSuitsEnabled
{
    self.spadesBtn.enabled = YES;
    self.diamondsBtn.enabled = YES;
    self.heartsBtn.enabled = YES;
    self.clubsBtn.enabled = YES;
    
    self.spadesBtn.alpha = 1;
    self.diamondsBtn.alpha = 1;
    self.heartsBtn.alpha = 1;
    self.clubsBtn.alpha = 1;
}

- (void)makeSuitsDisabled:(BOOL)disable
{
    self.spadesBtn.alpha = 0.5;
    self.diamondsBtn.alpha = 0.5;
    self.heartsBtn.alpha = 0.5;
    self.clubsBtn.alpha = 0.5;
    
    if (disable == YES)
    {
        [self makeSuitsButtonsDisabled];
    }
}

- (void)makeSuitsButtonsDisabled
{
    self.spadesBtn.enabled = NO;
    self.diamondsBtn.enabled = NO;
    self.heartsBtn.enabled = NO;
    self.clubsBtn.enabled = NO;
}

- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [self setSpadesBtn:nil];
    [self setHeartsBtn:nil];
    [self setDiamondsBtn:nil];
    [self setClubsBtn:nil];
    [self setCardsLabel:nil];
    [self setTitleLabel:nil];
    [self setDoneBtn:nil];
    [self setContentView:nil];
    [self setHelpTitle:nil];
    [self setBackBtn:nil];
    [super viewDidUnload];
}
@end
