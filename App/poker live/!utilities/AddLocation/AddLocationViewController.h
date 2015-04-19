//
//  AddTagsViewController.h
//  FBDaily
//
//  Created by DSenichkin on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "Player.h"

@interface AddLocationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate>
{
    NSMutableArray *allItems;
    NSMutableArray *searchResults;
    UITableView *myTableView;
    UIView *footerView;
    UIButton *addTagBtn;
    //Location *currentPost;
    
    BOOL isTyping;
    
    UISearchBar *searchBar;
    
    NSInteger pickerType;
    
    NSInteger CELL_DEFAULT_HEIGHT;
    BOOL DONT_SHOW_HERO;
}

- (void)setPickerType:(NSInteger)tmpPickerType showHeroName:(BOOL)showHeroName;

- (void)refreshContent;


- (BOOL)isSearching;

@property (nonatomic, retain) NSMutableArray *allItems;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

@property (nonatomic, assign) id delegate;

//@property (nonatomic, retain) Location *currentPost;

- (void)hideViewAndRemoveKeyboard;
- (void)showKeyboardCustom;

- (void)showWithTitle:(NSString *)title lockBackground:(BOOL)lockBackground animated:(BOOL)animated;
- (void)hide:(BOOL)animated;

@end


@protocol AddLocationViewControllerDelegate <NSObject>
@optional

- (void)newPlayerWasSelected:(NSString*)playerName;

@end