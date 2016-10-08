//
//  QViewController.mm
//  iQuadtris
//
//  Created by Jared Bruni on 12/12/12.
//  Copyright (c) 2012 Jared Bruni. All rights reserved.
//

#import "QViewController.h"
#import "cmx_types.h"
#import "cmx_event.h"
#import "cmx_video.h"
#import "quadtris.h"
#define MOVEMENT_X 10
#define MOVEMENT_Y 10

QViewController *view_controller;
NSTimer *timer1,*timer2;
unsigned int screen_width = 480, screen_height = 300;
bool ac_mode = false;
enum SCREEN { SCR_GAME, SCR_GAMEOVER, SCR_START };
SCREEN game_screen = SCR_START;
quad::Game game;
unsigned int timer1_ID = 0, timer2_ID = 0;
cmx::video::Surface background_surface, start_surface, blocks[8];
cmx::video::Surface *front;//front surface
cmx::Rect rct,rct2,rct3,rct4,grid0,grid1,grid2,grid3,background_bg,screen_rect;
unsigned int image_shift = 0;
void drawGame();
void drawStart();
void drawGameOver();
inline void drawRect(cmx::video::Surface *, cmx::Rect &rect, unsigned int color);
void drawGrid(quad::GameGrid &grid, cmx::video::Surface *surface, cmx::Rect &source_rect, int direction);

void initCoords(unsigned int screen_w, unsigned int screen_h) {
    screen_width = screen_w;
    screen_height = screen_h;
    rct = cmx::Rect(0, 0,screen_width/2,screen_height/2);
    rct2 = cmx::Rect(screen_width/2, 0, screen_width/2, screen_height/2);
    rct3 = cmx::Rect(0, screen_height/2, screen_width/2, screen_height/2);
    rct4 = cmx::Rect(screen_width/2,screen_height/2,screen_width/2,screen_height/2);
    grid0 = cmx::Rect(screen_width/4, 0, screen_width/2, screen_height/2);
    grid1 = cmx::Rect(screen_width/4, screen_height/2, screen_width/2, screen_height/2);
    grid2 = cmx::Rect(0, screen_height/4, screen_width/4, screen_height/2);
    grid3 = cmx::Rect(screen_width-(screen_width/4), screen_height/4, screen_width/4, screen_height/2);
    background_bg = cmx::Rect(15, 35, 325, 45);
    screen_rect = cmx::Rect(0, 0, screen_width, screen_height);
    std::cout << "Data is " << screen_w << ":" << screen_h << "\n";
}

unsigned int timerUpdateCallback(unsigned int old_value, void *param) {
	game.timer_Update();
	return quad::Game::score.game_speed;
}

unsigned int blockProc(unsigned int old_value, void *param) {
	game.update();
	return old_value;
}

void switchPiece(unsigned int &i) {
	switch(i) {
		case quad::MOVE_UP:
			i = quad::MOVE_RIGHT;
			break;
		case quad::MOVE_DOWN:
			i = quad::MOVE_LEFT;
			break;
		case quad::MOVE_LEFT:
			i = quad::MOVE_UP;
			break;
		case quad::MOVE_RIGHT:
			i = quad::MOVE_DOWN;
			break;
    }
    
}

void setActiveGrid(unsigned int i) {
	switchPiece(i);
	if(game[0].isGameOver() == true && game[1].isGameOver() == true && game[2].isGameOver() == true && game[3].isGameOver() == true) {
		game_screen = SCR_GAMEOVER;
        [view_controller stopGame];
		return;
	}
	if(game[i].isGameOver()==true) {
		switchPiece(i);
	}
	game.setActiveGrid(i);
}

void changePiece() {
	unsigned int i = game.getActiveGridIndex();
	setActiveGrid(i);
}

void initGraphics() {

	if(background_surface.loadImage("background.jpg") == 1) {
		std::cout << "Background loaded successfully\n";
	}
	if(start_surface.loadImage("start.jpg") == 1) {
		std::cout << "Start screen background loaded successfully\n";
	}
	for(unsigned int i = 1; i <= 8; ++i) {
		std::ostringstream stream;
		stream<<"" << "block"<<i<<".jpg";
		if(blocks[i-1].loadImage(stream.str()) == 1) {
			std::cout << stream.str() << " successfully loaded.\n";
		}
	}
}

void startGame() {
    std::cout << "Screen Size: " << screen_width << "x" << screen_height << "\n";
    game.newGame((screen_width/2)/8, (screen_height/2)/8, (grid3.w/8), (grid3.h/8));
    game.setCallback(changePiece);
    timer1_ID = cmx::event::createTimer(quad::Game::score.game_speed, timerUpdateCallback);
    timer2_ID = cmx::event::createTimer(25, blockProc);
    game.setActiveGrid(0);
    game_screen = SCR_GAME;
}

