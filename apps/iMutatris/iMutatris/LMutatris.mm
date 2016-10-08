//
//  LMutatris.m
//  iMutatris
//
//  Created by Jared Bruni on 3/29/12.
//  Copyright (c) 2012 LostSideDead All rights reserved.
//

#import "LMutatris.h"
#import "ViewController.h"
#import "AppDelegate.h"
#include<cstdlib>
#include<cstring>

#define MOVEMENT_X 16
#define MOVEMENT_Y 16

UIImage *bg_image=0;
rgbVal colors[] = { {1,1,1,1}, {0.5, 0.5, 0.5, 1}, {0.5, 0, 0, 1}, {0.7, 0, 0.7, 1}, {0, 0, 0.5f, 1}, {0, 1, 0, 1}, {1,0,1,1}, {0.5, 0.2, 0.7}};
NSTimer *update_timer, *clear_timer;
id view_obj, gid;


namespace mp
{
    
    class blockType {
    public:
        
        blockType() { x = 0, y = 0, z = 0; index_color = 0;}
        blockType(int x, int y, int z, unsigned int index_color) { this->x = x, this->y = y, this->index_color = index_color, this->z = z;  }
        blockType(const blockType &t);
        
        void operator=(const blockType &t);
        bool operator==(const blockType &t);
        
        int x,y,z;
        int index_color;
    };
    
    
    
    class mxMut;
    
    
    class gameBlock {
    public:
        enum block_t { BLOCK_VERT, BLOCK_HORIZ, BLOCK_SQUARE };
        int x,y,z;
        blockType blocks[4];
        block_t block_type;
        gameBlock() { x = 0; y = 0; z = 0; }
        gameBlock(const gameBlock &c);
        void operator=(const gameBlock &b);
        void randBlock();
    };
    
    
    
    template<size_t width, size_t height, size_t depth>
    class mpGrid {
        
    public:
        enum { DATA_WIDTH=width,DATA_HEIGHT=height,DATA_DEPTH=depth };
        int data[width][height][depth];
        int grid_w,grid_h,grid_z;
        mpGrid(mxMut *m) { this->mut = m; grid_w =width; grid_h=height; memset(data, 0, sizeof(data)); }
        void addScore(int, int);
        void clear();
        void merge(const gameBlock &block);
        void update();
        void merge_down();
        int score, blocks_cleared;
        mxMut *mut;
        
    };
    
    
    class mxMut  {
        
    public:
        
        
        mxMut();
        
        void newGame();
        void moveLeft();
        void moveRight();
        void moveDown();
        void moveInward();
        void shiftColor();
        void nextBlock();
        void update();
        
        bool is_gameOver() const { return game_over; }
        
        int nscore, nclear;
        bool increase;
        
        enum { GRID_W = 17,
            GRID_H = 26, GRID_Z=1};
        
        mpGrid<GRID_W, GRID_H, GRID_Z> grid;
        gameBlock current, next;
        bool game_over;
        int inc_s, inc_c;
        void addn(int ns, int nc) {
            
            nscore = ns, nclear  = nc; inc_s += ns, inc_c += nc;
            if((inc_c % 20) == 0) {
                increase = true;
            }
            
        }
        void freeze(bool t) { freez = t; }
        
        bool freez;
        void update_moveDown();
        
    protected:
        void update_mergeBlock();
        
        
    };
    
    
    
    
    template<size_t width, size_t height, size_t depth>
    void mpGrid<width,height,depth>::addScore(int score, int cleared)
    {
        this->score += score;
        this->blocks_cleared += cleared;
        mut->addn(score,cleared);
        
    }
    
    
    
    template<size_t width, size_t height, size_t depth>
    void mpGrid<width,height,depth>::clear()
    {
        
        memset(data, 0, sizeof(data));
        
        
    }
    
