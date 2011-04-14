//
//  BTMGame.m
//  BeatTheMonkey
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "BTMGame.h"

#define BTM_DEBUG          1 // debug mode?

@interface BTMGame()
- (void)updateNextTile;    
@end

@implementation BTMGame

@synthesize nextTile, gameView, tilesCount, timeToHide, tiles, positions, tilesPressed, mistake, options, delegate, startDate, thisScore;

- (BTMGame *)initWithView:(UIView *)aView andOptions:(NSDictionary *)anOptions {
    self.options = anOptions;
    NSLog(@"Initializing BTMGame with anOptions = %@", self.options);
    self.gameView = aView;
    NSInteger userTilesCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"TilesCount"];
    self.tilesCount = userTilesCount > 0 ? userTilesCount : [self.options intForKey:@"TilesCount"];
    NSInteger userTimeToHide = [[NSUserDefaults standardUserDefaults] integerForKey:@"TimeToHide"];
    self.timeToHide = userTimeToHide > 0 ? userTimeToHide : [self.options intForKey:@"TimeToHide"];
    self.nextTile = nil;
    self.mistake = NO;
    self.tilesPressed = 0;
    self.tiles = [NSMutableArray array];
    self.positions = [NSMutableArray array];
    return self;
}

- (int)getRandomFreePosition {
    // if (BTM_DEBUG) { NSLog(@"self.positions count = %i", [self.positions count]); }
    int randomIndex = arc4random() % [self.positions count];
    // if (BTM_DEBUG) { NSLog(@"randomIndex %i", randomIndex); }
    int randomValue = [[self.positions objectAtIndex:randomIndex] intValue];
    // if (BTM_DEBUG) { NSLog(@"randomValue %i", randomValue); }
    [self.positions removeObjectAtIndex:randomIndex];
    return randomValue;
}

- (CGRect)getRandomPosition {
    int newPos = [self getRandomFreePosition];
    NSUInteger tileSize   = [self.options intForKey:@"TileSize"];
    NSUInteger tileBorder = [self.options intForKey:@"TileBorder"];
    int xPos = newPos % [self.options intForKey:@"TilesX"];
    int yPos = newPos / [self.options intForKey:@"TilesX"];
    float X = xPos * (tileSize + tileBorder) + tileBorder + [self.options intForKey:@"OffsetLeft"];
    float Y = yPos * (tileSize + tileBorder) + tileBorder + [self.options intForKey:@"OffsetTop"];
    return CGRectMake(X, Y, tileSize, tileSize);
}

- (void)removeOldTiles {
    [self.positions removeAllObjects];
    for (BTMTile *tile in self.tiles) {
        [tile removeFromSuperview];
    }   [self.tiles removeAllObjects];
    for (int i = 0; i < ([self.options intForKey:@"TilesX"] * [self.options intForKey:@"TilesY"]); i++) {
        [self.positions addObject:[NSNumber numberWithInt:i]];
    }
}

- (void)addTiles {
    for (int i = 1; i <= self.tilesCount; i++) {
        BTMTile *tile = [BTMTile tileWithFrame:[self getRandomPosition]];
        tile.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:[self.options intForKey:@"FontSize"]];
        [tile addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [tile setTitle:[NSString stringWithFormat:@"%i", i] forState:UIControlStateNormal];
        [tile setTag:i];
        [self.gameView addSubview:tile];
        [self.tiles addObject:tile];
    }   [self updateNextTile];
}

- (void)setup {
    self.tilesPressed = 0;
    self.thisScore = 0;
    self.startDate = [NSDate date];
    self.mistake = NO;
    [self removeOldTiles];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(addTiles) userInfo:nil repeats:NO];
}

- (void)updateNextTile {
    // if (BTM_DEBUG) NSLog(@"updateNextTile self.tilesPressed = %d", self.tilesPressed);
    self.nextTile = [self.tiles objectAtIndex:self.tilesPressed];
}

- (void)hideTiles {
	for (BTMTile *tile in self.tiles) {
		tile.backgroundColor = [UIColor whiteColor];
        tile.enabled = YES;
        [tile setTitle:@"" forState:UIControlStateNormal];
	 }
}

- (void)startGame {
    [self setup];
    NSLog(@"Calling NSTimer 1");
	[NSTimer scheduledTimerWithTimeInterval:self.timeToHide target:self
                                   selector:@selector(hideTiles) userInfo:nil repeats:NO];
}

- (float)highestScore {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"HighestScoreAmount"];
}

- (void)finishGame {
    // if (BTM_DEBUG) { NSLog(@"self.tiles count = %i", [self.tiles count]); }
    NSTimeInterval gameTime = -[self.startDate timeIntervalSinceNow];
    self.thisScore = (int)(1000 / (gameTime / self.tilesCount));
    NSLog(@"self.thisScore = %d", self.thisScore);
    if (self.mistake) {
        [self showMistakenTiles];
        if ([self.delegate respondsToSelector:@selector(btmGameHasFinished:mistake:)]) {
            [self.delegate btmGameHasFinished:self mistake:YES];
        }
    } else if (self.thisScore > [self highestScore]) {
        if ([self.delegate respondsToSelector:@selector(btmGameHasNewHighScore:)]) {
            [self.delegate btmGameHasNewHighScore:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(btmGameHasFinished:mistake:)]) {
            [self.delegate btmGameHasFinished:self mistake:NO];
        }
    }
}

- (void)addNewHighScoreWithName:(NSString *)aName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:aName forKey:@"HighestScoreName"];
    [userDefaults setDouble:self.thisScore forKey:@"HighestScoreAmount"];
    [userDefaults synchronize];
}

- (void)showMistakenTiles {
    for (BTMTile *tile in self.tiles) {
        [tile setTitle:[NSString stringWithFormat:@"%d", tile.tag] forState:UIControlStateNormal];
        if (tile.mistaken) {
            tile.backgroundColor = [UIColor redColor];
        } else {
            tile.backgroundColor = [UIColor greenColor];
        }
    }
}

- (void)buttonPressed:(BTMTile *)sender {
    if (BTM_DEBUG) { NSLog(@"tilesCount %d", self.tilesCount); }
    sender.enabled = NO;
    [sender setBackgroundColor:[UIColor blackColor]];
    if (self.nextTile != sender) {
        self.mistake = YES;
        sender.mistaken = YES;
    }
    self.tilesPressed++;
    if (self.tilesPressed == self.tilesCount) {
        [self finishGame];
    } else {
        [self updateNextTile];
    }
}   

- (void)dealloc {
//    NSLog(@"deallocating the game");
    [gameView release];
    [tiles release];
    [positions release];
    [nextTile release];
    [options release];
    [startDate release];
    [super dealloc];
}

@end
