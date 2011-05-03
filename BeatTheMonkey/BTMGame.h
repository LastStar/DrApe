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

typedef enum { DAGameModeCampaign = 0,
               DAGameModeTraining = 1 } DAGameMode;

@protocol BTMGameDelegate;

@interface BTMGame : NSObject {}

- (BTMGame *)initWithView:(UIView *)aView;
- (void)startGame;
- (void)addNewHighScoreWithName:(NSString *)aName;
- (BOOL)isPlayingForFirstTime;

@property (nonatomic, retain) NSString *highestScoreName;
@property (nonatomic, assign) NSUInteger highestScoreAmount;
@property (nonatomic, assign) NSUInteger difficulty;
@property (nonatomic, assign) NSUInteger tilesCount;
@property (nonatomic, assign) NSUInteger thisScore;
@property (nonatomic, assign) id<BTMGameDelegate> delegate;
@property (nonatomic, assign) DAGameMode gameMode;

@end

@protocol BTMGameDelegate <NSObject>
- (void)btmGameHasNewHighScore:(BTMGame *)aGame;
- (void)btmGameHasFinished:(BTMGame *)aGame mistake:(BOOL)aMistake;
- (void)btmGameIsPlayingForFirstTime:(BTMGame *)game;
@end
