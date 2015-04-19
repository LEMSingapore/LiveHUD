
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "AddLocationViewController.h"

#import "Settings.h"


@implementation AddLocationViewController

@synthesize searchBar;
@synthesize allItems;
@synthesize searchResults;
@synthesize myTableView;
//@synthesize currentPost;


//#define CELL_DEFAULT_HEIGHT 40

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        allItems = [[NSMutableArray alloc] init];
        searchResults = [[NSMutableArray alloc] init];
        // Custom initialization
        
        pickerType = LOCATIONS_PICKER;
        CELL_DEFAULT_HEIGHT = 40;
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    myTableView.scrollEnabled = YES;
    
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [searchResults removeAllObjects];
    [myTableView reloadData];
    
    [self hide:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShowned:)  name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)  name:UIKeyboardWillHideNotification object:nil];
    
    /*AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [allItems removeAllObjects];
    [allItems setArray:[delegate.dataManager getAllLocations]];
    [myTableView reloadData];*/
}

- (void)setPickerType:(NSInteger)tmpPickerType showHeroName:(BOOL)showHeroName
{
    pickerType = tmpPickerType;
    
    if (pickerType == PLAYERS_PICKER)
    {
        CELL_DEFAULT_HEIGHT = 40;
        DONT_SHOW_HERO = !showHeroName;
    }
    else
    {
        CELL_DEFAULT_HEIGHT = 40;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.searchDisplayController.searchBar.text = @"";

    //[self refreshContent];
}

- (void)refreshContent
{
    //NSLog(@"refreshContent CELL_DEFAULT_HEIGHT = %d", CELL_DEFAULT_HEIGHT);
    
    self.searchDisplayController.searchBar.text = @"";
    self.searchBar.text = @"";
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [allItems removeAllObjects];
    
    if (pickerType == LOCATIONS_PICKER)
    {
        [allItems setArray:[delegate.dataManager getAllLocations]];
    }
    else
    {
        if (DONT_SHOW_HERO)
            [allItems setArray:[delegate.dataManager getAllPlayersNamesSortedByName:NO]];
        else
            [allItems setArray:[delegate.dataManager getAllPlayersNamesSortedByName:YES]];
    }
    
    //NSLog(@"allItems = %@", allItems);
    footerView.hidden = YES;
    [myTableView reloadData];
}

- (void)showKeyboardCustom
{
    if (self.view.hidden == NO)
    {
        if ([allItems count] ==0)
        {
            [self.searchBar becomeFirstResponder];
        }
    }
}

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}*/

