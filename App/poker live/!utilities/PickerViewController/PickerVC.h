//
//  PickerVC.h
//  TixClix
//
//  Created by Denis Senichkin on 1/17/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSUInteger transitionState;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextField;

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
@protocol PickerVCDelegate <NSObject>
@optional

- (void)pickerViewController:(PickerVC *)controller willAppearAnimated:(BOOL)animated;
- (void)pickerViewController:(PickerVC *)controller willDisappearAnimated:(BOOL)animated;
- (void)pickerViewController:(PickerVC *)controller didSelectRow:(NSInteger)rowIndex inComponent:(NSInteger)component;
- (void)pickerViewControllerDoneButtonClicked:(PickerVC *)pickerView;
- (void)pickerViewControllerCancelButtonClicked:(PickerVC *)pickerView;

@end