    template<size_t width, size_t height, size_t depth>
    void mpGrid<width,height,depth>::merge(const gameBlock &block)
    {
        int offset_x = block.x;
        int offset_y = block.y;
        int offset_z = block.z;
        for(unsigned int i = 0; i < 4; i++)
        {
            int cx = block.blocks[i].x;
            int cy = block.blocks[i].y;
            int cz = block.blocks[i].z;
            cx+=offset_x;
            cy+=offset_y;
            cz+=offset_z;
            if(cx >= 0 && cx < static_cast<int>(width) && cy >= 0 && cy < static_cast<int>(height))
            {
                data[cx][cy][cz] = block.blocks[i].index_color;
            }
        }
        
    }
    
    
    template<size_t width, size_t height, size_t depth>
    void mpGrid<width,height,depth>::merge_down()
    {
        size_t i = 0, z = 0, x_depth = 0;
        
        for(i=0; i<width;i++)
        {
            for(z = 0; z < height-1; z++)
            {
                for(x_depth=0;x_depth<depth;++x_depth) {
                    if(data[i][z][x_depth] != 0 && data[i][z+1][x_depth] == 0)
                    {
                        data[i][z+1][x_depth] = data[i][z][x_depth];
                        data[i][z][x_depth] = 0;
                        break;
                    }
                }
            }
        }
    }
    
    
    template<size_t width, size_t height, size_t depth>
    void mpGrid<width,height,depth>::update()
    {
        size_t i,z,d;
        // left to right 4 in  a row vertical
		for(i = 0; i < width-3; i++)
        {
            for(z = 0; z < height; z++)
            {
                for(d = 0; d < depth; d++) {
                    int cur_item = data[i][z][d];
                    if(cur_item == 0 || cur_item == -1) continue;
                    if(i+3 < width && cur_item == data[i+1][z][d] && cur_item == data[i+2][z][d] && cur_item == data[i+3][z][d])
                    {
                        
                        if(i+4 < width && cur_item==data[i+4][z][d]) {
                            data[i+4][z][d] = -1;
                            
                            if(i+5 < width && cur_item == data[i+5][z][d]) {
                                data[i+5][z][d] = -1;
                            }
                        }
                        data[i][z][d] = -1;
                        data[i+1][z][d] = -1;
                        data[i+2][z][d] = -1;
                        data[i+3][z][d]= -1;
                        addScore(2,4);
                        continue;
                    }
                }
            }
            
        }
        // horizontal lines
		for(i = 0; i < width; i++)
        {
            for(z = 0; z < height-3; z++)
            {
                for(int d = 0; d < depth; d++) {
                    int cur_item = data[i][z][d];
                    if(cur_item == 0 || cur_item == -1) continue;
                    if(cur_item == data[i][z+1][d] && cur_item == data[i][z+2][d] && cur_item == data[i][z+3][d])
                    {
                        
                        if(z+4 < height && cur_item == data[i][z+4][d]) {
                            data[i][z+4][d] = -1;
                            if(z+5 < height && cur_item == data[i][z+5][d]) {
                                data[i][z+4][d] = -1;
                            }
                        }
                        data[i][z][d] = -1;
                        data[i][z+1][d] = -1;
                        data[i][z+2][d] = -1;
                        data[i][z+3][d] = -1;
                        addScore(3,4);
                    }
                }
            }
        }
        //  removes squares
		for(i = 0; i < width-1; i++)
        {
            for(z = 0; z < height-1; z++)
            {
                for(int d = 0; d < depth; d++) {
                    int cur_item = data[i][z][d];
                    if(cur_item == 0 || cur_item == -1) continue;
                    if(cur_item == data[i][z+1][d] && cur_item == data[i+1][z][d] && cur_item == data[i+1][z+1][d])
                    {
                        if(i+2 < width && z+1 < height) {
                            if(cur_item == data[i+2][z][d] && cur_item == data[i+2][z+1][d]) {
                                data[i+2][z][d] = -1;
                                data[i+2][z+1][d] = -1;
                            }
                        }
                        
                        data[i][z][d] = -1;
                        data[i+1][z][d] = -1;
                        data[i+1][z+1][d] = -1;
                        data[i][z+1][d] = -1;
                        addScore(10,4);
                    }
                }
            }
        }
        merge_down();
    }
    
    

    blockType::blockType(const blockType &t)
    {
        operator=(t);
    }
    
    void blockType::operator=(const blockType &t)
    {
        x = t.x;
        y = t.y;
        z = t.z;
        index_color = t.index_color;
    }
    