- (void)hideViewAndRemoveKeyboard
{
    //self.view.hidden = YES;
    //[searchBar resignFirstResponder];
    [self.view endEditing:YES];
    [self hide:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if ([self isSearching])
    //if ([searchResults count]>0)
    {
        rows = [self.searchResults count];
    }
    else
    {
        rows = [self.allItems count];
    }
    
    if (rows < 10)
    {
        rows = 10;
    }
    
    return rows;
}

- (BOOL)isSearching
{
    if (searchBar.text.length == 0)
    {
        return NO;
    }

    return YES;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.textLabel.textColor = [UIColor colorWithRed:53.0/255 green:42.0/255 blue:35.0/255 alpha:1.0];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSInteger count = 0;
    if ([self isSearching])
        count = [searchResults  count];
    else
        count = [allItems count];
    
    if (indexPath.row < count)
    {
        //if ([searchResults count]>0)
        if ([self isSearching])
        {
            if (pickerType == LOCATIONS_PICKER)
            {
                Location *tmpTag = [searchResults objectAtIndex:indexPath.row];
                cell.textLabel.text =  tmpTag.locationName;
            }
            else
            {
                Player *tmpTag = [searchResults objectAtIndex:indexPath.row];
                cell.textLabel.text =  tmpTag.playerName;
            }
        }
        else
        {
            if (pickerType == LOCATIONS_PICKER)
            {
                Location *tmpTag = [allItems objectAtIndex:indexPath.row];
                cell.textLabel.text = tmpTag.locationName;
            }
            else
            {
                Player *tmpTag = [allItems objectAtIndex:indexPath.row];
                cell.textLabel.text =  tmpTag.playerName;
            }
        }
    }
    else
    {
        cell.textLabel.text =  @"";
    }
    
    return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)tmpSearchBar
{
    [tmpSearchBar resignFirstResponder];

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //return ((isTyping && searchBar.text.length>0) ? CELL_DEFAULT_HEIGHT : 0.0f);
    //NSLog(@"heightForHeaderInSection CELL_DEFAULT_HEIGHT = %d", CELL_DEFAULT_HEIGHT);
    return (searchBar.text.length > 0 ? CELL_DEFAULT_HEIGHT : 0.0f);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
//    if (!isTyping) { 
//        return NULL;
//    }
    
    if (footerView == NULL)
    {
        NSLog(@"CREATE FOOTER");
        
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_DEFAULT_HEIGHT)];
        [footerView setBackgroundColor:[UIColor clearColor]];
        
        addTagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [[addTagBtn layer] setBorderWidth:1.0f];
        [[addTagBtn layer] setBorderColor:[UIColor colorWithRed:224.0/255 green:224.0/255 blue:224.0/255 alpha:1.0].CGColor];
        
        [addTagBtn setBackgroundImage:[UIImage imageNamed:@"FooterBkg.png"] forState:UIControlStateNormal];
        //[addTagBtn setTitle:@"" forState: UIControlStateNormal];
        NSString *tmpStr = [NSString stringWithFormat:@" Tap to create new tag '%@\'", searchBar.text]; 
        [addTagBtn setTitle:tmpStr forState: UIControlStateNormal];
        
        //addTagBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
        //[addTagBtn setTitleColor:[UIColor colorWithRed:53.0/255 green:42.0/255 blue:35.0/255 alpha:1.0] forState:UIControlStateNormal];
        addTagBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22];
        [addTagBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        addTagBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [addTagBtn setFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_DEFAULT_HEIGHT)];
        [addTagBtn addTarget:self action:@selector(addTagBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:addTagBtn];
        
        
        //footerView.hidden = YES;
        return footerView;
    }
    else
        return footerView;
}

- (void)showWithTitle:(NSString *)title lockBackground:(BOOL)lockBackground animated:(BOOL)animated
{
    //self.titleTextField.text = title;
	//self.backgroundImageView.alpha = 0;
    
    //NSLog(@"showWithTitle self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
	
	CGRect frame = self.view.frame;
	frame.origin.y = self.view.frame.size.height;
	self.view.frame = frame;
	
	self.view.hidden = NO;
    
    /*if(animated) {
		[UIView beginAnimations:@"showView" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.35];
	}*/
    
	if (lockBackground)
    {
		//self.backgroundImageView.alpha = 1;
	}
    
    [self refreshContent];
	
    
    [UIView animateWithDuration:0.35 animations:^
     {
         CGRect frame = self.view.frame;
         frame.origin.y = 0;
         self.view.frame = frame;
     }
     completion:^(BOOL finished)
     {
     }];
    
    
	//frame.origin.y = self.view.bounds.size.height - frame.size.height;
	//self.view.frame = frame;
	
	/*if(animated) {
		[UIView commitAnimations];
	}*/
    
    //NSLog(@"showWithTitle self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
	
}

- (void)hide:(BOOL)animated
{
    //NSLog(@"hide self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
	/*if(animated)
    {
		[UIView beginAnimations:@"hideView" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.35];
	}*/
    
	//self.backgroundImageView.alpha = 0;
	
	/*CGRect frame = self.view.frame;
	frame.origin.y = self.view.bounds.size.height;
	self.view.frame = frame;*/
    
    /*CGRect frame = self.view.frame;
	frame.origin.y = self.view.frame.size.height;
	self.view.frame = frame;*/
    
    if (animated)
    {
        [UIView animateWithDuration:0.35 animations:^
         {
             CGRect frame = self.view.frame;
             frame.origin.y = self.view.frame.size.height;
             self.view.frame = frame;
         }
         completion:^(BOOL finished)
         {
             self.view.hidden = YES;
         }];
    }
    else
    {
        self.view.hidden = YES;
    }
    
	/*if (animated)
    {
		//transitionState = TransitionStateDisappearing;
		[UIView commitAnimations];
        self.view.hidden = YES;
	}
    else
    {
		self.view.hidden = YES;
	}*/
    
    //NSLog(@"hide self.controlsView.frame = %@", NSStringFromCGRect(self.controlsView.frame));
    
}

