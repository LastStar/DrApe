//
//  BeatTheMonkeyViewController.h
//  BeatTheMonkey
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipSideViewController.h"
#import "BTMGame.h"

@interface BeatTheMonkeyViewController : UIViewController <FlipSideViewControllerDelegate,
                                                           BTMGameDelegate,
                                                           UIAlertViewDelegate> {}

@property (nonatomic, retain) BTMGame *game;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) UILabel *scoreLabel;
@property (nonatomic, retain) UIButton *startGameButton;

- (IBAction)infoPressed:(id)sender;
- (IBAction)shareOnTwitter:(id)sender;

@end
