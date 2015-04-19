//
//  NotesViewController.h
//  FBDaily
//
//  Created by DSenichkin on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "Player.h"


@interface NotesViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
    UIButton *saveNoteBtn;
    UITextView *notesText;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) IBOutlet UIButton *saveNoteBtn;
@property (nonatomic, retain) IBOutlet UITextView *notesText;
@property (retain, nonatomic) IBOutlet UIButton *cancelNoteBtn;
@property (nonatomic, retain) Player *currentPlayer;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)registerForKeyboardNotifications;
- (void)loadNote:(Player*)post;
- (void)hide:(BOOL)animated;
- (void)showWithPlayer:(Player*)tmpPlayer animated:(BOOL)animated;

@end


@protocol NotesViewControllerDelegate <NSObject>
@optional

- (void)menuWillHide:(BOOL)animated;

@end