void drawBlock(quad::GamePiece &p,cmx::Rect source_rect,cmx::video::Surface *surface, unsigned int x, unsigned int y, int direction) {
    switch(direction) {
        case 0: {
            for(unsigned int i = 0; i < 4; ++i) {
                unsigned int block_x = p.x+p.blocks[i].x;
                unsigned int block_y = p.y+p.blocks[i].y;
                cmx::Rect rct(x+(block_x*8), source_rect.h-(y+(block_y*8)), 8, 8);
                //drawRect(surface,rct, game_colors[p.blocks[i].color]);
                if(p.blocks[i].color>0)
                    cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height, blocks[p.blocks[i].color-1], cmx::Rect(0, 0, 8, 8), rct);
            }
        }
            break;
        case 1: {
            for(unsigned int i = 0; i < 4; ++i) {
                unsigned int block_x = p.x+p.blocks[i].x;
                unsigned int block_y = p.y+p.blocks[i].y;
                cmx::Rect rct(x+(block_x*8), (y+(block_y*8)), 8, 8);
                //drawRect(surface,rct, game_colors[p.blocks[i].color]);
                if(p.blocks[i].color>0)
                    cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height, blocks[p.blocks[i].color-1], cmx::Rect(0, 0, 8, 8), rct);
                
               
            }
        }
            break;
        case 2: {
            for(unsigned int i = 0; i < 4; ++i) {
                unsigned int pos_x = source_rect.x+source_rect.w+32;
                unsigned int block_x = p.x+p.blocks[i].x, block_y = p.y+p.blocks[i].y;
                cmx::Rect rct(pos_x-(block_y*8), source_rect.y+(block_x*8), 8, 8);
                //drawRect(surface, rct, game_colors[p.blocks[i].color]);
                if(p.blocks[i].color>0)
                    cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height, blocks[p.blocks[i].color-1], cmx::Rect(0, 0, 8, 8), rct);
                
            }
        }
            break;
        case 3: {
            for(unsigned int i = 0; i < 4; ++i) {
                unsigned int pos_x = source_rect.x-32;
                unsigned int block_x = p.x+p.blocks[i].x, block_y = p.y+p.blocks[i].y;
                cmx::Rect rct(pos_x+(block_y*8), source_rect.y+(block_x*8), 8, 8);
                //drawRect(surface, rct, game_colors[p.blocks[i].color]);
                if(p.blocks[i].color>0)
                    cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height, blocks[p.blocks[i].color-1], cmx::Rect(0, 0, 8, 8), rct);
            }
            
        }
            break;
	}
}

