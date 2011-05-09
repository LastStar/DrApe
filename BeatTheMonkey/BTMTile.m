//
//  BTMTile.m
//  BeatTheMonkey
//
//  Created by EskiMag on 4.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "BTMTile.h"
#import <QuartzCore/QuartzCore.h>


@implementation BTMTile

@synthesize position, mistaken, label;

+ (BTMTile *)tileWithFrame:(CGRect)aFrame {
    BTMTile *tile = [super buttonWithType:UIButtonTypeCustom];
    tile.frame = aFrame;
    tile.enabled = NO;
    tile.titleLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile.png"]];
    tile.backgroundColor = [UIColor clearColor];
    tile.layer.cornerRadius = 3.0;
    tile.layer.masksToBounds = YES;
    return tile;
}

@end