//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    NSLog(@"viewForFooterInSection");
//    
//    if (footerView == NULL)
//    {
//        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 319, 30)];   
//        [footerView setBackgroundColor:[UIColor whiteColor]];
//        
//        [addTagBtn release];
//        addTagBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//        [addTagBtn setBackgroundImage:[UIImage imageNamed:@"FooterBkg.png"] forState:UIControlStateNormal];
//        [addTagBtn setTitle:@"" forState: UIControlStateNormal];
//        [addTagBtn setTitleColor:[[[UIColor alloc] initWithRed:53.0/255 green:42.0/255 blue:35.0/255 alpha:1.0] autorelease] forState:UIControlStateNormal];
//        addTagBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        [addTagBtn setFrame:CGRectMake(0, 0, 319, 30)];
//        [addTagBtn addTarget:self action:@selector(addTagBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [footerView addSubview:addTagBtn];
//        
//        footerView.hidden = YES;
//        return footerView;
//    }
//    else
//        return footerView;
//}

- (void)addTagBtnClicked
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; 
    //NSLog(@"addTagBtnClicked");
    NSString *tmpStr = addTagBtn.titleLabel.text;
    NSInteger endStr = tmpStr.length-1;
    NSRange range = NSMakeRange (16, endStr-16);
    NSString *tagTame = [tmpStr substringWithRange:range];

    BOOL ifTagExist;
    
    if (pickerType == LOCATIONS_PICKER)
    {
        ifTagExist = [delegate.dataManager ifLocationExist:tagTame];
    }
    else
    {
        ifTagExist = [delegate.dataManager ifPlayerExist:tagTame];
    }
    
    if (ifTagExist)
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Already exist."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil,
                                  nil];
        [alertView show];

        return;
    }
    

    if (pickerType == LOCATIONS_PICKER)
    {
        [delegate.dataManager getLocationByName:tagTame];
    }
    else
    {
        [delegate.dataManager getPlayerByName:tagTame];
    }
    
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar endEditing:YES];
    
    [allItems removeAllObjects];
    
    if (pickerType == LOCATIONS_PICKER)
    {
        [allItems setArray:[delegate.dataManager getAllLocations]];
    }
    else
    {
        if (DONT_SHOW_HERO)
            [allItems setArray:[delegate.dataManager getAllPlayersNamesSortedByName:NO]];
        else
            [allItems setArray:[delegate.dataManager getAllPlayersNamesSortedByName:YES]];
    }
    
    [myTableView reloadData];
    footerView.hidden = YES;

    [addTagBtn setTitle:@"" forState: UIControlStateNormal];
    
    if (pickerType == LOCATIONS_PICKER)
    {
        Settings *settings = [[AppDelegate sharedAppDelegate].dataManager getSettingsEntry];
        settings.settingsLocationName = tagTame;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLocationName" object:nil];

    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(newPlayerWasSelected:)])
        {
            [self.delegate newPlayerWasSelected:tagTame];
        }
    }

    [self hideViewAndRemoveKeyboard];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)localSearchBar
{
    isTyping = YES;
    
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [searchResults removeAllObjects];
    [myTableView reloadData];
    
    //NSLog(@"textdidbegin");
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)localSearchBar

{
    searchBar.showsCancelButton = YES;
    isTyping = NO;
    //NSLog(@"textdidend");
}

