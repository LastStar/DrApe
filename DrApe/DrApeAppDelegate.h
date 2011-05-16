//
//  DrApeAppDelegate.h
//  DrApe
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDictionary+intForKey.h"

@class DrApeViewController;

@interface DrApeAppDelegate : NSObject <UIApplicationDelegate> {}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet DrApeViewController *viewController;

@end