void drawGrid(quad::GameGrid &grid, cmx::video::Surface *surface, cmx::Rect &source_rect, int direction) {
    
	unsigned int x = 0, y = 0;
	unsigned int source_x = 0, source_y = 0;
	int grid_index = game.getActiveGridIndex();
    switch(direction) {
        case 0: // UP
        {
            int pos_x = source_rect.x;
            int pos_y = source_rect.y+source_rect.h;
            for(x = 0; x < grid.grid_width(); ++x) {
                for(y = 0; y < grid.grid_height(); ++y) {
                    cmx::Rect pos_rect(pos_x, pos_y, 8, 8);
                    unsigned int color = grid.game_grid[x][y].getColor();
                    if(color != 0 && color != 0xFE && grid.isGameOver() == false)
                        //drawRect(surface, pos_rect, game_colors[color]);
                        cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height,blocks[color-1], cmx::Rect(0, 0, 8, 8), pos_rect);
                    else if(color == 0xFE || (color != 0 && grid.isGameOver() == true))  cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height,blocks[rand()%game.score.BLOCK_COUNT], cmx::Rect(0, 0, 8, 8), pos_rect);
                    pos_y -= 8;
                }
                pos_y = source_rect.y+source_rect.h;
                pos_x += 8;
            }
        }
            break;
        case 1: // Down
        {
            unsigned int pos_x = source_rect.x;
            unsigned int pos_y = source_rect.y;
            for(x = 0; x < grid.grid_width(); ++x) {
                for(y = 0; y < grid.grid_height(); ++y) {
                    // draw
                    cmx::Rect pos_rect(pos_x, pos_y, 8, 8);
                    unsigned int color = grid.game_grid[x][y].getColor();
                    if(color != 0 && color != 0xFE && grid.isGameOver() == false) //drawRect(surface, pos_rect, game_colors[color]);
                        cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height, blocks[color-1], cmx::Rect(0, 0, 8, 8), pos_rect);
                    
                    else if(color == 0xFE || (color != 0 && grid.isGameOver() == true)) cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height,blocks[rand()%game.score.BLOCK_COUNT], cmx::Rect(0, 0, 8, 8), pos_rect);
                    pos_y += 8;
                }
                pos_y = source_rect.y;
                pos_x += 8;
            }
        }
            break;
        case 2: // Left
        {
            unsigned int pos_x = source_rect.x+source_rect.w+32;
            for(x = 0; x < grid.grid_width(); ++x) {
                for(y = 0; y < grid.grid_height(); ++y) {
                    cmx::Rect posRect(pos_x-(y*8), source_rect.y+(x*8), 8, 8);
                    unsigned int color = grid.game_grid[x][y].getColor();
                    if(color != 0 && color != 0xFE && grid.isGameOver() == false) //drawRect(surface, posRect, game_colors[color]);
                        cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height,blocks[color-1], cmx::Rect(0, 0, 8, 8), posRect);
                    
                    else if(color == 0xFE || (color != 0 && grid.isGameOver() == true)) cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height,blocks[rand()%game.score.BLOCK_COUNT], cmx::Rect(0, 0, 8, 8), posRect);
                }
            }
        }
            break;
        case 3: // Right
        {
            unsigned int pos_x = source_rect.x-32;
            for(x = 0; x < grid.grid_width(); ++x) {
                for(y = 0; y < grid.grid_height(); ++y) {
                    cmx::Rect posRect(pos_x+(y*8), source_rect.y+(x*8), 8, 8);
                    unsigned int color = grid.game_grid[x][y].getColor();
                    if(color != 0 && color != 0xFE && grid.isGameOver() == false) //drawRect(surface, posRect, game_colors[color]);
                        cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height, blocks[color-1], cmx::Rect(0, 0, 8, 8), posRect);
                    
                    else if(color == 0xFE || (color != 0 && grid.isGameOver() == true)) cmx::video::copySurfaceToBuffer(NULL, screen_width, screen_height,blocks[rand()%game.score.BLOCK_COUNT], cmx::Rect(0, 0, 8, 8), posRect);
                    
                }
            }
        }
            break;
	}
     

	if(direction == grid_index) {
		source_x += source_rect.x;
		source_y += source_rect.y;
		drawBlock(grid.piece,source_rect,surface,source_x, source_y,direction);
	}
}


void drawRect(cmx::video::Surface *surface,cmx::Rect &rect, unsigned int color) {
    CGRect r = CGRectMake(rect.x, rect.y, rect.w, rect.h);
    CGContextRef context = UIGraphicsGetCurrentContext();
    cmx::Color colz(color);
    CGContextSetRGBFillColor(context, colz.color.color[0]/255, colz.color.color[1]/255, colz.color.color[2]/255, colz.color.color[3]);
    CGContextFillRect(context, r);
}



@interface QViewController ()

@end

@implementation QViewController


@synthesize view_ctrl;