    bool blockType::operator==(const blockType &t)
    {
        
        if(t.x == x && t.y == y && t.z == z && t.index_color == index_color) return true;
        return false;
    }
    
    
    
    gameBlock::gameBlock(const gameBlock &b)
    {
        operator=(b);
    }
    
    void gameBlock::operator=(const gameBlock &b)
    {
        x = b.x;
        y = b.y;
        z = b.z;
        blocks[0] = b.blocks[0];
        blocks[1] = b.blocks[1];
        blocks[2] = b.blocks[2];
        blocks[3] = b.blocks[3];
    }
    
    
    void gameBlock::randBlock()
    {
        
        y = 0;
        x = mxMut::GRID_W/2;
        z = 0;
        do
        {
            blocks[0].index_color = 1+rand()%5;
            blocks[1].index_color = 1+rand()%5;
            blocks[2].index_color = 1+rand()%5;
            blocks[3].index_color = 1+rand()%5;
            
        } while (blocks[0].index_color == blocks[1].index_color && blocks[0].index_color == blocks[2].index_color && blocks[0].index_color == blocks[3].index_color );
        
        
        block_type = static_cast<block_t>(rand()%3);
        
        
        blocks[0].z = blocks[1].z = blocks[2].z = blocks[3].z = 0;
        
        switch(block_type)
        {
                /* 1 */case BLOCK_HORIZ:
                blocks[0].x = 0;
                blocks[0].y = 0;
                blocks[0].z = 0;
                blocks[1].x = 0;
                blocks[1].y = 1;
                blocks[1].z = 0;
                blocks[2].x = 0;
                blocks[2].z = 0;
                blocks[2].y = 2;
                blocks[3].x = 0;
                blocks[3].y = 3;
                blocks[3].z = 0;
                break;
                /* 1 */case BLOCK_VERT:
                blocks[0].x =  0;
                blocks[0].y = 0;
                blocks[0].z = 0;
                blocks[1].x = 1;
                blocks[1].y = 0;
                blocks[3].z = 0;
                blocks[2].x = 2;
                blocks[2].y = 0;
                blocks[2].z = 0;
                blocks[3].x = 3;
                blocks[3].y = 0;
                blocks[3].z = 0;
                break;
                /* 1 */case BLOCK_SQUARE:
                blocks[0].x = 0;
                blocks[0].y = 0;
                blocks[0].z = 0;
                blocks[1].z = 0;
                blocks[2].z = 0;
                blocks[3].z = 0;
                blocks[1].x = 0;
                blocks[1].y = 1;
                blocks[3].x = 1;
                blocks[3].y = 0;
                blocks[2].x = 1;
                blocks[2].y = 1;
                break;
        }
        
        
    }
    
    mxMut::mxMut(): nscore(0), nclear(0), grid(this)
    {
        
        grid.score = 0;
        grid.blocks_cleared = 0;
        freez = false;
        
    }
    
    void mxMut::newGame()
    {
        
        grid.clear();
        grid.score =  0;
        grid.blocks_cleared = 0;
        next.randBlock();
        nextBlock();
        //setTimer(600);
		game_over = false;
        inc_s = inc_c = 0;
        increase = false;
        
    }
    
    void mxMut::moveInward() {
        int i = 0;
        bool go = true;
        for(i=0; i < 4; i++) {
            int new_z = current.z+current.blocks[i].z;
            new_z = !new_z;
            if(grid.data[current.x+current.blocks[i].x][current.y+current.blocks[i].y][new_z] != 0) {
                go = false;
                break;
            }
        }
        
        if(go == true) {
            current.z = !current.z;
        }
    }
    
    
    void mxMut::moveLeft()
    {
        
        int i;
        bool go = true;
        
        // scan for collisions
        
        for(i=0;i<4;i++)
        {
            
            if(current.x+current.blocks[i].x > 0)
            {} else { go = false; break; }
            
            if(grid.data[current.x+current.blocks[i].x-1][current.y+current.blocks[i].y][current.z+current.blocks[i].z] != 0)
            { go = false; break; }
            
            
        }
        
        if(go == true)
            current.x--;
        
    }
    
