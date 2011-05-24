//
//  DAGame.m
//  DrApe
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "DAGame.h"
#import "Utils.h"


@interface DAGame()

- (void)goToNextLevel;
- (NSUInteger)calculateScoreFromTime:(NSTimeInterval)gameTime;
- (void)setupOptions;
- (void)finishGame;
- (double)difficultyToTime:(NSUInteger)aDifficulty;
- (void)addTilesAfterTimeout;
- (void)flipAllTilesAfterTimeout;

@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, readwrite) DAGameMode gameMode;
@property (nonatomic, readwrite) NSUInteger difficulty;
@property (nonatomic) NSUInteger tilesPressed;
@property (nonatomic) NSUInteger tilesCount;
@property (nonatomic) NSUInteger thisScore;
@property (nonatomic) NSUInteger tempScore;
@property (nonatomic) BOOL mistake;

@end

@implementation DAGame

@synthesize tilesCount = _tilesCount,
          difficulty = _difficulty,
        tilesPressed = _tilesPressed,
             mistake = _mistake,
            delegate = _delegate,
           startDate = _startDate,
           thisScore = _thisScore,
           tempScore = _tempScore,
            gameMode = _gameMode,
         multiplayer = _multiplayer;

#pragma mark - Class methods

+ (NSUInteger)highestScoreAmount {
    return [UD integerForKey:@"HighestScoreAmount"];
}

+ (NSString *)highestScoreName {
    return [UD stringForKey:@"HighestScoreName"];
}

+ (void)setHighestScoreWithName:(NSString *)name andAmount:(int)highestscore {
    [UD setObject:name forKey:@"HighestScoreName"];
    [UD setInteger:highestscore forKey:@"HighestScoreAmount"];
    [UD synchronize];
}

#define THIS_VERSION 11
- (void)setupOptions {
    if (DA_DEBUG) NSLog(@"LastOptionsVersion %i", [UD integerForKey:@"LastOptionsVersion"]);
    if (![UD objectForKey:@"LastOptionsVersion"] || [UD integerForKey:@"LastOptionsVersion"] < THIS_VERSION) {
        [UD setInteger:THIS_VERSION forKey:@"LastOptionsVersion"];
        [UD setInteger:GAME_MODE forKey:@"GameMode"];
        [UD setInteger:TILES_COUNT forKey:@"TilesCount"];
        [UD setInteger:TILES_X forKey:@"TilesX"];
        [UD setInteger:TILES_Y forKey:@"TilesY"];
        [UD setInteger:DIFFICULTY forKey:@"Difficulty"];
        [UD setInteger:DIFFICULTY_MAX_ACHIEVED forKey:@"DifficultyMaxAchieved"];

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

- (id)init {
    if ((self = [super init])) {
        [self setupOptions];
        self.tempScore = 0;
        [DATile setDelegate:self];
    }
    
    return self;
}

- (void)dealloc {
    [_startDate release];
    [super dealloc];
}

- (void)addTiles {
    for (int i = 1; i <= self.tilesCount; i++) {
        DATile *tile = [[DATile alloc] init];
        if ([self.delegate respondsToSelector:@selector(DAGame:addsNewTile:)]) {
            [self.delegate DAGame:self addsNewTile:tile];
        }
    }
    
    [self flipAllTilesAfterTimeout];
}

- (void)goToNextLevel {
    if (DA_DEBUG) NSLog(@"Going to next level.");
    if (self.tilesCount == TILES_COUNT_MAX) { // going to next difficulty
        if (self.difficulty == DIFFICULTY_MAX) {
            if ([self.delegate respondsToSelector:@selector(DAGameDidComplete:)]) {
                [self.delegate DAGameDidComplete:self];
            }
        } else {
            [UD setInteger:(self.difficulty + 1) forKey:@"DifficultyMaxAchieved"]; // TODO nastavovat len v pripade, ze este som vo vyssom leveli nebol
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
    [DATile reset];
    self.tilesCount = [UD integerForKey:@"TilesCount"];
    self.difficulty = [UD integerForKey:@"Difficulty"];
    self.gameMode = [UD boolForKey:@"GameMode"];
    self.tilesPressed = 0;
    self.thisScore = 0;
    self.startDate = [NSDate date];
    if (self.gameMode == DAGameModeTraining || self.mistake) {
        self.tempScore = 0;
    }
    self.mistake = NO;
}

- (void)addTilesAfterTimeout {
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(addTiles) userInfo:nil repeats:NO];
}

- (void)flipAllTilesAfterTimeout {
    [NSTimer scheduledTimerWithTimeInterval:[self difficultyToTime:self.difficulty] target:[DATile class]
                                   selector:@selector(flipAllTiles) userInfo:nil repeats:NO];
}

- (void)startGame {
    [self setup];
    [self addTilesAfterTimeout];
}

- (void)startMultiplayerGame {
    [self setup];
    self.tilesCount = 4; // temporarily hardcoded
    self.gameMode = DAGameModeTraining;
    self.difficulty = 0; // temporarily hardcoded
    [self addTilesAfterTimeout];
}

- (NSUInteger)calculateScoreFromTime:(NSTimeInterval)gameTime {
    double diffCoef = self.difficulty + 1;
    double tileCoef = self.tilesCount;
    double timeCoef = (gameTime + tileCoef) / tileCoef;
    if (DA_DEBUG) NSLog(@"diff: %f time: %f tiles: %f", diffCoef, timeCoef, tileCoef);
    
    return round((tileCoef * tileCoef) / (timeCoef * timeCoef) * diffCoef * 10);
}

- (void)cancelGame {
    [DATile mistakeAllTiles];
    self.mistake = YES;
    [self finishGame];
}
    
- (void)resetCampaign {
    [UD setInteger:TILES_COUNT_MIN forKey:@"TilesCount"];
    [UD synchronize];
}

- (void)tileHasBeenMistaken {
    self.mistake = YES;
}

- (void)tileHasBeenPressed:(DATile *)tile {
    // nothing
}

- (void)allTilesPressed {
    // todo poslat nieco cez multiplayer
    [self finishGame];
}

- (void)finishGame {
    NSTimeInterval gameTime = -[self.startDate timeIntervalSinceNow];
    self.thisScore = [self calculateScoreFromTime:gameTime];
    
    if (DA_DEBUG) NSLog(@"self.thisScore = %d", self.thisScore);
    
    if (self.mistake) {
        [DATile showMistakenTiles];
        if (self.gameMode == DAGameModeCampaign) {
            [self resetCampaign];
        }
        if (self.tempScore > [DAGame highestScoreAmount]) {
            if ([self.delegate respondsToSelector:@selector(DAGame:hasNewHighScore:)]) {
                [self.delegate DAGame:self hasNewHighScore:self.tempScore];
            }
        }
        if ([self.delegate respondsToSelector:@selector(DAGameHasFinished:withScore:totalScore:andMistake:)]) {
            [self.delegate DAGameHasFinished:self withScore:self.tempScore totalScore:self.tempScore andMistake:YES];
        }
    } else {
        self.tempScore += self.thisScore;
        if (self.gameMode == DAGameModeCampaign) { [self goToNextLevel]; }
        if ([self.delegate respondsToSelector:@selector(DAGameHasFinished:withScore:totalScore:andMistake:)]) {
            [self.delegate DAGameHasFinished:self withScore:self.thisScore totalScore:self.tempScore andMistake:NO];
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

@end
