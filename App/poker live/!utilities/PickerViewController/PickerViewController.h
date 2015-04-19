//
//  PickerViewController.h
//  Somagrand
//
//  Created by Alex Kalinichenko on 3/12/10.
//  Copyright 2010 Onix-systems. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
	UIImageView *backgroundImageView;
	
	UIView *controlsView;
	UIImageView *topImageView;
	UIImageView *bottomImageView;

	
	UIButton *cancelButton;
	UIButton *doneButton;
	UILabel *titleLabel;
	UIPickerView *pickerView;
	NSArray *pickerData;
	
	NSInteger tag;
	
	NSUInteger transitionState;
}

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UIView *controlsView;
@property (nonatomic, retain) IBOutlet UIImageView *topImageView;
@property (nonatomic, retain) IBOutlet UIImageView *bottomImageView;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;

@property (nonatomic, retain) NSArray *pickerData;

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, assign) id delegate;

- (void)setData:(NSArray *)data;
- (void)selectRowWithIndex:(NSInteger)rowIndex inComponent:(NSInteger)component animated:(BOOL)animated;
- (void)selectRowWithValue:(NSString *)rowValue inComponent:(NSInteger)component animated:(BOOL)animated;

- (NSInteger)getSelectedRowIndexInComponent:(NSInteger)component;
- (NSString *)getSelectedRowValueInComponent:(NSInteger)component;

- (void)showWithTitle:(NSString *)title lockBackground:(BOOL)lockBackground animated:(BOOL)animated;

- (void)hide:(BOOL)animated;
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (IBAction)cancelButtonClicked;
- (IBAction)doneButtonClicked;

@end

#pragma mark -
@protocol PickerViewControllerDelegate <NSObject>
@optional

- (void)pickerViewController:(PickerViewController *)controller willAppearAnimated:(BOOL)animated;
- (void)pickerViewController:(PickerViewController *)controller willDisappearAnimated:(BOOL)animated;
- (void)pickerViewController:(PickerViewController *)controller didSelectRow:(NSInteger)rowIndex inComponent:(NSInteger)component;
- (void)pickerViewControllerDoneButtonClicked:(PickerViewController *)pickerView;
- (void)pickerViewControllerCancelButtonClicked:(PickerViewController *)pickerView;

@end