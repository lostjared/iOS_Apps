/*
 *
 *
 * http://lostsidedead.com
 * (c) 2012 Jared Bruni GPL
 */

#include"quadtris.h"
#include"QViewController.h"

	namespace quad {

		Block::Block() {
			clear();
		}

		Block::Block(const Block &b) {
			operator=(b);
		}

		void Block::operator=(const Block &b) {
			x = b.x;
			y = b.y;
			color = b.color;
			timeout = b.timeout;
		}

		bool Block::operator==(const Block &b) {
			if(b.color == color) return true;
			return false;
		}

		void Block::clear() {
			x = y = color = 0;
			timeout = 0;
		}

		void Block::Swap(Block &b) {
			Block temp(b);
			b = *this;
			*this = temp;
		}

		std::ostream &operator<<(std::ostream &out, const Block &b) {
			out << "Block [" << b.x << "," << b.y << "] = " << b.color << "\n";
			return out;
		}

		GamePiece::GamePiece() {
			x = y = 0;
			visible = false;
			type = BLOCK_NULL;
			block_lock = false;
		}

		GamePiece::GamePiece(const GamePiece &p) {
			copyBlock(&p);
		}

		void GamePiece::operator=(const GamePiece &p) {
			copyBlock(&p);
		}

		void GamePiece::showPiece(bool s) {
			visible = s;
		}

		std::ostream &operator<<(std::ostream &out, GamePiece &p) {
			out << "Game Block {" << p.x << "," << p.y << "} = {\n";
			for(int i = 0; i < 4; ++i)
				out << p.blocks[i];

			out << "\n};\n";
			return out;
		}

		void GamePiece::setBlockType(block_t type) {
			if(block_lock == true) return;
			switch (type) {
			case BLOCK_HORIZ:
				blocks[0].x = 0;
				blocks[0].y = 0;
				blocks[1].x = 0;
				blocks[1].y = 1;
				blocks[2].x = 0;
				blocks[2].y = 2;
				blocks[3].x = 0;
				blocks[3].y = 3;
				break;
			case BLOCK_VERT:
				blocks[0].x = 0;
				blocks[0].y = 0;
				blocks[1].x = 1;
				blocks[1].y = 0;
				blocks[2].x = 2;
				blocks[2].y = 0;
				blocks[3].x = 3;
				blocks[3].y = 0;
				break;
			case BLOCK_SQUARE:
				blocks[0].x = 0;
				blocks[0].y = 0;
				blocks[1].x = 0;
				blocks[1].y = 1;
				blocks[3].x = 1;
				blocks[3].y = 0;
				blocks[2].x = 1;
				blocks[2].y = 1;
				break;
			default:
				std::cerr << "Error setBlockType failed..\n";
				break;
			}
			this->type = type;
		}

		void GamePiece::randBlock() {
			type = block_t(1 + rand()%3);
			setBlockType(type);
			do {
				for(unsigned int i = 0; i < 4; ++i) {
					blocks[i].color = 1+(rand()%Game::score.BLOCK_COUNT);
				}
			} while(blocks[0] == blocks[1] && blocks[0] == blocks[2] && blocks[0] == blocks[3]);
		}

		void GamePiece::swapColorsUp() {
			Block tempBlocks[4];
			tempBlocks[0] = blocks[3];
			tempBlocks[1] = blocks[0];
			tempBlocks[2] = blocks[1];
			tempBlocks[3] = blocks[2];
			for(unsigned int i = 0; i < 4; ++i)
				blocks[i] = tempBlocks[i];
		}
		void GamePiece::swapColorsDown() {
			int temp_colors[4];
			for(unsigned int i = 0; i < 4; ++i) temp_colors[i] = blocks[i].color;
			blocks[0].color = temp_colors[1];
			blocks[1].color = temp_colors[2];
			blocks[2].color = temp_colors[3];
			blocks[3].color = temp_colors[0];
		}

		void GamePiece::copyBlock(const GamePiece *p) {
			for(unsigned int i = 0; i < 4; ++i) {
				blocks[i] = p->blocks[i];
			}
			x = p->x;
			y = p->y;
		}

		void GamePiece::moveLeft() {
			if(x > 0) --x;
		}

		void GamePiece::moveRight() {
			x++;
		}

		void GamePiece::moveDown() {
			y++;
		}

		GameGrid::GameGrid() {
			width = height = 0;
			game_grid = 0;
			direction = MOVE_NULL;
			position = 0;
			gameOver = false;
			switch_block = false;
			callback_x = 0;
		}

		GameGrid::GameGrid(const unsigned int w, const unsigned int h) {
			game_grid = 0;
			direction = MOVE_NULL;
			position = 0;
			gameOver = false;
			switch_block = false;
			callback_x = 0;
			resetGrid(w, h);
		}

		GameGrid::~GameGrid() {
			eraseGrid();
		}

		void GameGrid::eraseGrid() {
			if(game_grid == 0) return;
				for(unsigned int i = 0; i < width; ++i) {
					delete [] game_grid[i];
			}
			delete [] game_grid;
			game_grid = 0;
		}

		void GameGrid::resetGrid(const unsigned int w, const unsigned int h) {
			if(game_grid != 0) {
				eraseGrid();
			}
			game_grid = new Block*[w];
			for(unsigned int i = 0; i < w; ++i) {
				game_grid[i] = new Block[h];
				for(unsigned int hx = 0; hx < h; ++hx) {
					game_grid[i][hx].clear();
				}
			}
			width = w;
			height = h;
			direction = MOVE_NULL;
			gameOver = false;
		}

		void GameGrid::fillGrid(const unsigned int color) {
			for(unsigned int i = 0; i < width; ++i) {
				for(unsigned int z = 0; z < height; ++z) {
					game_grid[i][z].setColor(color);
				}
			}
		}

		void GameGrid::setDirection(const enum Direction d) {
			direction = d;
		}

		bool GameGrid::testBlockPos(unsigned int x, unsigned int y) {
			for(unsigned int i = 0; i < 4; ++i) {
				unsigned int tx=x+piece.x+piece.blocks[i].x;
				unsigned int ty=y+piece.y+piece.blocks[i].y;
				if(tx > 0 && tx < width && ty > 0 && ty < height && game_grid[tx][ty].getColor() != 0) return false;
			}
			return true;
		}
		void GameGrid::movePos(Direction dir) {
			++quad::Game::score.total_moves;
			switch(dir) {
			case MOVE_LEFT: {
				if(piece.x > 0 && piece.y < height && testBlockPos(-1,0) == true)
					piece.moveLeft();
			}
				break;
			case MOVE_RIGHT:
			{
				if(piece.x < width-2 && piece.y < height-1) {
					for(unsigned int q = 0; q < 4; ++q) {
						unsigned int tx = piece.x+piece.blocks[q].x;
						unsigned int ty = piece.y+piece.blocks[q].y;
						if(tx > width-2 || ty > height-2)
							return;
					}
					if(testBlockPos(1, 0)==true) piece.moveRight();
				}
			}
				break;
			case MOVE_DOWN:
				update_moveDown();
				break;
			case MOVE_UP:
				piece.swapColorsDown();
				break;
			case MOVE_NULL:
				return;
				break;
			case MOVE_BLOCKSWITCH: {

				unsigned int type = piece.type;
				if(++type > 3) type = 1;
				for(unsigned int q = 0; q < 4; ++q) {
					if((piece.x+piece.blocks[q].x < width-3) && (piece.y+piece.blocks[q].y < height-3) && testBlockPos(1,1) == true && testBlockPos(0, 1) == true)
					{
						piece.setBlockType(block_t(type));
						return;
					}
					else
						return;
				}
			}
				break;
			}
		}
		// asummes piece is in a valid location
		void GameGrid::mergeBlocks() {
			for(unsigned int i = 0; i < 4; ++i) {
				unsigned int px=piece.x+piece.blocks[i].x;
				unsigned int py=piece.y+piece.blocks[i].y;
				game_grid[px][py] = piece.blocks[i];
				if(py <= 1) { gameOver = true;  }
			}
		}

		void GameGrid::setBlock(Block &b, unsigned int x, unsigned int y) {
			game_grid[x][y] = b;

		}

		void GameGrid::mergeDown() {
			for(unsigned int i = 0; i < width; ++i) {
				for(unsigned int z = 0; z < height-1; ++z) {
					if(game_grid[i][z].getColor() != 0 && game_grid[i][z+1].getColor() == 0) {
						game_grid[i][z+1] = game_grid[i][z];
						game_grid[i][z].setColor(0);
						break;
					}
				}
			}
		}

		void GameGrid::procBlocks() {
			unsigned int i=0,z=0;
            bool draw = false;
			for(i = 0; i < width; ++i) {
				for(z = 0; z < height; ++z) {
					if(game_grid[i][z].getColor() == 0xFE) {
						++game_grid[i][z].timeout;
                        draw = true;
						if(game_grid[i][z].timeout > 15) {
							game_grid[i][z].timeout = 0 ;
							game_grid[i][z].color = 0;
						}
					}
				}
                // custom for iphone version
                if(draw == true) {
                    [[view_controller view_ctrl] setNeedsDisplay];
                }
			}
			for(i = 0; i < width-3; ++i) {
				for(z = 0; z < height; ++z) {
					Block cur_block = game_grid[i][z];
					if(cur_block.getColor() == 0 || cur_block.getColor() == 0xFE) continue;
					if(cur_block == game_grid[i+1][z] && cur_block == game_grid[i+2][z] && cur_block == game_grid[i+3][z]) {
						if(i+4 < width && game_grid[i+4][z] == cur_block) {
							Game::score.addClear(1);
							game_grid[i+4][z].setColor(0xFE);
						}
						if(i+5 < width && game_grid[i+5][z] == cur_block) {
							Game::score.addClear(1);
							game_grid[i+5][z].setColor(0xFE);
						}
						Game::score.addClear(4);
						for(unsigned int q = 0; q < 4; ++q)
							game_grid[i+q][z].setColor(0xFE);
						continue;
					}
				}
			}

			for(i = 0; i < width; ++i) {
				for(z = 0; z < height-3; ++z) {
					Block cur_block = game_grid[i][z];
					if(cur_block.getColor() == 0 || cur_block.getColor() == 0xFE) continue;
					if(cur_block == game_grid[i][z+1] && cur_block == game_grid[i][z+2] && cur_block == game_grid[i][z+3]) {
						if(z+4 < height && game_grid[i][z+4] == cur_block) {
							Game::score.addClear(1);
							game_grid[i][z+4].setColor(0xFE);
						}
						if(z+5 < height && game_grid[i][z+5] == cur_block) {
							Game::score.addClear(1);
							game_grid[i][z+5].setColor(0xFE);
						}
						Game::score.addClear(4);
						for(unsigned int q = 0; q < 4; ++q) {
							game_grid[i][z+q].setColor(0xFE);
						}
						continue;
					}
				}
			}
			for(i = 0; i < width-1; ++i) {
				for(z = 0; z < height-1; ++z) {
					Block cur_block = game_grid[i][z];
					if(cur_block.getColor() == 0 || cur_block.getColor() == 0xFE) continue;
					if(cur_block == game_grid[i][z+1] && cur_block == game_grid[i+1][z] && cur_block == game_grid[i+1][z+1]) {
						if(i+2 < width && z+2 < height && cur_block == game_grid[i+2][z+1] && cur_block == game_grid[i+2][z+2]) {
							Game::score.addClear(2);
							game_grid[i+2][z+1].setColor(0xFE);
							game_grid[i+2][z+2].setColor(0xFE);
						}
						Game::score.addClear(4);
						game_grid[i][z].setColor(0xFE);
						game_grid[i+1][z].setColor(0xFE);
						game_grid[i+1][z+1].setColor(0xFE);
						game_grid[i][z+1].setColor(0xFE);
						continue;
					}
				}
			}
		}

		void GameGrid::update() {
		}

		void GameGrid::update_moveDown() {

			for(unsigned int q = 0; q < 4; ++q) {
				if(piece.y+piece.blocks[q].y > height-2) {
					mergeBlocks();
					releaseBlock();
					return;
				}
				else if(game_grid[piece.x+piece.colorAt(GamePiece::BlockIndex(q)).x][piece.y+piece.colorAt(GamePiece::BlockIndex(q)).y+1].getColor() != 0) {
					mergeBlocks();
					releaseBlock();
					return;
				}
			}
			piece.y++;
		}

		void GameGrid::erase() {
			for(unsigned int i = 0; i < width; ++i) {
				for(unsigned int z = 0; z < height; ++z) {
					game_grid[i][z].clear();
				}
			}
		}

		void GameGrid::releaseBlock() {
			if(gameOver == false) {
				piece.x = width/2;
				piece.y = 0;
				piece.randBlock();
			}
			if(callback_x != 0) callback_x();
		}

		Game::Game() {
			current = 0;
		}

		void Game::newGame(unsigned int width_, unsigned int height_, unsigned int sw, unsigned int sh) {
			grids[0].resetGrid(width_, height_);
			grids[0].setDirection(MOVE_UP);
			grids[1].resetGrid(width_, height_);
			grids[1].setDirection(MOVE_DOWN);
			grids[2].resetGrid(sw,sh);
			grids[2].setDirection(MOVE_LEFT);
			grids[3].resetGrid(sw, sh);
			grids[3].setDirection(MOVE_RIGHT);
			current = 0;
			for(unsigned int i = 0; i < 4; ++i) {
				grids[i].erase();
				grids[i].releaseBlock();
				grids[i].switch_block = false;
			}
			score.clear();
			setActiveGrid(GRID_1); // first grid is move down
		}

		void Game::setActiveGrid(const unsigned int cur) {
			current = cur;
			for(int i = 0; i < 4; ++i) {
				grids[i].piece.showPiece(false);
			}
			grids[current].piece.showPiece(true);
		}

		unsigned int Game::getActiveGridIndex() const {
			return current;
		}

		void Game::update() {

			procBlocks();
			for(unsigned int i = 0; i < 4; ++i) {
				grids[i].mergeDown();
			}
		}

		void Game::procBlocks() {
			for(unsigned int i = 0; i < 4; ++i) {
				grids[i].procBlocks();
			}
		}

		void Game::timer_Update() {
			grids[current].update_moveDown();
		}

		quad::Score Game::score;

		std::ostream &operator<<(std::ostream &out, const GameGrid &g) {
			for(unsigned int i=0; i < g.height; ++i) {
				for(unsigned int z = 0; z < g.width; ++z) {
					out << g.game_grid[z][i].getColor() << " ";
				}
				out << std::endl;
			}
			return out;
		}

		std::ostream &operator<<(std::ostream &out, const Game &g) {
			for(unsigned int i = 0; i < 4; ++i) {
				out << "Grid: " << i << "\n" << g.grids[i] << "\n";
			}
			return out;
		}

		std::ostream &operator<<(std::ostream &out, const Score &s) {
			out << "Score of: " << s.score << " : " << s.num_clr << std::endl;
			return out;
		}
	}
