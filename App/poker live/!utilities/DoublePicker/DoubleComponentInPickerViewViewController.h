//
//  DoubleComponentInPickerViewViewController.h
//  DoubleComponentInPickerView
//
//  Created by Deepak Kumar on 24/09/09.
//  Copyright Rose India 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCardsComponent 0
#define kSuitsComponent 1

@interface DoubleComponentInPickerViewViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
	NSArray *marray2;
	NSArray *marray1;
    
    NSMutableArray *curCardsArray1;
	NSMutableArray *curSuitsArray2;
	
}
//@property(nonatomic, retain) UIPickerView *doublePicker;
@property(nonatomic, retain) NSArray *marray2;
@property(nonatomic, retain) NSArray *marray1;
@property (nonatomic, assign) id delegate;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *mpicker;

-(IBAction)show:(id)sender;
-(NSString*)returnSelectedCard;

@end


@protocol DoubleComponentInPickerViewViewControllerDelegate <NSObject>
@optional

- (void)doublePickerViewControllerDoneButtonClicked:(DoubleComponentInPickerViewViewController *)pickerView;

@end

