//
//  BTMTile.m
//  BeatTheMonkey
//
//  Created by EskiMag on 4.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "BTMTile.h"


@implementation BTMTile

@synthesize position, mistaken, label;

+ (BTMTile *)tileWithFrame:(CGRect)aFrame {
    BTMTile *tile = [super buttonWithType:UIButtonTypeCustom];
    tile.frame = aFrame;
    tile.enabled = NO;
    tile.titleLabel.textColor = [UIColor whiteColor];
    tile.backgroundColor = [UIColor blackColor];
    return tile;
}

@end
