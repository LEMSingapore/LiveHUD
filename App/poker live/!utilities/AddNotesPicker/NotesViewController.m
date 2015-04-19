//
//  NotesViewController.m
//  FBDaily
//
//  Created by DSenichkin on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotesViewController.h"
#import "AppDelegate.h"

@implementation NotesViewController

@synthesize saveNoteBtn;
@synthesize notesText;
@synthesize currentPlayer;
@synthesize cancelNoteBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //documentsDirectory = [[NSString alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [self setCancelNoteBtn:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"notes viewDidLoad %@", NSStringFromCGRect(self.notesText.frame));
    
    // Do any additional setup after loading the view from its nib.
    [saveNoteBtn addTarget:self action:@selector(saveNotesClicked) forControlEvents:UIControlEventTouchUpInside];    
    notesText.textColor = [UIColor  colorWithRed:53.0/255 green:42.0/255 blue:35.0/255 alpha:1.0];
    [self registerForKeyboardNotifications];

    
    NSInteger yOffset = 25;
    for(int i=0; i < 200;i++)
    {
        UIImageView *monthHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, 705, 1)]; 
        monthHeader.backgroundColor = [UIColor  colorWithRed:221.0/255 green:221.0/255 blue:221.0/255 alpha:1.0];
        [notesText addSubview:monthHeader];
        [notesText sendSubviewToBack:monthHeader];
        yOffset+=22;
    }
    
    [self hide:NO];
    //NSLog(@"documentsDirectory = %@", documentsDirectory);
}

- (void)showWithPlayer:(Player*)tmpPlayer animated:(BOOL)animated
{
    //NSLog(@"showWithPlayer viewDidLoad %@", NSStringFromCGRect(self.notesText.frame));
    
    NSString *message;
    
    if (tmpPlayer.playerNotes == NULL || tmpPlayer.playerNotes.length == 0)
    {
        message = [NSString stringWithFormat:@"Add a note for %@", tmpPlayer.playerName];
    }
    else
    {
        message = [NSString stringWithFormat:@"Review a note for %@", tmpPlayer.playerName];
    }
    
    self.titleLabel.text = message;
    
    if (tmpPlayer != NULL)
    {
        notesText.text = tmpPlayer.playerNotes;
        currentPlayer = tmpPlayer;
    }
    
	CGRect frame = self.view.frame;
	frame.origin.y = self.view.frame.size.height;
	self.view.frame = frame;
	
	self.view.hidden = NO;
    
    [UIView animateWithDuration:0.35 animations:^
     {
         CGRect frame = self.view.frame;
         frame.origin.y = 0;
         self.view.frame = frame;
     }
                     completion:^(BOOL finished)
     {
     }];
}

- (void)loadNote:(Player*)post
{
    NSLog(@"loadNoteForDate");
    
    if (post != NULL)
    {
        notesText.text = post.playerNotes;
        currentPlayer = post;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"notes viewWillAppear");
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[self.view endEditing:YES];
    //return YES;
    
    return [textField resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)saveNotesClicked
{
    if (notesText.text.length > 0)
    {
        if (currentPlayer != NULL)
        {
            [currentPlayer savePlayerNotes:notesText.text];
        }
        
        notesText.text = @"";
    }
    
    [self hide:YES];
}

// Call this method somewhere in your view controller setup code.

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)  name:UIKeyboardWillHideNotification object:nil];
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    double animationDuration;
    animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSInteger kbHeight = MIN(kbSize.width, kbSize.height);
    
    [UIView animateWithDuration:animationDuration animations:^
     {
         //self.notesText.transform = CGAffineTransformMakeTranslation(0, -kbSize.width);
         CGRect frame = self.notesText.frame;
         frame.size.height = frame.size.height - kbHeight;
         self.notesText.frame = frame;
     }
     completion:^(BOOL finished)
     {
         
     }];    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    double animationDuration;
    animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSInteger kbHeight = MIN(kbSize.width, kbSize.height);
    
    [UIView animateWithDuration:animationDuration animations:^
     {
         //self.notesText.transform = CGAffineTransformMakeTranslation(0, kbSize.width);
         CGRect frame = self.notesText.frame;
         frame.size.height = frame.size.height + kbHeight;
         self.notesText.frame = frame;
     }
    completion:^(BOOL finished)
     {
         
     }];   
}

- (IBAction)cancelBtnClicked:(id)sender 
{
    [self hide:YES];
}

- (void)hide:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(menuWillHide:)])
    {
        [self.delegate menuWillHide:animated];
    }
    
    CGRect frame = self.notesText.frame;
    frame.size.height = self.notesText.bounds.size.height;
    self.notesText.frame = frame;
    
    [notesText resignFirstResponder];
    
    if (animated)
    {
        
        [UIView animateWithDuration:0.35 animations:^
         {
             //self.view.transform = CGAffineTransformMakeTranslation(0, 427);
             CGRect frame = self.view.frame;
             frame.origin.y = self.view.frame.size.height;
             self.view.frame = frame;
         }
         completion:^(BOOL finished)
         {
             self.view.hidden = YES;
             notesText.text = @"";
         }];
    }
    else
    {
        CGRect frame = self.view.frame;
        frame.origin.y = self.view.frame.size.height;
        self.view.frame = frame;
        
        self.view.hidden = YES;
    }
}

@end
