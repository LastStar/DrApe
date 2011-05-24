//
//  DATile.m
//  DrApe
//
//  Created by EskiMag on 4.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "DATile.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"


@implementation DATile

@synthesize mistaken = _mistaken,
            position = _position;

static id<DATileDelegate> _delegate = nil;
static NSMutableArray *_tiles = nil;
static NSMutableArray *_positions = nil;
static DATile *_nextTile = nil;
static NSUInteger _tilesPressed = 0;

+ (void)setDelegate:(id<DATileDelegate>)delegate {
    _delegate = delegate;
}

+ (NSMutableArray *)tiles {
    if (!_tiles) {
        _tiles = [[NSMutableArray alloc] init];
    }
    return _tiles;
}

+ (void)setTiles:(NSMutableArray *)tiles {
    [_tiles release];
    _tiles = tiles;
}

+ (NSMutableArray *)positions {
    if (!_positions) {
        _positions = [[NSMutableArray alloc] init];
        NSUInteger positionsCount = [UD integerForKey:@"TilesX"] * [UD integerForKey:@"TilesY"];
        for (int i = 0; i < positionsCount; i++) {
            [_positions addObject:[NSNumber numberWithInt:i]];
        }
    }
    return _positions;
}

+ (void)setPositions:(NSMutableArray *)positions {
    [_positions release];
    _positions = positions;
}

+ (NSUInteger)popRandomPosition {
    int positionsCount = [[self positions] count];
    int randomIndex = arc4random() % positionsCount;
    NSUInteger randomPosition = [[[self positions] objectAtIndex:randomIndex] integerValue];
    [[self positions] removeObjectAtIndex:randomIndex];
    
    return randomPosition;
}

+ (CGRect)getRandomRect {
    int intPosition = [DATile popRandomPosition];
    NSUInteger tileSize   = [UD integerForKey:@"TileSize"];
    NSUInteger tileBorder = [UD integerForKey:@"TileBorder"];
    int xPos = intPosition % [UD integerForKey:@"TilesX"];
    int yPos = intPosition / [UD integerForKey:@"TilesX"];
    CGFloat X = xPos * (tileSize + tileBorder) + tileBorder + [UD integerForKey:@"OffsetLeft"];
    CGFloat Y = yPos * (tileSize + tileBorder) + tileBorder + [UD integerForKey:@"OffsetTop"];
    
    return CGRectMake(X, Y, tileSize, tileSize);
}

+ (void)reset {
    [self removeAllTiles];
    _nextTile = nil;
    _tilesPressed = 0;
}

+ (void)hideAllTiles {
    for (DATile *tile in [self tiles]) {
        [tile hide];
    }
}

+ (void)flipAllTiles {
    for (DATile *tile in [self tiles]) {
        [tile flip];
    }
}

+ (void)mistakeAllTiles {
    for (DATile *tile in self.tiles) {
        tile.mistaken = YES;
    }
}

+ (void)removeAllTiles {
    self.positions = nil;
    for (DATile *tile in [self tiles]) {
        [tile removeFromSuperview];
    }
    self.tiles = nil;
}

+ (void)showMistakenTiles {
    for (DATile *tile in [self tiles]) {
        [tile setTitle:[NSString stringWithFormat:@"%d", tile.tag] forState:UIControlStateNormal];
        [tile setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_screen.png"]] forState:UIControlStateNormal];
        if (tile.mistaken) {
            tile.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile_red.png"]];
        } else {
            tile.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile_green.png"]];
        }
    }
}

- (id)init {
    return [self initWithFrame:[DATile getRandomRect]];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:[UD doubleForKey:@"FontSize"]];
        self.enabled = NO;
        [self setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile.png"]] forState:UIControlStateNormal];
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 3.0;
        self.layer.masksToBounds = YES;
        [self addTarget:self action:@selector(press) forControlEvents:UIControlEventTouchUpInside];
        [self setTitle:[NSString stringWithFormat:@"%i", [[DATile tiles] count] + 1] forState:UIControlStateNormal];
        self.tag = [DATile tiles].count + 8888;
        [[DATile tiles] addObject:self];
        if ([[DATile tiles] objectAtIndex:0] == self) {
            _nextTile = self;
        }
    }
    return self;
}

- (void)press {
    [self hide];
    _tilesPressed++;
    if ([_delegate respondsToSelector:@selector(tileHasBeenPressed:)]) {
        [_delegate tileHasBeenPressed:self];
    }
    if (_nextTile != self) {
        self.mistaken = YES;
        if ([_delegate respondsToSelector:@selector(tileHasBeenMistaken)]) {
            [_delegate tileHasBeenMistaken];
        }
    }
    if (_tilesPressed == [[DATile tiles] count]) {
        if ([_delegate respondsToSelector:@selector(allTilesPressed)]) {
            [_delegate allTilesPressed];
        }
    } else {
        _nextTile = [[DATile tiles] objectAtIndex:_tilesPressed];
    }
}

- (void)hide {
    self.enabled = NO;
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)flip {
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile.png"]];
    self.enabled = YES;
    [self setTitle:@"" forState:UIControlStateNormal];
}

@end
