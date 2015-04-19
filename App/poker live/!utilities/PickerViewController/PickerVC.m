//
//  PickerVC.m
//  TixClix
//
//  Created by Denis Senichkin on 1/17/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import "PickerVC.h"

enum {
	TransitionStateIdle = 0,
	TransitionStateAppearing,
	TransitionStateDisappearing,
} TransitionState;

@interface PickerVC ()

@end


@implementation PickerVC

@synthesize backgroundImageView;
@synthesize controlsView;
@synthesize topImageView;
@synthesize bottomImageView;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize pickerView;

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
    
	//self.view.frame = CGRectMake(0, 0, 320, 460);
    self.view.frame = self.view.bounds;
    
    //NSLog(@"viewDidLoad self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
	[self hide:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        tView.backgroundColor = [UIColor clearColor];
        tView.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22];
        // Setup label properties - frame, font, colors etc
    }
    
    // Fill the label text here
    NSArray *componentData = [self.pickerData objectAtIndex:component];
    tView.text = [NSString stringWithFormat:@"  %@", [componentData objectAtIndex:row]];

    return tView;
}


- (void)setData:(NSArray *)data
{
	self.pickerData = data;
    
	[self.pickerView reloadAllComponents];
}

- (void)selectRowWithIndex:(NSInteger)rowIndex inComponent:(NSInteger)component animated:(BOOL)animated
{
	if (component < 0 || component >= [self.pickerData count]) {
		return;
	}
	
	if (rowIndex < 0 || rowIndex >= [[self.pickerData objectAtIndex:component] count]) {
		return;
	}
	
	[self.pickerView selectRow:rowIndex inComponent:component animated:animated];
}

- (void)selectRowWithValue:(NSString *)rowValue inComponent:(NSInteger)component animated:(BOOL)animated
{
	NSArray *componentData = [self.pickerData objectAtIndex:component];
	NSInteger rowIndex = [componentData indexOfObject:rowValue];
    
	if(rowIndex != NSNotFound) {
		[self.pickerView selectRow:rowIndex inComponent:component animated:animated];
	} else {
		[self.pickerView selectRow:0 inComponent:component animated:animated];
	}
}

- (NSInteger)getSelectedRowIndexInComponent:(NSInteger)component
{
	if(component >= [self.pickerData count])
    {
		return -1;
	}
    else
    {
		return [self.pickerView selectedRowInComponent:component];
	}
}

- (NSString *)getSelectedRowValueInComponent:(NSInteger)component
{
	if(component >= [self.pickerData count])
    {
		return nil;
	}
    else
    {
		NSArray *componentData = [self.pickerData objectAtIndex:component];
		NSInteger selectedRow = [self.pickerView selectedRowInComponent:component];
        
		if(selectedRow >= 0)
        {
			return [componentData objectAtIndex:selectedRow];
		}
        else
        {
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
	
    self.titleTextField.text = title;
    
	self.backgroundImageView.alpha = 0;
    
    //NSLog(@"showWithTitle self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
	
	CGRect frame = self.controlsView.frame;
	frame.origin.y = self.view.frame.size.height;
	self.controlsView.frame = frame;
	
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
		self.backgroundImageView.alpha = 0.5;
	}
	
	frame.origin.y = self.view.bounds.size.height - frame.size.height;
	self.controlsView.frame = frame;
	
	if(animated) {
		transitionState = TransitionStateAppearing;
		[UIView commitAnimations];
	}
    
    //NSLog(@"showWithTitle self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
	
}

- (void)hide:(BOOL)animated
{
    //NSLog(@"hide self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
    
	if ([self.delegate respondsToSelector:@selector(pickerViewController:willDisappearAnimated:)])
    {
		[self.delegate pickerViewController:self	willDisappearAnimated:animated];
	}
	
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
	
	CGRect frame = self.controlsView.frame;
	frame.origin.y = self.view.bounds.size.height;
	self.controlsView.frame = frame;
    
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
    
	if ([self.delegate respondsToSelector:@selector(pickerViewControllerCancelButtonClicked:)])
    {
		[self.delegate pickerViewControllerCancelButtonClicked:self];
	}
}

- (IBAction)doneButtonClicked
{
	//targetButton.enabled = YES;
	
	/*if([self.pickerData count] == 1 && targetButton != nil)
    {
		[targetButton setMyTitle:[self getSelectedRowValueInComponent:0]];
	}*/
	
	[self hide:YES];
	
	if ([self.delegate respondsToSelector:@selector(pickerViewControllerDoneButtonClicked:)])
    {
		[self.delegate pickerViewControllerDoneButtonClicked:self];
	}
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
	if ([self.delegate respondsToSelector:@selector(pickerViewController:didSelectRow:inComponent:)])
    {
		[self.delegate pickerViewController:self didSelectRow:row inComponent:component];
	}
}



- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [self setControlsView:nil];
    [self setTopImageView:nil];
    [self setBottomImageView:nil];
    [self setCancelButton:nil];
    [self setDoneButton:nil];
    [self setPickerView:nil];
    [self setTitleTextField:nil];
    [super viewDidUnload];
}
@end
