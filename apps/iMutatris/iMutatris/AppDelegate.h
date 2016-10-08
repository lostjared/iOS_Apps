//
//  AppDelegate.h
//  iMutatris
//
//  Created by Jared Bruni on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class GameOver;
@class StartScreen;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) GameOver *gameOverController;
@property (strong, nonatomic) StartScreen *startScreenController;
- (void) setGameOver: (int) score Clears: (int) clears Level: (int) lvl;
- (void) setNewGame;
@end

extern AppDelegate *mainDelegate;