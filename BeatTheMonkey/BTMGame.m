//
//  BTMGame.m
//  BeatTheMonkey
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "BTMGame.h"
#import "Utils.h"


@interface BTMGame()

- (void)updateNextTile;
- (void)goToNextLevel;
- (NSUInteger)calculateScoreFromTime:(NSTimeInterval)gameTime;
- (void)setupOptions;
- (void)finishGame;
- (void)showMistakenTiles;
- (double)difficultyToTime:(NSUInteger)aDifficulty;

@property (nonatomic, retain) BTMTile *nextTile;
@property (nonatomic, retain) UIView *gameView;
@property (nonatomic, retain) NSMutableArray *tiles;
@property (nonatomic, retain) NSMutableArray *positions;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, readwrite) DAGameMode gameMode;
@property (nonatomic, retain, readwrite) NSString *highestScoreName;
@property (nonatomic, readwrite) NSUInteger highestScoreAmount;
@property (nonatomic, readwrite) NSUInteger difficulty;
@property (nonatomic) NSUInteger tilesPressed;
@property (nonatomic) NSUInteger tilesCount;
@property (nonatomic) NSUInteger thisScore;
@property (nonatomic) NSUInteger tempScore;
@property (nonatomic) BOOL mistake;

@end

@implementation BTMGame

@synthesize    nextTile = _nextTile,
               gameView = _gameView,
             tilesCount = _tilesCount,
             difficulty = _difficulty,
                  tiles = _tiles,
              positions = _positions,
           tilesPressed = _tilesPressed,
                mistake = _mistake,
               delegate = _delegate,
              startDate = _startDate,
              thisScore = _thisScore,
              tempScore = _tempScore,
       highestScoreName = _highestScoreName,
     highestScoreAmount = _highestScoreAmount,
               gameMode = _gameMode;

#define THIS_VERSION 6
- (void)setupOptions {
    if (BTM_DEBUG) NSLog(@"LastOptionsVersion %i", [UD integerForKey:@"LastOptionsVersion"]);
    if (![UD objectForKey:@"LastOptionsVersion"] || [UD integerForKey:@"LastOptionsVersion"] < THIS_VERSION) {
        [UD setInteger:THIS_VERSION forKey:@"LastOptionsVersion"];
        [UD setInteger:GAME_MODE forKey:@"GameMode"];
        [UD setInteger:TILES_COUNT forKey:@"TilesCount"];
        [UD setInteger:TILES_X forKey:@"TilesX"];
        [UD setInteger:TILES_Y forKey:@"TilesY"];
        [UD setInteger:DIFFICULTY forKey:@"Difficulty"];
        [UD setInteger:DIFFICULTY_MAX_ACHIEVED forKey:@"DifficultyMaxAchieved"];
//        [UD setInteger:0 forKey:@"HighestScoreAmount"]; // todo disable

        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            [UD setInteger:IPAD_FONT_SIZE forKey:@"FontSize"]; 
            [UD setInteger:IPAD_OFFSET_LEFT forKey:@"OffsetLeft"];
            [UD setInteger:IPAD_OFFSET_TOP forKey:@"OffsetTop"];
            [UD setInteger:IPAD_TILE_BORDER forKey:@"TileBorder"];
            [UD setInteger:IPAD_TILE_SIZE forKey:@"TileSize"];
        } else {
            [UD setInteger:IPHONE_FONT_SIZE forKey:@"FontSize"]; 
            [UD setInteger:IPHONE_OFFSET_LEFT forKey:@"OffsetLeft"];
            [UD setInteger:IPHONE_OFFSET_TOP forKey:@"OffsetTop"];
            [UD setInteger:IPHONE_TILE_BORDER forKey:@"TileBorder"];
            [UD setInteger:IPHONE_TILE_SIZE forKey:@"TileSize"];        
        }
        [UD synchronize];
    }
}

