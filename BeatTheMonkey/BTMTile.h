//
//  BTMTile.h
//  BeatTheMonkey
//
//  Created by EskiMag on 4.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BTMTile : UIButton {}

@property (nonatomic, assign) int position;
@property (nonatomic, assign) BOOL mistaken;
@property (nonatomic, copy) NSString *label;

+ (BTMTile *)tileWithFrame:(CGRect)aFrame;

@end