- (IBAction)tapDetected:(UIGestureRecognizer *)sender {
    game.getActiveGrid().movePos(quad::MOVE_BLOCKSWITCH);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup aft
    doubleTap = [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(tapDetected:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    view_controller = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return (UIInterfaceOrientationIsLandscape(toInterfaceOrientation));
}

- (void) startGame {
    initGraphics();
    startGame();
    timer1 = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector: @selector(proc1:) userInfo:nil repeats: YES];
    timer2 = [NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector: @selector(proc2:) userInfo:nil repeats: YES];
}

- (void) stopGame {
    [timer1 invalidate];
    [timer2 invalidate];
}

- (void) proc1: (id) sender {
    game.update();
}

- (void) proc2: (id) sender {
    game.timer_Update();
   [view_ctrl setNeedsDisplay];
}

@end

@implementation QView

typedef enum { STATE_0, STATE_1 } state;

CGPoint startLocation,stopLocation;
NSTimeInterval startTime,endTime;
state stated;

- (void) moveLeft {
    quad::GameGrid &grid = game.getActiveGrid();
    switch(grid.getDirection()) {
        case quad::MOVE_UP:
            grid.movePos(quad::MOVE_LEFT);
            break;
        case quad::MOVE_DOWN:
            grid.movePos(quad::MOVE_LEFT);
            break;
        case quad::MOVE_LEFT:
            grid.movePos(quad::MOVE_DOWN);
            break;
        case quad::MOVE_RIGHT:
            grid.movePos(quad::MOVE_UP);
            break;
        default:
            break;
    }
    
    [self setNeedsDisplay];
}

- (void) moveRight {
    quad::GameGrid &grid = game.getActiveGrid();
    switch(grid.getDirection()) {
        case quad::MOVE_UP:
            grid.movePos(quad::MOVE_RIGHT);
            break;
        case quad::MOVE_DOWN:
            grid.movePos(quad::MOVE_RIGHT);
            break;
        case quad::MOVE_LEFT:
            grid.movePos(quad::MOVE_UP);
            break;
        case quad::MOVE_RIGHT:
            grid.movePos(quad::MOVE_DOWN);
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (void) moveUp {
    quad::GameGrid &grid = game.getActiveGrid();
    
    switch(grid.getDirection()) {
        case quad::MOVE_UP:
            grid.movePos(quad::MOVE_DOWN);
            break;
        case quad::MOVE_DOWN:
            grid.movePos(quad::MOVE_UP);
            break;
        case quad::MOVE_LEFT:
            grid.movePos(quad::MOVE_LEFT);
            break;
        case quad::MOVE_RIGHT:
            grid.movePos(quad::MOVE_LEFT);
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (void) moveDown {
    quad::GameGrid &grid = game.getActiveGrid();
    switch(grid.getDirection()) {
        case quad::MOVE_UP:
            grid.movePos(quad::MOVE_UP);
            break;
        case quad::MOVE_DOWN:
            grid.movePos(quad::MOVE_DOWN);
            break;
        case quad::MOVE_LEFT:
            grid.movePos(quad::MOVE_RIGHT);
            break;
        case quad::MOVE_RIGHT:
            grid.movePos(quad::MOVE_RIGHT);
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (void) shiftColors {
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    int numTouch = ((NSSet*)[event allTouches]).count;
    int numTouchB = touches.count;
    
    if((stated == STATE_0) && (numTouchB == 1) && (numTouch == 1)) {
        startLocation = [[touches anyObject] locationInView:self];
        stopLocation = startLocation;
        startTime = [(UITouch*)[touches anyObject] timestamp];
        stated = STATE_1;
    } else stated = STATE_0;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(stated == STATE_1 && [touches count] == 1) {
        CGPoint stopLocationX = [[[touches allObjects] objectAtIndex: 0] locationInView:self];
        float abs_x = startLocation.x - stopLocationX.x, abs_y = startLocation.y - stopLocationX.y;
        if((fabs(abs_x) >= MOVEMENT_X)) {
            if(abs_x < 0) {
                [self moveRight];
                startLocation = stopLocationX;
            }
            else if(abs_x > 0){
                [self moveLeft];
                startLocation = stopLocationX;
            }
        }
        if((fabs(abs_y) >= MOVEMENT_Y)) {
            if(abs_y < 0) {
                [self moveDown];
                startLocation = stopLocationX;
            } else if(abs_y > 0) {
                [self moveUp];
                startLocation = stopLocationX;
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesCancelled: (NSSet *)touches withEvent: (UIEvent*)event {
    stated = STATE_0;
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    int numTouchE = ((NSSet *)[event allTouches]).count;
    int noTouchEnded = touches.count;
    if((stated == STATE_1) && (numTouchE == 1 && noTouchEnded == 1)) {
        stopLocation = [(UITouch *)[touches anyObject] locationInView:self];
        endTime = [(UITouch*)[touches anyObject] timestamp];
        [self setNeedsDisplay];
        stated = STATE_0;
    }
    
}


- (void) drawRect: (CGRect) rect {
    CGRect r = [self bounds];
    CGContextRef  context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    CGContextFillRect(context, r);
    CGRect rp = [self bounds];
    [background_surface.image_source drawInRect: rp];
    static unsigned int backcolor = _RGB(0,0,0);
    drawRect(0, grid0, backcolor);
    drawRect(0, grid1, backcolor);
    drawRect(0, grid2, backcolor);
    drawRect(0, grid3, backcolor);
    drawGrid(game[0],front,grid0, 0);// 0 - Up
    drawGrid(game[1],front,grid1, 1);// 1 - down
    drawGrid(game[2],front,grid2, 2);// 2 - left
    drawGrid(game[3],front,grid3, 3);// 3 - right
    
    NSString *score_str = [NSString stringWithFormat: @"Score: %d Cleared: %d Level: %d", game.score.score, game.score.num_clr, game.score.level];
    CGPoint p = CGPointMake(25,25);
    [[UIColor whiteColor] set];
    [score_str drawAtPoint: p withFont: [UIFont systemFontOfSize:12] ];
}

@end