    void mxMut::moveRight()
    {
        
        int i;
        bool go = true;
        
        // scan for collisoins
        
        for(i=0;i<4;i++)
        {
            if(current.x+current.blocks[i].x<(grid.grid_w-1))
            {} else { go = false; break; }
            
            if(grid.data[current.x+current.blocks[i].x+1][current.y+current.blocks[i].y][current.z+current.blocks[i].z] != 0)
            { 	go = false; break; }
            
            
        }
        
        
        if(go == true)
            current.x++;
        
    }
    
    void mxMut::moveDown()
    {
        update_moveDown();
    }
    
    void mxMut::shiftColor()
    {
        // shift color
		int colors[4];
        
        for(int i = 0; i < 4; i++)
            colors[i] = current.blocks[i].index_color;
        
        current.blocks[0].index_color = colors[3];
        current.blocks[1].index_color = colors[0];
        current.blocks[2].index_color = colors[1];
        current.blocks[3].index_color = colors[2];
        
    }
    
    void mxMut::nextBlock()
    {
        current = next;
        next.randBlock();
    }
    
    void mxMut::update_moveDown()
    {
        
        int i;
        bool go = true;
        
        for(i = 0; i < 4; i++)
        {
            
            if(current.y+current.blocks[i].y > grid.grid_h-2)
            {
                update_mergeBlock();
                return;
            } else go = true;
            
            
            if(grid.data[current.x+current.blocks[i].x][current.y+current.blocks[i].y+1][current.z+current.blocks[i].z] != 0)
            {
                if(current.y > 3) update_mergeBlock();
                else {
                    //stopTimer()
                    game_over = true;
                    
                }
                return;
            }
            
        }
        
        if(go == true)
            current.y++;
        
    }
    
    
    void mxMut::update_mergeBlock()
    {
        
        grid.merge(current);
        nextBlock();
    }
    
    void mxMut::update() {
        /*	unsigned int mxMut::timerExecution(unsigned int mil)
         { */
        //if(freez == true) return 0;
        
        update_moveDown();
        
        //		grid.update();
        
        /*	return mil;
         }*/
    }
    
    

    
}


mp::mxMut *mut_game;
LMutatris *mutatris;

@implementation LMutatris
   
- (id)init {
    self = [super init];
    mut_game = new mp::mxMut();
    level = 0;
    return self;
}

- (void) dealloc {  
        delete mut_game;
}

- (int) score {
    return mut_game->grid.score;
}

- (int) clears {
    return mut_game->grid.blocks_cleared;
}

- (int) Level { return level; }

- (void) moveLeft {
    mut_game->moveLeft();
}
 
- (void) moveRight {
    mut_game->moveRight();
}
- (void) moveDown {
    mut_game->moveDown(); 
}
- (void) shiftColors {
    mut_game->shiftColor();
}

- (BOOL) is_GameOver  {
    return (mut_game->is_gameOver());
}

       
- (void) drawGrid: (CGRect) rect {
    CGRect r = [[UIScreen mainScreen] bounds];
    [bg_image drawInRect: r];
    CGContextRef context = UIGraphicsGetCurrentContext();
    r.origin.x += 20;
    r.size.width -= 40;
    r.origin.y += 20;
    r.size.height -= 80;
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextFillRect(context, r);
    static float color_rand[17][26] = { 0 };
    for(int x = 0; x < mut_game->grid.grid_w; ++x) {
        for(int y = 0; y < mut_game->grid.grid_h; ++y) {
            int block_color = mut_game->grid.data[x][y][0];
    
            if(block_color == -1) {
                CGContextSetRGBFillColor(context, colors[rand()%5].values[0], colors[rand()%5].values[1], colors[rand()%5].values[2], 1);
                color_rand[x][y] += 0.2f;
                if(color_rand[x][y] > 1.0f) {
                    color_rand[x][y] = 0;
                    mut_game->grid.data[x][y][0] = 0;
                }
            }
            else
            if(block_color == 0) 
                CGContextSetRGBFillColor(context, 0, 0, 0, 1);
            else
                CGContextSetRGBFillColor(context, colors[block_color].values[0], colors[block_color].values[1], colors[block_color].values[2], 1.0f);
            CGRect rect = CGRectMake(r.origin.x+(x*16), r.origin.y+(y*16), 16, 16);
            CGContextFillRect(context, rect);
            
        }
    }
    for(int q = 0; q < 4; q++) {
        int off_x = r.origin.x;
        int off_y = r.origin.y;
        int xPos = mut_game->current.x+mut_game->current.blocks[q].x;
        int yPos = mut_game->current.y+mut_game->current.blocks[q].y;
        off_x += xPos*16;
        off_y += yPos*16;
        int block_color = mut_game->current.blocks[q].index_color;
        CGContextSetRGBFillColor(context, colors[block_color].values[0], colors[block_color].values[1], colors[block_color].values[2], 1.0f);
        CGContextFillRect(context, CGRectMake(off_x, off_y, 16, 16));
    }
    
    [[UIColor whiteColor] set ];
    NSString *score = [NSString stringWithFormat:@"Level: %d Score: %d Clears: %d", level, mut_game->grid.score, mut_game->grid.blocks_cleared ];
    [score drawAtPoint: CGPointMake(r.origin.x + 5, r.origin.y + 5) withFont: [UIFont systemFontOfSize: 12]];
    
    
    if(level_ani == YES) {
        [[UIColor redColor] set ];
        NSString *level_str = [NSString stringWithFormat:@"Now at Level: %d Speed: %0.2f", level,speed];
        [level_str drawAtPoint: CGPointMake(r.origin.x+5, r.origin.y+r.size.height/2 - 25) withFont:[UIFont systemFontOfSize: 20]];
    }
    
    
}