- (BOOL)isPlayingForFirstTime {
    return ![UD boolForKey:@"TutorialSeen"];
}

- (BTMGame *)initWithView:(UIView *)aView {
    if ((self = [super init])) {
        [self setupOptions];
        self.gameView = aView;
        self.tempScore = 0;
        self.tiles = [NSMutableArray array];
        self.positions = [NSMutableArray array];
    }
    
    return self;
}

- (int)getRandomFreePosition {
    int randomIndex = arc4random() % [self.positions count];
    int randomValue = [[self.positions objectAtIndex:randomIndex] intValue];
    [self.positions removeObjectAtIndex:randomIndex];
    
    return randomValue;
}

- (CGRect)getRandomPosition {
    int newPos = [self getRandomFreePosition];
    NSUInteger tileSize   = [UD integerForKey:@"TileSize"];
    NSUInteger tileBorder = [UD integerForKey:@"TileBorder"];
    int xPos = newPos % [UD integerForKey:@"TilesX"];
    int yPos = newPos / [UD integerForKey:@"TilesX"];
    CGFloat X = xPos * (tileSize + tileBorder) + tileBorder + [UD integerForKey:@"OffsetLeft"];
    CGFloat Y = yPos * (tileSize + tileBorder) + tileBorder + [UD integerForKey:@"OffsetTop"];
    
    return CGRectMake(X, Y, tileSize, tileSize);
}

- (void)removeOldTiles {
    [self.positions removeAllObjects];
    for (BTMTile *tile in self.tiles) {
        [tile removeFromSuperview];
    }   [self.tiles removeAllObjects];
    NSUInteger positionsCount = [UD integerForKey:@"TilesX"] * [UD integerForKey:@"TilesY"];
    for (int i = 0; i < positionsCount; i++) {
        [self.positions addObject:[NSNumber numberWithInt:i]];
    }
}

- (void)addTiles {
    for (int i = 1; i <= self.tilesCount; i++) {
        BTMTile *tile = [BTMTile tileWithFrame:[self getRandomPosition]];
        tile.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:[UD doubleForKey:@"FontSize"]];
        [tile addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [tile setTitle:[NSString stringWithFormat:@"%i", i] forState:UIControlStateNormal];
        [tile setTag:i];
        [self.gameView addSubview:tile];
        [self.tiles addObject:tile];
    }
    
    [self updateNextTile];
}

- (void)goToNextLevel {
    if (BTM_DEBUG) NSLog(@"Going to next level.");
    if (self.tilesCount == TILES_COUNT_MAX) { // going to next difficulty
        if (self.difficulty == DIFFICULTY_MAX) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You finished the whole game" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
        } else {
            [UD setInteger:(self.difficulty + 1) forKey:@"DifficultyMaxAchieved"];
            [UD setInteger:(self.difficulty + 1) forKey:@"Difficulty"];
            [UD setInteger:TILES_COUNT_MIN forKey:@"TilesCount"];
            [UD synchronize];
        }
    } else { // increase tiles count
        [UD setInteger:(self.tilesCount + 1) forKey:@"TilesCount"];
        [UD synchronize];
    }
}

- (void)setup {
    self.tilesCount = [UD integerForKey:@"TilesCount"];
    self.difficulty = [UD integerForKey:@"Difficulty"];
    self.gameMode = [UD boolForKey:@"GameMode"];
    self.highestScoreName = [UD stringForKey:@"HighestScoreName"];
    self.highestScoreAmount = [UD integerForKey:@"HighestScoreAmount"];
    self.tilesPressed = 0;
    self.thisScore = 0;
    self.startDate = [NSDate date];
    self.mistake = NO;
    self.nextTile = nil;
    if (self.gameMode == DAGameModeTraining) {
        self.tempScore = 0;
    }
    
    [self removeOldTiles];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(addTiles) userInfo:nil repeats:NO];
}

