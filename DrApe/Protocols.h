//
//  Protocols.h
//  drape
//
//  Created by EskiMag on 24.5.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DAGame, DATile;

@protocol DAGameDelegate <NSObject>
- (void)DAGame:(DAGame *)aGame hasNewHighScore:(NSUInteger)score;
- (void)DAGameHasFinished:(DAGame *)aGame withScore:(NSUInteger)score totalScore:(NSUInteger)totalScore andMistake:(BOOL)aMistake;
- (void)DAGameIsPlayingForFirstTime:(DAGame *)game;
- (void)DAGame:(DAGame *)aGame addsNewTile:(DATile *)tile;
- (void)DAGameDidComplete:(DAGame *)aGame;
@end

@protocol DATileDelegate <NSObject>
- (void)tileHasBeenPressed:(DATile *)tile;
- (void)allTilesPressed;
- (void)tileHasBeenMistaken;
@end