- (void) startNewGame {
    mut_game->newGame();   
    [self changeLevel];
    level = 1;
    speed = 1.0f;
}

- (void) update {
    mut_game->update();
}

- (void) grid_update {
    mut_game->grid.update();
    if(mut_game->increase == true) {
        level++;
        mut_game->increase = false;
        [self changeLevel];
    }
    
    if(level_ani == YES) {
        static int counter = 0;
        if(++counter > 25) {
            counter = 0;
            level_ani = NO;
            speed -= 0.1f;
            [view_obj setGameTimer:speed];
        }
    }
   
    
}

- (void) changeLevel {
    level_ani = YES;
}

@end


@implementation gameScreen


- (void) timerUpdate: (id)s  {
    [self updateProgram: s];
    [self setNeedsDisplay];
    
}
- (void) gridUpdate: (id) g {
    [self updateCallback];
    [self setNeedsDisplay];
}

- (void) loadProgram {
    bg_image = [UIImage imageNamed:@"gamebg.png"];
    view_dictionary = [[NSMutableDictionary alloc] init ];
    update_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector: @selector(timerUpdate:) userInfo:nil repeats:YES];
    clear_timer =[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector: @selector(gridUpdate:) userInfo:nil repeats:YES];
    srand((unsigned int) time(0));
}

-(void)drawRect:(CGRect)rc {
    [self drawScreen:rc];
}

- (void) setGameTimer: (float) value {
    [update_timer invalidate];
    update_timer = [NSTimer scheduledTimerWithTimeInterval:value target:self selector: @selector(timerUpdate:) userInfo:nil repeats:YES];
}


- (void) setScreen: (NSString *) scr_str {
    id obj = [view_dictionary objectForKey:scr_str];
    if(obj != nil)
        current_view = obj;
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
                [self shiftColors];
                stated = STATE_0;
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


- (void) updateProgram: (id) i {
    [mutatris update];
    if([mutatris is_GameOver] == YES) {
        [update_timer invalidate];
        [clear_timer invalidate];
        [mainDelegate setGameOver: [mutatris score] Clears: [mutatris clears] Level: [mutatris Level]];        
    }
}
- (void) updateCallback {
    [mutatris grid_update];
}

- (void) loadScr {
    mutatris = [[LMutatris alloc] init];
    [mutatris startNewGame];
}
- (void) drawScreen:(CGRect) rect {
    if([mutatris is_GameOver] == NO) [mutatris drawGrid:rect];
}

- (void) moveLeft {
    [mutatris moveLeft];
}

- (void) moveRight {
    [mutatris moveRight];
}

- (void) moveDown {
    [mutatris moveDown];
}
- (void) shiftColors {
    [mutatris shiftColors];
}

@end
