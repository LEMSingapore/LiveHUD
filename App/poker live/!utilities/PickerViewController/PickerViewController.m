//
//  PickerViewController.m
//  Somagrand
//
//  Created by Alex Kalinichenko on 3/12/10.
//  Copyright 2010 Onix-systems. All rights reserved.
//

#import "PickerViewController.h"

enum {
	TransitionStateIdle = 0,
	TransitionStateAppearing,
	TransitionStateDisappearing,
} TransitionState;


@interface PickerViewController ()

@end


@implementation PickerViewController

@synthesize backgroundImageView;
@synthesize controlsView;
@synthesize topImageView;
@synthesize bottomImageView;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize titleLabel;
@synthesize pickerView;

@synthesize pickerData;

@synthesize tag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.frame = CGRectMake(0, 20, 320, 460);
    
    self.view.backgroundColor  = [UIColor redColor];
	
	//self.topImageView.image = [[OSThemeManager theme] imageNamed:@"pickerViewBg-Top.png" forControl:nil];
	//self.bottomImageView.image = [[OSThemeManager theme] imageNamed:@"pickerViewBg-Bottom.png" forControl:nil];
	
	// Buttons bg images
	UIImage *buttonImage = [[UIImage imageNamed:@"menuButtonBg.png"] stretchableImageWithLeftCapWidth:9 topCapHeight:0];
	[cancelButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
	[doneButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
	
	[self hide:NO];
}


#pragma mark -
- (void)setData:(NSArray *)data
{
	self.pickerData = data;

	[pickerView reloadAllComponents];
}

- (void)selectRowWithIndex:(NSInteger)rowIndex inComponent:(NSInteger)component animated:(BOOL)animated {
	if (component < 0 || component >= [pickerData count]) {
		return;
	}
	
	if (rowIndex < 0 || rowIndex >= [[pickerData objectAtIndex:component] count]) {
		return;
	}
	
	[pickerView selectRow:rowIndex inComponent:component animated:animated];
}

- (void)selectRowWithValue:(NSString *)rowValue inComponent:(NSInteger)component animated:(BOOL)animated {
	NSArray *componentData = [pickerData objectAtIndex:component];
	NSInteger rowIndex = [componentData indexOfObject:rowValue];

	if(rowIndex != NSNotFound) {
		[pickerView selectRow:rowIndex inComponent:component animated:animated];
	} else {
		[pickerView selectRow:0 inComponent:component animated:animated];
	}
}

- (NSInteger)getSelectedRowIndexInComponent:(NSInteger)component {
	if(component >= [pickerData count]) {
		return -1;
	} else {
		return [pickerView selectedRowInComponent:component];
	}
}

- (NSString *)getSelectedRowValueInComponent:(NSInteger)component {
	if(component >= [pickerData count]) {
		return nil;
	} else {
		NSArray *componentData = [pickerData objectAtIndex:component];
		NSInteger selectedRow = [pickerView selectedRowInComponent:component];

		if(selectedRow >= 0) {
			return [componentData objectAtIndex:selectedRow];
		} else {
			return nil;
		}
	}
}

- (void)showWithTitle:(NSString *)title lockBackground:(BOOL)lockBackground animated:(BOOL)animated
{
    
	if ([self.delegate respondsToSelector:@selector(pickerViewController:willAppearAnimated:)])
    {
		[self.delegate pickerViewController:self willAppearAnimated:animated];
	}
	
	titleLabel.text = title;

	self.backgroundImageView.alpha = 0;
	
	CGRect frame = self.controlsView.frame;
	frame.origin.y = self.view.frame.size.height;
	self.controlsView.frame = frame;
	
	self.view.hidden = NO;
	
	if(animated)
    {
		[UIView beginAnimations:@"showView" context:nil];	
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];	
		[UIView setAnimationDuration:0.35];
	}	

	if (lockBackground) {
		self.backgroundImageView.alpha = 1;
	}
	
	frame.origin.y = self.view.bounds.size.height - frame.size.height;
	self.controlsView.frame = frame;
	
	if(animated)
    {
		transitionState = TransitionStateAppearing;
		[UIView commitAnimations];
	}
}

- (void)hide:(BOOL)animated
{
	if (transitionState == TransitionStateDisappearing) {
		return;
	}
	
	if ([self.delegate respondsToSelector:@selector(pickerViewController:willDisappearAnimated:)]) {
		[self.delegate pickerViewController:self	willDisappearAnimated:animated];
	}

	
	if(animated) {
		[UIView beginAnimations:@"hideView" context:nil];	
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];	
		[UIView setAnimationDuration:0.35];
	}

	self.backgroundImageView.alpha = 0;
	
	CGRect frame = self.controlsView.frame;
	frame.origin.y = self.view.bounds.size.height;
	self.controlsView.frame = frame;

	if (animated) {
		transitionState = TransitionStateDisappearing;
		[UIView commitAnimations];
	} else {
		self.view.hidden = YES;
	}
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if([animationID isEqualToString:@"showView"]) {
		transitionState = TransitionStateIdle;
	} else if([animationID isEqualToString:@"hideView"]) {
		transitionState = TransitionStateIdle;
		self.view.hidden = YES;
		self.delegate = nil;
	}
}

- (IBAction)cancelButtonClicked
{
	[self hide:YES];

	if ([self.delegate respondsToSelector:@selector(pickerViewControllerCancelButtonClicked:)]) {
		[self.delegate pickerViewControllerCancelButtonClicked:self];
	}
}

- (IBAction)doneButtonClicked
{
	
	/*if([pickerData count] == 1 && targetButton != nil) {
		[targetButton setMyTitle:[self getSelectedRowValueInComponent:0]];
	}*/
	[self hide:YES];
	
	if ([self.delegate respondsToSelector:@selector(pickerViewControllerDoneButtonClicked:)]) {
		[self.delegate pickerViewControllerDoneButtonClicked:self];
	}
}

#pragma mark -
#pragma mark UIPickerViewDataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return [pickerData count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [[pickerData objectAtIndex:component] count];
}

#pragma mark -
#pragma mark UIPickerViewDelegate Methods
/*
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	
}
 */

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSArray *componentData = [pickerData objectAtIndex:component];
	return [componentData objectAtIndex:row];
}

/*
 - (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
 
 }
 */

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if ([self.delegate respondsToSelector:@selector(pickerViewController:didSelectRow:inComponent:)]) {
		[self.delegate pickerViewController:self didSelectRow:row inComponent:component];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	self.backgroundImageView = nil;
	self.controlsView = nil;
	self.topImageView = nil;
	self.bottomImageView = nil;
	self.cancelButton = nil;
	self.doneButton = nil;
	self.pickerView = nil;
}


@end
