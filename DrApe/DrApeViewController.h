//
//  DrApeViewController.h
//  DrApe
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipSideViewController.h"
#import "DAGame.h"

@interface DrApeViewController : UIViewController <FlipSideViewControllerDelegate,
                                                   DAGameDelegate,
                                                   UIAlertViewDelegate> {}

@property (nonatomic, retain) DAGame *game;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) UILabel *scoreLabel;
@property (nonatomic, retain) UIButton *startGameButton;

- (IBAction)infoPressed:(id)sender;

@end
