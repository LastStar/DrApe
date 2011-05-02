//
//  BTMGame.h
//  BeatTheMonkey
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+BTM.h"
#import "BTMTile.h"

@protocol BTMGameDelegate;

@interface BTMGame : NSObject {}

- (BTMGame *)initWithView:(UIView *)aView;
- (void)startGame;
- (void)finishGame;
- (void)showMistakenTiles;
- (void)addNewHighScoreWithName:(NSString *)aName;
- (double)difficultyToTime:(NSUInteger)aDifficulty;
- (BOOL)isPlayingForFirstTime;

@property (nonatomic, retain) BTMTile *nextTile;
@property (nonatomic, retain) UIView *gameView;
@property (nonatomic, retain) NSMutableArray *tiles;
@property (nonatomic, retain) NSMutableArray *positions;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSString *highestScoreName;
@property (nonatomic, assign) NSUInteger highestScoreAmount;
@property (nonatomic, assign) NSUInteger tilesCount;
@property (nonatomic, assign) NSUInteger tilesPressed;
@property (nonatomic, assign) NSUInteger thisScore;
@property (nonatomic, assign) NSUInteger difficulty;
@property (nonatomic, assign) BOOL mistake;
@property (nonatomic, assign) BOOL automaticLevelUpgrading;
@property (nonatomic, assign) id<BTMGameDelegate> delegate;

@end

@protocol BTMGameDelegate <NSObject>
- (void)btmGameHasNewHighScore:(BTMGame *)aGame;
- (void)btmGameHasFinished:(BTMGame *)aGame mistake:(BOOL)aMistake;
- (void)btmGameIsPlayingForFirstTime:(BTMGame *)game;
@end