- (void)searchBar:(UISearchBar *)localSearchBar textDidChange:(NSString *)searchText
{
    //NSLog(@"textdidchange");
    isTyping = YES;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; 
    [searchResults removeAllObjects];
    
    if (pickerType == LOCATIONS_PICKER)
    {
        [searchResults setArray:[delegate.dataManager getLocationsByName:searchText]];
    }
    else
    {
        if (DONT_SHOW_HERO)
            [searchResults setArray:[delegate.dataManager getPlayersByName:searchText showHero:NO]];
        else
            [searchResults setArray:[delegate.dataManager getPlayersByName:searchText showHero:YES]];
    }
    
    NSString *tmpStr = [NSString stringWithFormat:@" Tap to create '%@\'", searchText]; 
    [addTagBtn setTitle:tmpStr forState: UIControlStateNormal];
    footerView.hidden = NO;
    
    [myTableView reloadData];
    
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; 
    [searchResults removeAllObjects];
    
    if (pickerType == LOCATIONS_PICKER)
    {
        [searchResults setArray:[delegate.dataManager getLocationsByName:searchText]];
    }
    else
    {
        if (DONT_SHOW_HERO)
            [searchResults setArray:[delegate.dataManager getPlayersByName:searchText showHero:NO]];
        else
            [searchResults setArray:[delegate.dataManager getPlayersByName:searchText showHero:YES]];
    }
    
    [myTableView reloadData];
    
    NSString *tmpStr = [NSString stringWithFormat:@" Create new location '%@\'", searchText];
    
    if (pickerType == PLAYERS_PICKER)
    {
        tmpStr = [NSString stringWithFormat:@" Create new player '%@\'", searchText];
    }
    
    //NSLog(@"tmpStr = %@", tmpStr);
    [addTagBtn setTitle:tmpStr forState: UIControlStateNormal];
    footerView.hidden = NO;
}

- (IBAction)cancelBtnClicked:(id)sender
{
    //self.view.hidden = YES;
    /*[self hide:YES];
    [searchBar resignFirstResponder];*/
    [self hideViewAndRemoveKeyboard];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)localSearchBar
{
    //self.view.hidden = YES;
    //[self hide:YES];
    //[localSearchBar resignFirstResponder];
   [self hideViewAndRemoveKeyboard];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //NSLog(@"CELL_DEFAULT_HEIGHT = %d", CELL_DEFAULT_HEIGHT);
    return CELL_DEFAULT_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = 0;
    if ([self isSearching])
        count = [searchResults  count];
    else
        count = [allItems count];
    
    if (indexPath.row < count)
    {
        if (pickerType == LOCATIONS_PICKER)
        {
            Location *tmpTag;
            if ([self isSearching])
                tmpTag = [searchResults objectAtIndex:indexPath.row];
            else
                tmpTag = [allItems objectAtIndex:indexPath.row];
            
            Settings *settings = [[AppDelegate sharedAppDelegate].dataManager getSettingsEntry];
            settings.settingsLocationName = tmpTag.locationName;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLocationName" object:nil];
        }
        else
        {
            Player *tmpTag;
            if ([self isSearching])
                tmpTag = [searchResults objectAtIndex:indexPath.row];
            else
                tmpTag = [allItems objectAtIndex:indexPath.row];
            
            if ([self.delegate respondsToSelector:@selector(newPlayerWasSelected:)])
            {
                [self.delegate newPlayerWasSelected:tmpTag.playerName];
            }
        }
        
        footerView.hidden = YES;
        [addTagBtn setTitle:@"" forState: UIControlStateNormal];
        
        [self hideViewAndRemoveKeyboard];
        //self.view.hidden = YES;
    }
    
}

#pragma mark - Keyabords delegates
- (void)keyboardWillBeShowned:(NSNotification*)aNotification
{
    double animationDuration;
    animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSDictionary *userInfo = [aNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:animationDuration animations:^
     {
         NSLog(@"myTableView.frame = %@", NSStringFromCGRect(self.myTableView.frame));
         CGRect frame = self.myTableView.frame;
         
         NSInteger height = MIN(kbSize.height, kbSize.width);
         
         frame.size.height = self.myTableView.frame.size.height - height;
         self.myTableView.frame = frame;
         NSLog(@"myTableView.frame = %@", NSStringFromCGRect(self.myTableView.frame));
         
     }
      completion:^(BOOL finished)
     {
         
     }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    double animationDuration;
    animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSDictionary *userInfo = [aNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:animationDuration animations:^
     {
         NSLog(@"myTableView.frame = %@", NSStringFromCGRect(self.myTableView.frame));
         CGRect frame = self.myTableView.frame;
         
         NSInteger height = MIN(kbSize.height, kbSize.width);
         
         frame.size.height = self.myTableView.frame.size.height + height;
         self.myTableView.frame = frame;
         NSLog(@"myTableView.frame = %@", NSStringFromCGRect(self.myTableView.frame));
         
     }
                     completion:^(BOOL finished)
     {
         
     }];
}

@end
