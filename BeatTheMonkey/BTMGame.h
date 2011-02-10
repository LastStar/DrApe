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

- (BTMGame *)initWithView:(UIView *)aView andOptions:(NSDictionary *)anOptions;
- (void)startGame;
- (void)finishGame;
- (void)showMistakenTiles;
- (void)addNewHighScoreWithName:(NSString *)aName;
- (float)highestScore;

@property (nonatomic, retain) BTMTile *nextTile;
@property (nonatomic, retain) NSDictionary *options;
@property (nonatomic, retain) UIView *gameView;
@property (nonatomic, retain) NSMutableArray *tiles;
@property (nonatomic, retain) NSMutableArray *positions;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, assign) NSInteger tilesCount;
@property (nonatomic, assign) NSInteger tilesPressed;
@property (nonatomic, assign) NSUInteger thisScore;
@property (nonatomic, assign) float timeToHide;
@property (nonatomic, assign) BOOL mistake;
@property (nonatomic, assign) id<BTMGameDelegate> delegate;

@end

@protocol BTMGameDelegate
- (void)btmGameHasNewHighScore:(BTMGame *)aGame;
- (void)btmGameHasFinished:(BTMGame *)aGame mistake:(BOOL)aMistake;
@end
