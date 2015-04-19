//
//  DoubleComponentInPickerViewViewController.m
//  DoubleComponentInPickerView
//
//  Created by Deepak Kumar on 24/09/09.
//  Copyright Rose India 2009. All rights reserved.
//

#import "DoubleComponentInPickerViewViewController.h"

@implementation DoubleComponentInPickerViewViewController
@synthesize marray2, marray1;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        // Custom initialization
        curCardsArray1 = [NSMutableArray new];
        curSuitsArray2 = [NSMutableArray new];
    }
    return self;
}
/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [self setCancelBtn:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.view.frame = self.view.bounds;
    
    NSArray *cards = [[NSArray alloc] initWithObjects:@"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"T", @"J", @"Q", @"K", @"A", nil];
    NSArray *suits = [[NSArray alloc] initWithObjects:@"♠", @"♥", @"♦", @"♣", nil];

    [curCardsArray1 addObjectsFromArray:cards];
    [curSuitsArray2 addObjectsFromArray:suits];
    
    self.marray1 = cards;
    self.marray2 = suits;
}

// Override to allow orientations other than the default portrait orientation.
/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}*/


-(IBAction)show:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(doublePickerViewControllerDoneButtonClicked:)])
    {
		[self.delegate doublePickerViewControllerDoneButtonClicked:self];
	}
    
    self.view.hidden = YES;
}

-(NSString*)returnSelectedCard
{
	NSInteger cardRow = [self.mpicker selectedRowInComponent:kCardsComponent];
	NSInteger suitRow = [self.mpicker selectedRowInComponent:kSuitsComponent];

    NSString *card = [curCardsArray1 objectAtIndex:cardRow];
	NSString *suit = [self.marray2 objectAtIndex:suitRow];
	
	NSString *cardWithSuit = [[NSString alloc] initWithFormat:@"%@%@", card, suit];
    
    return cardWithSuit;
}

- (IBAction)cancelBtnClicked:(id)sender
{
    self.view.hidden = YES;
}

#pragma mark - Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component == kSuitsComponent)
    {
		return [self.marray2 count];
    }
    
    NSInteger suitRow = [self.mpicker selectedRowInComponent:kSuitsComponent];
	NSString *suit = [self.marray2 objectAtIndex:suitRow];
    
    Settings *settings = [[AppDelegate sharedAppDelegate].dataManager getSettingsEntry];
    Player *hero = [[AppDelegate sharedAppDelegate].dataManager getPlayerByName:settings.settingsHeroName];
    
    NSInteger rows = [self.marray1 count] - [settings numberOfExistedCardsForSuit:suit] - [hero numberOfExistedCardsForSuit:suit];
	
	return rows;
}

#pragma mark - Picker Delegate Methods
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
   	if (component == kSuitsComponent)
    {
		[self.mpicker reloadAllComponents];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (component == kSuitsComponent)
    {
		return [self.marray2 objectAtIndex:row];
    }
    
    Settings *settings = [[AppDelegate sharedAppDelegate].dataManager getSettingsEntry];
    Player *hero = [[AppDelegate sharedAppDelegate].dataManager getPlayerByName:settings.settingsHeroName];
    
    NSInteger suitRow = [self.mpicker selectedRowInComponent:kSuitsComponent];
	NSString *suit = [self.marray2 objectAtIndex:suitRow];
    
    [curCardsArray1 removeAllObjects];
    [curCardsArray1 addObjectsFromArray:self.marray1];
    if ([settings numberOfExistedCardsForSuit:suit]>0 || [hero numberOfExistedCardsForSuit:suit]>0)
    {
        for(int i = ([curCardsArray1 count]-1); i >= 0; i--)
        {
            NSString *card = [curCardsArray1 objectAtIndex:i];
            
            NSInteger suitRow = [self.mpicker selectedRowInComponent:kSuitsComponent];
            NSString *suit = [self.marray2 objectAtIndex:suitRow];
            NSString *cardWithSuit = [[NSString alloc] initWithFormat:@"%@%@", card, suit];
            
            if ([settings isCardExistInSettingsCards:cardWithSuit] || [hero isCardExistInPlayerCards:cardWithSuit])
            {
                [curCardsArray1 removeObjectAtIndex:i];
            }
            
        }
        
    }

	
	return [curCardsArray1 objectAtIndex:row];
}

/*
 ♣
 BLACK CLUB SUIT
 Unicode: U+2663, UTF-8: E2 99 A3
 
 ⬥
 BLACK MEDIUM DIAMOND
 Unicode: U+2B25, UTF-8: E2 AC A5
 
 ♠
 BLACK SPADE SUIT
 Unicode: U+2660, UTF-8: E2 99 A0
 
 ❤
 HEAVY BLACK HEART
 Unicode: U+2764, UTF-8: E2 9D A4
*/

@end
