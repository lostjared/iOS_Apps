//
//  QViewController.h
//  iQuadtris
//
//  Created by Jared Bruni on 12/12/12.
//  Copyright (c) 2012 Jared Bruni. All rights reserved.
//

#import <UIKit/UIKit.h>

extern unsigned int screen_width, screen_height;
void initCoords(unsigned int screen_w, unsigned int screen_h);
extern NSTimer *timer1,*timer2;

@class QView;

@interface QViewController : UIViewController {
    IBOutlet QView *view_ctrl;
    UITapGestureRecognizer *doubleTap;
    
}
@property (readwrite, retain) QView *view_ctrl;
- (void) startGame;
- (void) stopGame;
- (void) proc1: (id) sender;
- (void) proc2: (id) sender;
@end

@interface QView : UIView {
    

}
- (void) drawRect: (CGRect) rect;
- (void) moveLeft;
- (void) moveRight;
- (void) moveDown;
- (void) moveUp;
- (void) shiftColors;
@end

extern QViewController *view_controller;