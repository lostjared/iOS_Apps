//
//  LMutatris.h
//  iMutatris
//
//  Created by Jared Bruni on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum { STATE_0, STATE_1 } state;


@interface LMutatris : NSObject {
    
    int level;
    float speed;
    BOOL level_ani;
}

- (void) drawGrid: (CGRect) rect;
- (void) startNewGame;
- (void) moveLeft;
- (void) moveRight;
- (void) moveDown;
- (void) shiftColors;
- (void) update;
- (void) grid_update;
- (void) changeLevel;
- (BOOL) is_GameOver;
- (int) score;
- (int) clears;
- (int) Level;
@end

extern UIImage *bg_image;
typedef struct _rgbVal {
    float values[4];
} rgbVal;

extern rgbVal colors[];
extern NSTimer *update_timer, *clear_timer;
extern id view_obj;
extern LMutatris *mutatris;

@interface gameScreen : UIView {
    BOOL game_over;
    id current_view;
    NSMutableDictionary *view_dictionary;
    CGPoint startLocation,stopLocation;
    NSTimeInterval startTime,endTime;
    state stated;
    
}
- (void) loadProgram;
- (void) setScreen: (NSString *) scr;
- (void) timerUpdate: (id) s;
- (void) gridUpdate: (id) g;
- (void) setGameTimer: (float) value;
- (void) loadScr;
- (void) drawScreen: (CGRect) r;
- (void) moveLeft;
- (void) moveRight;
- (void) moveDown;
- (void) shiftColors;
- (void) updateProgram: (id) s;
- (void) updateCallback;
@end