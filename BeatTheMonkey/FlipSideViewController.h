//
//  FlipSideViewController.h
//  BeatTheMonkey
//
//  Created by EskiMag on 8.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTMGame.h"

@protocol FlipSideViewControllerDelegate;

@interface FlipSideViewController : UIViewController {}

@property (nonatomic, assign) id<FlipSideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UILabel *highScoreLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *difficultyControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *tilesCountControl;
@property (nonatomic, retain) BTMGame *game;
@property (nonatomic, assign) BOOL changed;

- (IBAction)done:(id)sender;
- (IBAction)difficultySwitched:(id)sender;
- (IBAction)tilesCountSwitched:(id)sender;

@end

@protocol FlipSideViewControllerDelegate
- (void)flipSideViewControllerDidFinish:(FlipSideViewController *)controller;
@end