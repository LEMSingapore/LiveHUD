//
//  HomePageViewController.h
//  Poker Live
//
//  Created by Denis Senichkin on 2/13/13.
//  Copyright (c) 2013 Onix Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *configBtn;
@property (weak, nonatomic) IBOutlet UIButton *reviewBtn;
@property (weak, nonatomic) IBOutlet UIButton *playersNotesBtn;

@property (weak, nonatomic) IBOutlet UIImageView *bkgView;
@end
