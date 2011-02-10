//
//  BeatTheMonkeyAppDelegate.h
//  BeatTheMonkey
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDictionary+BTM.h"

@class BeatTheMonkeyViewController;

@interface BeatTheMonkeyAppDelegate : NSObject <UIApplicationDelegate> {
@private
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BeatTheMonkeyViewController *viewController;
@property (nonatomic, retain) NSDictionary *options;

@end
