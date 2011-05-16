//
//  FlipSideViewController.h
//  DrApe
//
//  Created by EskiMag on 8.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAGame.h"
#import "GradientButton.h"


@protocol FlipSideViewControllerDelegate;

@interface FlipSideViewController : UIViewController {}

@property (nonatomic, assign) id<FlipSideViewControllerDelegate> delegate;
@property (nonatomic, retain) DAGame *game;

@end

@protocol FlipSideViewControllerDelegate <NSObject>
- (void)flipSideViewControllerDidFinish:(FlipSideViewController *)controller;
@end