- (void)updateNextTile {
    self.nextTile = [self.tiles objectAtIndex:self.tilesPressed];
}

- (void)hideTiles {
	for (BTMTile *tile in self.tiles) {
		tile.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile.png"]];
        tile.enabled = YES;
        [tile setTitle:@"" forState:UIControlStateNormal];
	 }
}

- (void)startGame {
    [self setup];
	[NSTimer scheduledTimerWithTimeInterval:[self difficultyToTime:self.difficulty] target:self
                                   selector:@selector(hideTiles) userInfo:nil repeats:NO];
}

- (float)highestScore {
    return [UD integerForKey:@"HighestScoreAmount"];
}

- (NSUInteger)calculateScoreFromTime:(NSTimeInterval)gameTime {
    double diffCoef = self.difficulty + 1;
    double timeCoef = gameTime;
    double tileCoef = self.tilesCount;
    if (BTM_DEBUG) NSLog(@"%f %f %f", diffCoef, timeCoef, tileCoef);
    
    return round((tileCoef / timeCoef) * diffCoef * 100);
}

- (void)cancelGame {
    for (BTMTile *tile in self.tiles) {
        tile.mistaken = YES;
    }
    
    self.mistake = YES;
    [self finishGame];
}
    
- (void)resetCampaign {
    [UD setInteger:TILES_COUNT_MIN forKey:@"TilesCount"];
    [UD synchronize];
}

- (void)finishGame {
    NSTimeInterval gameTime = -[self.startDate timeIntervalSinceNow];
    self.thisScore = [self calculateScoreFromTime:gameTime];
    
    if (BTM_DEBUG) NSLog(@"self.thisScore = %d", self.thisScore);
    
    if (self.mistake) {
        [self showMistakenTiles];
        if (self.gameMode == DAGameModeCampaign) {
            [self resetCampaign];
        }
        if (self.tempScore > self.highestScoreAmount) {
            if ([self.delegate respondsToSelector:@selector(btmGame:hasNewHighScore:)]) {
                [self.delegate btmGame:self hasNewHighScore:self.tempScore];
            }
        }
        if ([self.delegate respondsToSelector:@selector(btmGameHasFinished:withScore:totalScore:andMistake:)]) {
            [self.delegate btmGameHasFinished:self withScore:self.tempScore totalScore:self.tempScore andMistake:YES];
        }
        self.tempScore = 0;
    } else {
        self.tempScore += self.thisScore;
        if (self.gameMode == DAGameModeCampaign) { [self goToNextLevel]; }
        if ([self.delegate respondsToSelector:@selector(btmGameHasFinished:withScore:totalScore:andMistake:)]) {
            [self.delegate btmGameHasFinished:self withScore:self.thisScore totalScore:self.tempScore andMistake:NO];
        }
    }
}

- (double)difficultyToTime:(NSUInteger)difficulty {
    switch (difficulty) {
        case 0:
            return 2;
        case 1:
            return 1.3;
        case 2:
            return 0.9;
        default:
            return 2;
    }
}

- (void)addNewHighScoreWithName:(NSString *)aName {
    [UD setObject:aName forKey:@"HighestScoreName"];
    [UD setDouble:self.thisScore forKey:@"HighestScoreAmount"];
    [UD synchronize];
}

- (void)showMistakenTiles {
    for (BTMTile *tile in self.tiles) {
        [tile setTitle:[NSString stringWithFormat:@"%d", tile.tag] forState:UIControlStateNormal];
        [tile setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if (tile.mistaken) {
            tile.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile_red.png"]];
        } else {
            tile.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile_green.png"]];
        }
    }
}

- (void)buttonPressed:(BTMTile *)sender {
    sender.enabled = NO;
    [sender setBackgroundColor:[UIColor clearColor]];
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
    [_gameView release];
    [_tiles release];
    [_positions release];
    [_nextTile release];
    [_startDate release];
    [super dealloc];
}

@end
